import 'package:retrofit_craft_plugin/retrofit_craft_plugin.dart';
import 'package:test/test.dart';

String _norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

EnumRegistry _entries({
  String name = 'Entry',
  String filePath = '/proj/lib/app/api/entries.dart',
  List<String> values = const ['identity', 'consumer'],
}) =>
    EnumRegistry(name: name, filePath: filePath, values: values);

EnumRegistry _versions({
  String name = 'Version',
  String filePath = '/proj/lib/app/api/versions.dart',
  List<String> values = const ['v1', 'v2', 'v3'],
}) =>
    EnumRegistry(name: name, filePath: filePath, values: values);

void main() {
  group('generateAppApi', () {
    test('emits root, entry wrapper, and version wrapper classes', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries()},
        versions: {'Version': _versions()},
        apiClasses: [
          ApiClassSpec(
            className: 'AuthApiV1',
            filePath: '/proj/lib/features/auth/auth_api_v1.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v1'),
          ),
          ApiClassSpec(
            className: 'AuthApiV3',
            filePath: '/proj/lib/features/auth/auth_api_v3.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v3'),
          ),
          ApiClassSpec(
            className: 'OrderApi',
            filePath: '/proj/lib/features/order/order_api.dart',
            entry: ApiRef(prefix: 'Entry', name: 'consumer'),
            version: ApiRef(prefix: 'Version', name: 'v2'),
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );

      expect(result.success, isTrue, reason: result.diagnostics.toString());
      final n = _norm(result.source!);

      expect(n, contains("import 'package:dio/dio.dart';"));
      expect(n, contains("import 'api/entries.dart';"));
      expect(n, contains("import '../features/auth/auth_api_v1.dart';"));
      expect(n, contains("import '../features/auth/auth_api_v3.dart';"));
      expect(n, contains("import '../features/order/order_api.dart';"));

      expect(n, contains('class AppApi { AppApi({required this.dio}); final Dio dio;'));
      expect(n, contains('late final consumer = _ConsumerEntry(dio);'));
      expect(n, contains('late final identity = _IdentityEntry(dio);'));

      expect(n, contains('class _IdentityEntry {'));
      expect(n, contains('late final auth = _IdentityAuthVersions(_dio);'));

      expect(n, contains('class _IdentityAuthVersions {'));
      expect(
        n,
        contains('late final v1 = AuthApiV1(_dio, baseUrl: Entry.identity.baseUrl);'),
      );
      expect(
        n,
        contains('late final v3 = AuthApiV3(_dio, baseUrl: Entry.identity.baseUrl);'),
      );

      expect(n, contains('class _ConsumerEntry {'));
      expect(n, contains('class _ConsumerOrderVersions {'));
      expect(
        n,
        contains('late final v2 = OrderApi(_dio, baseUrl: Entry.consumer.baseUrl);'),
      );
    });

    test('concatenates Version.path onto baseUrl when version has '
        'hasPathField=true', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: {
          'Version': EnumRegistry(
            name: 'Version',
            filePath: '/proj/lib/app/api/versions.dart',
            values: const ['v1', 'v2'],
            hasPathField: true,
          ),
        },
        apiClasses: [
          ApiClassSpec(
            className: 'AuthApiV1',
            filePath: '/proj/lib/features/auth/auth_api_v1.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v1'),
          ),
          ApiClassSpec(
            className: 'AuthApiV2',
            filePath: '/proj/lib/features/auth/auth_api_v2.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v2'),
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isTrue, reason: result.diagnostics.toString());
      final n = _norm(result.source!);
      expect(
        n,
        contains(
          r"late final v1 = AuthApiV1(_dio, baseUrl: '${Entry.identity.baseUrl}${Version.v1.path}');",
        ),
      );
      expect(
        n,
        contains(
          r"late final v2 = AuthApiV2(_dio, baseUrl: '${Entry.identity.baseUrl}${Version.v2.path}');",
        ),
      );
    });

    test('hasPathField=false (legacy) still emits the bare baseUrl', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: {'Version': _versions(values: const ['v1'])},
        apiClasses: [
          ApiClassSpec(
            className: 'AuthApiV1',
            filePath: '/proj/lib/features/auth/auth_api_v1.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v1'),
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isTrue, reason: result.diagnostics.toString());
      final n = _norm(result.source!);
      expect(
        n,
        contains(
          'late final v1 = AuthApiV1(_dio, baseUrl: Entry.identity.baseUrl);',
        ),
      );
      expect(n, isNot(contains('Version.v1.path')));
    });

    test('unversioned (no-version-layer) classes always use bare baseUrl, '
        'even if Version has a path field', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: {
          'Version': EnumRegistry(
            name: 'Version',
            filePath: '/proj/lib/app/api/versions.dart',
            values: const ['v1'],
            hasPathField: true,
          ),
        },
        apiClasses: [
          ApiClassSpec(
            className: 'HealthApi',
            filePath: '/proj/lib/features/health/health_api.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: null,
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isTrue, reason: result.diagnostics.toString());
      expect(
        result.source,
        contains('late final health = HealthApi(_dio, baseUrl: Entry.identity.baseUrl);'),
      );
      expect(result.source, isNot(contains('.path')));
    });

    test('unversioned class with no default emits direct field', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: const {},
        apiClasses: [
          ApiClassSpec(
            className: 'HealthApi',
            filePath: '/proj/lib/features/health/health_api.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: null,
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );

      expect(result.success, isTrue, reason: result.diagnostics.toString());
      final n = _norm(result.source!);
      expect(
        n,
        contains('late final health = HealthApi(_dio, baseUrl: Entry.identity.baseUrl);'),
      );
      expect(n, isNot(contains('Versions')));
    });

    test('applies default_entry when @Api omits entry', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(defaultEntry: 'Entry.identity'),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: {'Version': _versions(values: const ['v1'])},
        apiClasses: [
          ApiClassSpec(
            className: 'PingApi',
            filePath: '/proj/lib/features/ping/ping_api.dart',
            entry: null,
            version: ApiRef(prefix: 'Version', name: 'v1'),
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isTrue, reason: result.diagnostics.toString());
      expect(result.source, contains('late final identity = _IdentityEntry(dio);'));
    });

    test('default_entry / default_version accept bare names, dot-shorthand, '
        'and explicit prefixed form', () {
      for (final entryDefault in ['consumer', '.consumer', 'Entry.consumer']) {
        for (final versionDefault in ['v1', '.v1', 'Version.v1']) {
          final result = generateAppApi(
            config: RetrofitCraftConfig(
              defaultEntry: entryDefault,
              defaultVersion: versionDefault,
            ),
            entries: {'Entry': _entries()},
            versions: {'Version': _versions()},
            apiClasses: [
              ApiClassSpec(
                className: 'KycApi',
                filePath: '/proj/lib/features/kyc/kyc_api.dart',
                entry: null,
                version: null,
              ),
            ],
            outputAbsPath: '/proj/lib/app/app_api.craft.dart',
          );
          expect(
            result.success,
            isTrue,
            reason:
                'entryDefault=$entryDefault versionDefault=$versionDefault '
                'failed: ${result.diagnostics}',
          );
          expect(
            result.source,
            contains('late final consumer = _ConsumerEntry(dio);'),
          );
          expect(
            result.source,
            contains('late final v1 = KycApi(_dio, baseUrl: Entry.consumer.baseUrl);'),
          );
        }
      }
    });

    test('fails when entry is missing and no default is configured', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: const {},
        versions: const {},
        apiClasses: [
          ApiClassSpec(
            className: 'XApi',
            filePath: '/proj/lib/x.dart',
            entry: null,
            version: null,
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isFalse);
      expect(result.diagnostics.single, contains('no entry'));
    });

    test('fails when entry references an unknown registry', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: const {},
        versions: const {},
        apiClasses: [
          ApiClassSpec(
            className: 'XApi',
            filePath: '/proj/lib/x.dart',
            entry: ApiRef(prefix: 'Ghost', name: 'foo'),
            version: null,
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isFalse);
      expect(result.diagnostics.single, contains('no enum'));
    });

    test('fails when entry value is not declared in the registry', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: const {},
        apiClasses: [
          ApiClassSpec(
            className: 'XApi',
            filePath: '/proj/lib/x.dart',
            entry: ApiRef(prefix: 'Entry', name: 'ghost'),
            version: null,
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isFalse);
      expect(result.diagnostics.single, contains('does not declare a value'));
    });

    test('fails when versioned and unversioned classes share a group', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: {'Version': _versions(values: const ['v1'])},
        apiClasses: [
          ApiClassSpec(
            className: 'AuthApiV1',
            filePath: '/proj/lib/a.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v1'),
          ),
          ApiClassSpec(
            className: 'AuthApi',
            filePath: '/proj/lib/b.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: null,
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isFalse);
      expect(result.diagnostics.first, contains('both with and without a version'));
    });

    test('class-name collisions across files get unique import aliases', () {
      final result = generateAppApi(
        config: const RetrofitCraftConfig(),
        entries: {'Entry': _entries(values: const ['identity'])},
        versions: {'Version': _versions(values: const ['v1', 'v2'])},
        apiClasses: [
          ApiClassSpec(
            className: 'AuthApi',
            filePath: '/proj/lib/v1/auth.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v1'),
          ),
          ApiClassSpec(
            className: 'AuthApi',
            filePath: '/proj/lib/v2/auth.dart',
            entry: ApiRef(prefix: 'Entry', name: 'identity'),
            version: ApiRef(prefix: 'Version', name: 'v2'),
          ),
        ],
        outputAbsPath: '/proj/lib/app/app_api.craft.dart',
      );
      expect(result.success, isTrue, reason: result.diagnostics.toString());
      final src = result.source!;
      expect(src, contains("import '../v1/auth.dart' as _alias0;"));
      expect(src, contains("import '../v2/auth.dart' as _alias1;"));
      expect(src, contains('_alias0.AuthApi(_dio'));
      expect(src, contains('_alias1.AuthApi(_dio'));
    });
  });
}
