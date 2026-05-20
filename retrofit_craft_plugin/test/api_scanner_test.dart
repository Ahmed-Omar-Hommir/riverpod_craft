import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:retrofit_craft_plugin/retrofit_craft_plugin.dart';
import 'package:test/test.dart';

void main() {
  group('ApiScanner', () {
    test('collects enum Entry, enum Version, and @Api retrofit classes', () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
enum Entry {
  identity('https://identity.example.com/api/'),
  consumer('https://consumer.example.com/api/');
  const Entry(this.baseUrl);
  final String baseUrl;
}

enum Version { v1, v2, v3 }

@Api(entry: Entry.identity, version: Version.v1)
@RestApi()
abstract class AuthApiV1 {
  factory AuthApiV1(Dio dio, {String? baseUrl}) = _AuthApiV1;
}
''');

      scanner.collectFromUnit(parsed, '/test/source.dart');

      expect(scanner.entries.keys, contains('Entry'));
      expect(scanner.entries['Entry']!.values, ['identity', 'consumer']);
      expect(scanner.entries['Entry']!.filePath, '/test/source.dart');
      expect(scanner.versions.keys, contains('Version'));
      expect(scanner.versions['Version']!.values, ['v1', 'v2', 'v3']);

      final api = scanner.apiClasses.single;
      expect(api.className, 'AuthApiV1');
      expect(api.entry?.prefix, 'Entry');
      expect(api.entry?.name, 'identity');
      expect(api.version?.prefix, 'Version');
      expect(api.version?.name, 'v1');
    });

    test('@Api without version: leaves version null', () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
@Api(entry: Entry.identity)
abstract class HealthApi {}
''');
      scanner.collectFromUnit(parsed, '/test/health.dart');
      expect(scanner.apiClasses.single.version, isNull);
      expect(scanner.apiClasses.single.entry?.name, 'identity');
    });

    test('@Api with no args leaves both entry and version null', () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
@Api()
abstract class FreeApi {}
''');
      scanner.collectFromUnit(parsed, '/test/free.dart');
      expect(scanner.apiClasses.single.entry, isNull);
      expect(scanner.apiClasses.single.version, isNull);
    });

    test('class with static const fields acts as a registry', () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
class Entry {
  const Entry(this.baseUrl);
  final String baseUrl;
  static const Entry identity = Entry('https://identity...');
  static const Entry consumer = Entry('https://consumer...');
}
''');
      scanner.collectFromUnit(parsed, '/test/static.dart');
      expect(scanner.entries.keys, contains('Entry'));
      expect(scanner.entries['Entry']!.values, ['identity', 'consumer']);
    });

    test('reset() clears all accumulated state', () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
enum Entry { identity; const Entry(); }
enum Version { v1 }
@Api(entry: Entry.identity, version: Version.v1)
abstract class FooApi {}
''');
      scanner.collectFromUnit(parsed, '/test/source.dart');
      expect(scanner.apiClasses, isNotEmpty);
      scanner.reset();
      expect(scanner.entries, isEmpty);
      expect(scanner.versions, isEmpty);
      expect(scanner.apiClasses, isEmpty);
    });

    test('Version enum with a `path` String field sets hasPathField=true', () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
enum Version {
  v1('v1/'),
  v2('v2/');
  const Version(this.path);
  final String path;
}

enum Plain { a, b }
''');
      scanner.collectFromUnit(parsed, '/test/versions.dart');
      expect(scanner.versions['Version']?.hasPathField, isTrue);
      expect(scanner.versions['Plain']?.hasPathField, isFalse);
      // Symmetrically, the same enum scanned as an entry registry also sees
      // the field (we don't distinguish "this enum is an entry" vs "version"
      // at scan time — it's discovered into both maps).
      expect(scanner.entries['Version']?.hasPathField, isTrue);
    });

    test('hasPathField stays false when the field is the wrong type or name',
        () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
enum WrongType {
  v1(1);
  const WrongType(this.path);
  final int path;
}

enum WrongName {
  v1('v1/');
  const WrongName(this.url);
  final String url;
}

enum StaticOnly {
  v1, v2;
  static const String path = 'global/';
}
''');
      scanner.collectFromUnit(parsed, '/test/versions.dart');
      expect(scanner.versions['WrongType']?.hasPathField, isFalse);
      expect(scanner.versions['WrongName']?.hasPathField, isFalse);
      expect(scanner.versions['StaticOnly']?.hasPathField, isFalse);
    });

    test('dot-shorthand expressions are recorded with empty prefix', () {
      final scanner = ApiScanner();
      final parsed = parseString(content: '''
@Api(entry: .identity, version: .v1)
abstract class AuthApi {}
''');
      scanner.collectFromUnit(parsed, '/test/auth.dart');
      final api = scanner.apiClasses.single;
      expect(api.entry?.prefix, '');
      expect(api.entry?.name, 'identity');
      expect(api.version?.prefix, '');
      expect(api.version?.name, 'v1');
    });

    test('respects entryFilePath / versionFilePath scoping', () {
      final scanner = ApiScanner()
        ..entryFilePath = '/proj/entries.dart'
        ..versionFilePath = '/proj/versions.dart';

      scanner.collectFromUnit(
        parseString(content: 'enum Entry { identity; const Entry(); }'),
        '/proj/entries.dart',
      );
      scanner.collectFromUnit(
        parseString(content: 'enum NotAnEntry { foo }'),
        '/proj/unrelated.dart',
      );

      expect(scanner.entries.keys, ['Entry']);
      expect(scanner.entries.containsKey('NotAnEntry'), isFalse);
    });
  });

  group('naming helpers', () {
    test('stripVersionSuffix removes trailing V<digits>', () {
      expect(stripVersionSuffix('AuthApiV1'), 'AuthApi');
      expect(stripVersionSuffix('AuthApiV12'), 'AuthApi');
      expect(stripVersionSuffix('AuthApi'), 'AuthApi');
    });

    test('groupFieldName lowercases first char and strips Api suffix', () {
      expect(groupFieldName('AuthApiV1'), 'auth');
      expect(groupFieldName('AuthApi'), 'auth');
      expect(groupFieldName('OrderApi'), 'order');
      expect(groupFieldName('HealthApi'), 'health');
    });

    test('entryWrapperClassName + versionsWrapperClassName shapes', () {
      expect(entryWrapperClassName('identity'), '_IdentityEntry');
      expect(
        versionsWrapperClassName('identity', 'auth'),
        '_IdentityAuthVersions',
      );
    });
  });
}
