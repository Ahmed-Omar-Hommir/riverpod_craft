import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:yaml/yaml.dart';

/// One plugin entry declared in `riverpod_craft.yaml`'s `plugins:` list.
///
/// Format: `<package_name>:<ClassName>`. The class must have a no-arg
/// constructor and implement either `RiverpodCraftPlugin<T>` (per-file)
/// or `ProjectWideCraftPlugin`. The CLI uses a runtime `is` check in the
/// generated entry script to route each instance to the right
/// registration call.
class PluginSpec {
  const PluginSpec({required this.package, required this.className});

  /// The package name on pub.dev (e.g. `retrofit_craft_plugin`).
  final String package;

  /// The plugin class exposed by that package's library
  /// (e.g. `RetrofitApiPlugin`).
  final String className;

  /// The full `<package>:<ClassName>` source form, used in diagnostics.
  String get source => '$package:$className';

  /// The Dart import URI for this plugin's package. Convention: the
  /// package's barrel library has the same base name as the package
  /// itself, e.g. `package:retrofit_craft_plugin/retrofit_craft_plugin.dart`.
  String get importUri => 'package:$package/$package.dart';
}

/// Loads plugin configuration from `riverpod_craft.yaml`.
///
/// The config file format (preferred since 0.6.0):
/// ```yaml
/// plugins:
///   - retrofit_craft_plugin:RetrofitApiPlugin
///   - another_package:AnotherPlugin
/// ```
class PluginLoader {
  /// Reads `riverpod_craft.yaml` and returns each `<package>:<ClassName>`
  /// entry as a raw string. Returns an empty list if the config or block
  /// is absent.
  static List<String> loadPluginPaths([Directory? directory]) =>
      loadPluginSpecs(directory).map((s) => s.source).toList();

  /// Same as [loadPluginPaths], but returns parsed [PluginSpec] objects.
  /// Each entry must be a `<package>:<ClassName>` string; otherwise it's
  /// skipped with a warning.
  static List<PluginSpec> loadPluginSpecs([Directory? directory]) {
    final dir = directory ?? Directory.current;
    final configFile = File('${dir.path}/riverpod_craft.yaml');
    if (!configFile.existsSync()) return [];

    try {
      final yaml = loadYaml(configFile.readAsStringSync());
      if (yaml is! YamlMap) return [];

      final plugins = yaml['plugins'];
      if (plugins is! YamlList) return [];

      final specs = <PluginSpec>[];
      for (final entry in plugins) {
        final spec = _parseEntry(entry);
        if (spec != null) specs.add(spec);
      }
      return specs;
    } catch (e) {
      print('Warning: Failed to parse riverpod_craft.yaml: $e');
      return [];
    }
  }

  static PluginSpec? _parseEntry(dynamic entry) {
    if (entry is! String) {
      print(
        'Warning: ignoring non-string plugins entry "$entry". '
        'Expected `<package>:<ClassName>`.',
      );
      return null;
    }
    final colon = entry.indexOf(':');
    if (colon <= 0 || colon == entry.length - 1) {
      print(
        'Warning: ignoring malformed plugins entry "$entry". '
        'Expected `<package>:<ClassName>`.',
      );
      return null;
    }
    final pkg = entry.substring(0, colon).trim();
    final cls = entry.substring(colon + 1).trim();
    if (pkg.isEmpty || cls.isEmpty) return null;
    return PluginSpec(package: pkg, className: cls);
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

  /// Reads the `error_mapper` path from `riverpod_craft.yaml`.
  ///
  /// Returns `null` if not configured.
  static String? loadErrorMapperPath([Directory? directory]) {
    final dir = directory ?? Directory.current;
    final configFile = File('${dir.path}/riverpod_craft.yaml');

    if (!configFile.existsSync()) return null;

    try {
      final content = configFile.readAsStringSync();
      final yaml = loadYaml(content);

      if (yaml is! YamlMap) return null;

      final mapper = yaml['error_mapper'];
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

  /// The full source of the `pagedMapper` function, to inline in `.craft.dart`.
  static String? pagedMapperFunctionSource;

  /// Path to the global error mapper file, from `error_mapper` in the config.
  static String? errorMapperPath;
  static bool get hasErrorMapper => errorMapperPath != null;

  /// The full source of the `errorMapper` function, to inline in `.craft.dart`.
  static String? errorMapperFunctionSource;

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
        errorMapperFunctionSource = declaration.toSource();
        break;
      }
    }

    if (errorMapperFunctionSource == null) {
      print(
        'Warning: No top-level `errorMapper` function found in '
        '$errorMapperPath',
      );
    }
  }
}
