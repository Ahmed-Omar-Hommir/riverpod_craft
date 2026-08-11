import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:yaml/yaml.dart';

/// Riverpod-generator configuration, read from the `error_mapper` and
/// `paged_provider_mapper` keys under the `riverpod_craft:` block of
/// `craft_runner.yaml`.
///
/// State is global (static) because the generated `ProviderInfo`/`Command`
/// models reach into it directly for the error type and inlined mapper source.
/// [load] is called once at the start of each generation pass.
class CraftConfig {
  static String? pagedMapperPath;
  static bool get hasPagedMapper => pagedMapperPath != null;

  /// The raw input type name from the mapper function (e.g., "ApiPagedResponse").
  static String? pagedMapperInputType;

  /// The full source of the `pagedMapper` function, to inline in `.craft.dart`.
  static String? pagedMapperFunctionSource;

  /// Path to the global error mapper file, from `error_mapper` in the config.
  static String? errorMapperPath;
  static bool get hasErrorMapper => errorMapperPath != null;

  /// The full source of the `errorMapper` function, to inline in `.craft.dart`.
  /// The function is renamed to [errorMapperInlineName] so the inlined copy
  /// stays private and never collides through barrel re-exports.
  static String? errorMapperFunctionSource;

  /// Private name the user's `errorMapper` is inlined under in each generated
  /// `.craft.dart`. Leading `_` keeps it library-private so files that are
  /// re-exported by a barrel don't produce `ambiguous_export` errors.
  static const errorMapperInlineName = r'_$errorMapper';

  /// The `errorMapper` function's return type (e.g. `Failure`). This becomes
  /// the error type parameter `F` in generated state and notifiers.
  static String? errorMapperOutputType;

  /// The error type parameter (`F`) emitted into generated code: the mapper's
  /// return type when configured, otherwise `Object`.
  static String get errorType =>
      hasErrorMapper && errorMapperOutputType != null
      ? errorMapperOutputType!
      : 'Object';

  /// Reads `craft_runner.yaml` from [directory] (defaults to the current
  /// working directory), populates the mapper paths, and parses each mapper
  /// file so the sources are ready to inline. Safe to call repeatedly; each
  /// call fully re-derives the state from disk.
  static void load([Directory? directory]) {
    final dir = directory ?? Directory.current;
    final configFile = File('${dir.path}/craft_runner.yaml');
    pagedMapperPath = null;
    pagedMapperInputType = null;
    pagedMapperFunctionSource = null;
    errorMapperPath = null;
    errorMapperFunctionSource = null;
    errorMapperOutputType = null;

    if (configFile.existsSync()) {
      try {
        final yaml = loadYaml(configFile.readAsStringSync());
        final section = yaml is YamlMap ? yaml['riverpod_craft'] : null;
        if (section is YamlMap) {
          final paged = section['paged_provider_mapper'];
          if (paged is String) pagedMapperPath = _resolve(paged, dir);
          final error = section['error_mapper'];
          if (error is String) errorMapperPath = _resolve(error, dir);
        }
      } catch (e) {
        print('riverpod_craft: failed to parse craft_runner.yaml: $e');
      }
    }

    parseMapperFile();
    parseErrorMapperFile();
  }

  static String _resolve(String path, Directory dir) {
    final file = File(path);
    if (file.isAbsolute) return path;
    return '${dir.path}/$path';
  }

  /// Parses the mapper file to extract the input type and function body.
  ///
  /// Given a mapper like:
  /// ```dart
  /// PaginatedResponse<T> pagedMapper<T>(ApiPagedResponse<T> data) { ... }
  /// ```
  /// Extracts:
  /// - `pagedMapperInputType` = "ApiPagedResponse"
  /// - `pagedMapperFunctionSource` = the full function source code
  static void parseMapperFile() {
    if (pagedMapperPath == null) return;

    final file = File(pagedMapperPath!);
    if (!file.existsSync()) {
      print('Warning: Mapper file not found: $pagedMapperPath');
      return;
    }

    final content = file.readAsStringSync();
    final result = parseString(content: content);
    final unit = result.unit;

    // Find the `pagedMapper` function
    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == 'pagedMapper') {
        // Store the full function source
        pagedMapperFunctionSource = declaration.toSource();

        // Extract input type from first param
        final params = declaration.functionExpression.parameters?.parameters;
        if (params != null && params.isNotEmpty) {
          final firstParam = params.first;
          String? paramType;

          if (firstParam is SimpleFormalParameter) {
            paramType = firstParam.type?.toSource();
          } else if (firstParam is DefaultFormalParameter) {
            final inner = firstParam.parameter;
            if (inner is SimpleFormalParameter) {
              paramType = inner.type?.toSource();
            }
          }

          if (paramType != null) {
            // Strip generic: "ApiPagedResponse<T>" → "ApiPagedResponse"
            final genericIdx = paramType.indexOf('<');
            pagedMapperInputType =
                genericIdx > 0 ? paramType.substring(0, genericIdx) : paramType;
          }
        }
        break;
      }
    }
  }

  /// Parses the error mapper file to extract the `errorMapper` function source.
  ///
  /// Given a mapper like:
  /// ```dart
  /// AppError errorMapper(Object error) { ... }
  /// ```
  /// Stores the full function source in [errorMapperFunctionSource] so it can
  /// be inlined into generated `.craft.dart` files.
  static void parseErrorMapperFile() {
    if (errorMapperPath == null) return;

    final file = File(errorMapperPath!);
    if (!file.existsSync()) {
      print('Warning: Error mapper file not found: $errorMapperPath');
      return;
    }

    final content = file.readAsStringSync();
    final result = parseString(content: content);
    final unit = result.unit;

    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == 'errorMapper') {
        // Capture the return type — it becomes the error type parameter `F`.
        errorMapperOutputType = declaration.returnType?.toSource();
        // Rename to a private name so the inlined copy doesn't leak through
        // barrel re-exports. The declared name is the first textual
        // occurrence (after the return type), so replaceFirst is safe.
        errorMapperFunctionSource = declaration.toSource().replaceFirst(
          'errorMapper',
          errorMapperInlineName,
        );
        break;
      }
    }

    if (errorMapperFunctionSource == null) {
      print(
        'Warning: No top-level `errorMapper` function found in '
        '$errorMapperPath',
      );
    } else if (errorMapperOutputType == null) {
      print(
        'Warning: `errorMapper` in $errorMapperPath has no explicit return '
        'type; generated error type falls back to `Object`. Annotate it, e.g. '
        '`Failure errorMapper(Object error) {...}`.',
      );
    }
  }
}
