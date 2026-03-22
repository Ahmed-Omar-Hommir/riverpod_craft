import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:yaml/yaml.dart';

/// Loads plugin configuration from `riverpod_craft.yaml`.
///
/// The config file format:
/// ```yaml
/// plugins:
///   - lib/plugins/my_plugin.dart
///   - lib/plugins/another_plugin.dart
/// ```
class PluginLoader {
  /// Reads `riverpod_craft.yaml` from the given directory and returns
  /// the list of plugin file paths declared in the config.
  ///
  /// Returns an empty list if the config file doesn't exist.
  static List<String> loadPluginPaths([Directory? directory]) {
    final dir = directory ?? Directory.current;
    final configFile = File('${dir.path}/riverpod_craft.yaml');

    if (!configFile.existsSync()) return [];

    try {
      final content = configFile.readAsStringSync();
      final yaml = loadYaml(content);

      if (yaml is! YamlMap) return [];

      final plugins = yaml['plugins'];
      if (plugins is! YamlList) return [];

      return plugins.map((e) => e.toString()).toList();
    } catch (e) {
      print('Warning: Failed to parse riverpod_craft.yaml: $e');
      return [];
    }
  }

  /// Reads the `paged_provider_mapper` path from `riverpod_craft.yaml`.
  ///
  /// Returns `null` if not configured.
  static String? loadPagedMapperPath([Directory? directory]) {
    final dir = directory ?? Directory.current;
    final configFile = File('${dir.path}/riverpod_craft.yaml');

    if (!configFile.existsSync()) return null;

    try {
      final content = configFile.readAsStringSync();
      final yaml = loadYaml(content);

      if (yaml is! YamlMap) return null;

      final mapper = yaml['paged_provider_mapper'];
      return mapper is String ? mapper : null;
    } catch (e) {
      return null;
    }
  }

  /// Checks if a `riverpod_craft.yaml` config file exists.
  static bool hasConfig([Directory? directory]) {
    final dir = directory ?? Directory.current;
    return File('${dir.path}/riverpod_craft.yaml').existsSync();
  }
}

/// Global config populated at CLI startup.
class CraftConfig {
  static String? pagedMapperPath;
  static bool get hasPagedMapper => pagedMapperPath != null;

  /// The raw input type name from the mapper function (e.g., "ApiPagedResponse").
  static String? pagedMapperInputType;

  /// All imports from the mapper file (to inject into .pg.dart).
  static List<String> pagedMapperImports = [];

  /// Parses the mapper file to extract the input type and imports.
  ///
  /// Given a mapper like:
  /// ```dart
  /// import 'models/api_paged_response.dart';
  /// PaginatedResponse<T> pagedMapper<T>(ApiPagedResponse<T> data) { ... }
  /// ```
  /// Extracts:
  /// - `pagedMapperInputType` = "ApiPagedResponse"
  /// - `pagedMapperImports` = all import directives from the mapper file
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

    // Collect all imports from the mapper file
    pagedMapperImports = unit.directives
        .whereType<ImportDirective>()
        .map((d) => d.toSource())
        .toList();

    // Find the `pagedMapper` function and extract its first param type
    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == 'pagedMapper') {
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
}
