import 'dart:io';

import 'package:retrofit_craft_plugin/retrofit_craft_plugin.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('retrofit_craft_config_');
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  test('returns defaults when no config file exists', () {
    final config = RetrofitCraftConfig.load(tmp);
    expect(config.defaultEntry, isNull);
    expect(config.defaultVersion, isNull);
    expect(config.entryPath, isNull);
    expect(config.versionPath, isNull);
    expect(config.output, 'lib/app/app_api.craft.dart');
    expect(config.rootClassName, 'AppApi');
  });

  test('returns defaults when retrofit_craft section is missing', () {
    File('${tmp.path}/riverpod_craft.yaml').writeAsStringSync('''
plugins:
  - some_plugin
''');
    final config = RetrofitCraftConfig.load(tmp);
    expect(config.defaultEntry, isNull);
    expect(config.output, 'lib/app/app_api.craft.dart');
  });

  test('parses all fields from the retrofit_craft section', () {
    File('${tmp.path}/riverpod_craft.yaml').writeAsStringSync('''
retrofit_craft:
  default_entry: Identity
  default_version: V1
  entry_path: lib/app/api/entries.dart
  version_path: lib/app/api/versions.dart
  output: lib/generated/api.craft.dart
  root_class_name: MyAppApi
''');
    final config = RetrofitCraftConfig.load(tmp);
    expect(config.defaultEntry, 'Identity');
    expect(config.defaultVersion, 'V1');
    expect(config.entryPath, 'lib/app/api/entries.dart');
    expect(config.versionPath, 'lib/app/api/versions.dart');
    expect(config.output, 'lib/generated/api.craft.dart');
    expect(config.rootClassName, 'MyAppApi');
  });

  test('returns defaults on malformed YAML rather than throwing', () {
    File('${tmp.path}/riverpod_craft.yaml').writeAsStringSync(
      'retrofit_craft:\n  default_entry: [unbalanced\n',
    );
    final config = RetrofitCraftConfig.load(tmp);
    expect(config.defaultEntry, isNull);
  });
}
