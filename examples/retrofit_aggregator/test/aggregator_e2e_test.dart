@Timeout(Duration(minutes: 3))
library;

import 'dart:io';

import 'package:test/test.dart';

/// End-to-end: run the craft_runner CLI (with `RetrofitApiPlugin` registered
/// as a project-wide plugin) one-shot via the `generate` command on any
/// retrofit source file. Assert the aggregator is produced, contains the
/// expected nested structure, and compiles under `dart analyze`. Then run
/// `clean` and assert it's removed.
///
/// The retrofit `*.g.dart` files in the fixture are hand-written stand-ins
/// for `retrofit_generator` output, so this test doesn't run build_runner.
void main() {
  final root = Directory.current.path;
  final genFile = File('$root/lib/app/app_api.craft.dart');

  Future<ProcessResult> craft(List<String> args) => Process.run(
        'dart',
        ['run', 'tool/craft.dart', ...args],
        workingDirectory: root,
      );

  tearDownAll(() async {
    // Restore the generated file for downstream consumers (it's committed).
    if (!genFile.existsSync()) {
      await craft(['generate', 'lib/features/auth/auth_api_v1.dart']);
    }
  });

  test('generates the AppApi aggregator', () async {
    await craft(['clean']);
    expect(genFile.existsSync(), isFalse);

    // The plugin is project-wide, so it runs after any per-file `generate`.
    // We pass any retrofit source file as the trigger.
    final res = await craft(['generate', 'lib/features/auth/auth_api_v1.dart']);
    expect(res.exitCode, 0, reason: '${res.stdout}\n${res.stderr}');
    expect(genFile.existsSync(), isTrue);

    final src = genFile.readAsStringSync();
    expect(src, contains('// GENERATED CODE - DO NOT MODIFY BY HAND'));
    expect(src, contains('class AppApi {'));
    expect(src, contains('AppApi({required this.dio});'));
    expect(src, contains('late final identity = _IdentityEntry(dio);'));
    expect(src, contains('late final consumer = _ConsumerEntry(dio);'));
    expect(src, contains('class _IdentityEntry {'));
    expect(src, contains('class _IdentityAuthVersions {'));
    // Versioned wrappers concatenate `Version.<vN>.path` onto the entry's
    // baseUrl (the `Version` enum declares a `final String path` field).
    expect(
      src,
      contains(r"baseUrl: '${Entry.identity.baseUrl}${Version.v1.path}'"),
    );
    expect(
      src,
      contains(r"baseUrl: '${Entry.identity.baseUrl}${Version.v3.path}'"),
    );
    expect(
      src,
      contains(r"baseUrl: '${Entry.consumer.baseUrl}${Version.v2.path}'"),
    );
    // Unversioned path: health is exposed directly on _IdentityEntry with
    // the bare baseUrl — `Version.path` does not apply when there's no
    // version layer.
    expect(
      src,
      contains('late final health = HealthApi(_dio, baseUrl: Entry.identity.baseUrl);'),
    );
  });

  test('generated aggregator compiles (dart analyze lib)', () async {
    if (!genFile.existsSync()) {
      await craft(['generate', 'lib/features/auth/auth_api_v1.dart']);
    }
    final res = await Process.run(
      'dart',
      ['analyze', 'lib'],
      workingDirectory: root,
    );
    expect(
      res.exitCode,
      0,
      reason: 'analyze failed:\n${res.stdout}\n${res.stderr}',
    );
  });

  test('clean removes the generated aggregator', () async {
    if (!genFile.existsSync()) {
      await craft(['generate', 'lib/features/auth/auth_api_v1.dart']);
    }
    final res = await craft(['clean']);
    expect(res.exitCode, 0);
    expect(genFile.existsSync(), isFalse);
  });
}
