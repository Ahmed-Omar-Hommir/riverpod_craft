import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class BuilderSpec {
  BuilderSpec({
    required this.package,
    required this.className,
    required this.options,
  });

  final String package;
  final String className;
  final Map<String, Object?> options;

  String get id => '$package:$className';
}

class CraftConfig {
  CraftConfig({
    required this.roots,
    required this.exclude,
    required this.builders,
  });

  final List<String> roots;
  final List<String> exclude;
  final List<BuilderSpec> builders;

  static const fileName = 'craft_runner.yaml';

  static CraftConfig load(String rootDir) {
    final file = File(p.join(rootDir, fileName));
    if (!file.existsSync()) {
      throw CraftConfigError('no $fileName in $rootDir');
    }

    final yaml = loadYaml(file.readAsStringSync());
    if (yaml is! YamlMap) throw CraftConfigError('$fileName is not a map');

    final builders = <BuilderSpec>[];
    final declared = yaml['builders'];
    if (declared is! YamlMap || declared.isEmpty) {
      throw CraftConfigError('$fileName declares no `builders:`');
    }
    declared.forEach((key, value) {
      final entry = '$key';
      final colon = entry.indexOf(':');
      if (colon <= 0 || colon == entry.length - 1) {
        throw CraftConfigError(
          'malformed builder "$entry" — expected `package:ClassName`',
        );
      }
      builders.add(
        BuilderSpec(
          package: entry.substring(0, colon).trim(),
          className: entry.substring(colon + 1).trim(),
          options: value is YamlMap ? _plain(value) : const {},
        ),
      );
    });

    return CraftConfig(
      roots: _stringList(yaml['roots']) ?? const ['lib', 'test'],
      exclude: _stringList(yaml['exclude']) ?? const ['.g.dart', '.freezed.dart'],
      builders: builders,
    );
  }

  static List<String>? _stringList(Object? value) =>
      value is YamlList ? [for (final v in value) '$v'] : null;

  static Map<String, Object?> _plain(YamlMap map) => {
    for (final entry in map.entries)
      '${entry.key}': switch (entry.value) {
        final YamlMap m => _plain(m),
        final YamlList l => [for (final v in l) v is YamlMap ? _plain(v) : v],
        final v => v,
      },
  };
}

class CraftConfigError implements Exception {
  CraftConfigError(this.message);

  final String message;

  @override
  String toString() => 'craft_runner: $message';
}
