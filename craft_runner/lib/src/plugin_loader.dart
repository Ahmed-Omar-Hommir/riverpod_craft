import 'dart:io';

import 'package:yaml/yaml.dart';

/// One plugin entry declared in `craft_runner.yaml`'s `plugins:` list.
///
/// Format: `<package_name>:<ClassName>`. The class must have a no-arg
/// constructor and implement `ProjectWideCraftPlugin`. The CLI instantiates
/// each entry in the generated entry script and registers it.
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

/// Loads plugin configuration from `craft_runner.yaml`.
///
/// The config file format:
/// ```yaml
/// plugins:
///   - retrofit_craft_plugin:RetrofitApiPlugin
///   - another_package:AnotherPlugin
/// ```
class PluginLoader {
  /// Reads `craft_runner.yaml` and returns each `<package>:<ClassName>`
  /// entry as a raw string. Returns an empty list if the config or block
  /// is absent.
  static List<String> loadPluginPaths([Directory? directory]) =>
      loadPluginSpecs(directory).map((s) => s.source).toList();

  /// Same as [loadPluginPaths], but returns parsed [PluginSpec] objects.
  /// Each entry must be a `<package>:<ClassName>` string; otherwise it's
  /// skipped with a warning.
  static List<PluginSpec> loadPluginSpecs([Directory? directory]) {
    final dir = directory ?? Directory.current;
    final configFile = File('${dir.path}/craft_runner.yaml');
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
      print('Warning: Failed to parse craft_runner.yaml: $e');
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

  /// Checks if a `craft_runner.yaml` config file exists.
  static bool hasConfig([Directory? directory]) {
    final dir = directory ?? Directory.current;
    return File('${dir.path}/craft_runner.yaml').existsSync();
  }
}
