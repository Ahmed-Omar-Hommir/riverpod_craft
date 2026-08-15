import 'dart:io';

import 'package:yaml/yaml.dart';

/// Configuration for the retrofit_craft plugin.
///
/// Read from the `retrofit_craft:` section of `craft_runner.yaml`. All
/// fields are optional; sensible defaults apply.
class RetrofitCraftConfig {
  const RetrofitCraftConfig({
    this.defaultEntry,
    this.defaultVersion,
    this.entryPath,
    this.versionPath,
    this.output = 'lib/app/app_api.craft.dart',
    this.rootClassName = 'AppApi',
  });

  /// `default_entry`: class name of an `Entry` subclass to use when an
  /// `@Api()` annotation omits the `entry:` argument. Generation fails if a
  /// class has no entry and no default is configured.
  final String? defaultEntry;

  /// `default_version`: class name of a `Version` subclass to use when an
  /// `@Api()` annotation omits the `version:` argument. When also absent,
  /// the class is exposed without a version layer.
  final String? defaultVersion;

  /// `entry_path`: when set, the scanner only looks for `Entry` subclasses
  /// in this single file. Otherwise it scans every Dart file under `lib/`.
  final String? entryPath;

  /// `version_path`: when set, the scanner only looks for `Version`
  /// subclasses in this single file. Otherwise it scans every Dart file
  /// under `lib/`.
  final String? versionPath;

  /// `output`: project-relative path of the generated aggregator. Must end
  /// in `.craft.dart` so `craft clean` removes it.
  final String output;

  /// `root_class_name`: name of the generated root class (default `AppApi`).
  final String rootClassName;

  /// Loads `retrofit_craft:` from `craft_runner.yaml` in [directory]
  /// (defaults to the current working directory). Returns a default config
  /// if the file or section is missing.
  /// Builds the config from a builder's `options:` block in `build.yaml`.
  static RetrofitCraftConfig fromOptions(Map<String, dynamic> options) {
    String? str(String key) {
      final value = options[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    return RetrofitCraftConfig(
      defaultEntry: str('default_entry'),
      defaultVersion: str('default_version'),
      entryPath: str('entry_path'),
      versionPath: str('version_path'),
      output: str('output') ?? 'lib/app/app_api.craft.dart',
      rootClassName: str('root_class_name') ?? 'AppApi',
    );
  }

  static RetrofitCraftConfig load([Directory? directory]) {
    final dir = directory ?? Directory.current;
    final configFile = File('${dir.path}/craft_runner.yaml');
    if (!configFile.existsSync()) return const RetrofitCraftConfig();

    final dynamic raw;
    try {
      raw = loadYaml(configFile.readAsStringSync());
    } catch (e) {
      print('retrofit_craft: failed to parse craft_runner.yaml: $e');
      return const RetrofitCraftConfig();
    }
    if (raw is! YamlMap) return const RetrofitCraftConfig();
    final section = raw['retrofit_craft'];
    if (section is! YamlMap) return const RetrofitCraftConfig();

    String? readStr(Object? key) {
      final v = section[key];
      return v is String ? v : null;
    }

    return RetrofitCraftConfig(
      defaultEntry: readStr('default_entry'),
      defaultVersion: readStr('default_version'),
      entryPath: readStr('entry_path'),
      versionPath: readStr('version_path'),
      output: readStr('output') ?? 'lib/app/app_api.craft.dart',
      rootClassName: readStr('root_class_name') ?? 'AppApi',
    );
  }
}
