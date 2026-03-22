import 'dart:io';

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

  /// Checks if a `riverpod_craft.yaml` config file exists.
  static bool hasConfig([Directory? directory]) {
    final dir = directory ?? Directory.current;
    return File('${dir.path}/riverpod_craft.yaml').existsSync();
  }
}
