import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

late Directory root;

String at(String path) => p.join(root.path, path);

void write(String path, String content) => File(at(path))
  ..parent.createSync(recursive: true)
  ..writeAsStringSync(content);

String? read(String path) {
  final file = File(at(path));
  return file.existsSync() ? file.readAsStringSync() : null;
}

/// Drives the builder the way craft_runner does: parse, then hand over the
/// project-relative path alongside the result.
void build(RiverpodCraftBuilder builder, String path) {
  builder.build(
    path,
    parseString(content: read(path)!, throwIfDiagnostics: false),
  );
}

RiverpodCraftBuilder builderWith({String? errorMapper, String? pagedMapper}) =>
    RiverpodCraftBuilder.withMappers(
      errorMapper: errorMapper == null ? null : at(errorMapper),
      pagedMapper: pagedMapper == null ? null : at(pagedMapper),
    );

void main() {
  setUp(() {
    root = Directory.systemTemp.createTempSync('riverpod_craft');
    // Builders write relative to the process cwd, as craft_runner runs them.
    Directory.current = root;
  });

  tearDown(() {
    Directory.current = Directory.systemTemp;
    root.deleteSync(recursive: true);
  });

  test('writes a part next to the provider it was generated from', () {
    write('lib/counter_provider.dart', '''
part 'counter_provider.craft.dart';

@provider
Future<int> counter(Ref ref) async => 0;
''');

    build(RiverpodCraftBuilder(), 'lib/counter_provider.dart');

    final output = read('lib/counter_provider.craft.dart');
    expect(output, isNotNull);
    expect(output, startsWith('// GENERATED CODE - DO NOT MODIFY BY HAND'));
    expect(output, contains("part of 'counter_provider.dart';"));
    expect(output, contains('counterProvider'));
  });

  test('a file with no craft annotation produces nothing', () {
    write('lib/plain_provider.dart', 'int counter() => 0;\n');

    build(RiverpodCraftBuilder(), 'lib/plain_provider.dart');

    expect(read('lib/plain_provider.craft.dart'), isNull);
  });

  test('a top-level @command generates without any @provider', () {
    write('lib/transfer_provider.dart', '''
part 'transfer_provider.craft.dart';

@command
Future<String> submitTransfer(Ref ref, {required double amount}) async => '';
''');

    build(RiverpodCraftBuilder(), 'lib/transfer_provider.dart');

    expect(read('lib/transfer_provider.craft.dart'), contains('submitTransfer'));
  });

  test('only *_provider.dart files are built', () {
    write('lib/counter.dart', '''
part 'counter.craft.dart';

@provider
Future<int> counter(Ref ref) async => 0;
''');

    build(RiverpodCraftBuilder(), 'lib/counter.dart');

    expect(read('lib/counter.craft.dart'), isNull);
  });

  test('a missing part directive throws, naming the line to add', () {
    write('lib/counter_provider.dart', '@provider\nint counter(Ref ref) => 0;\n');

    expect(
      () => build(RiverpodCraftBuilder(), 'lib/counter_provider.dart'),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('lib/counter_provider.dart'),
            contains("part 'counter_provider.craft.dart';"),
          ),
        ),
      ),
    );
  });

  test('every provider gets the mapper, not just the first', () {
    write('lib/error_mapper.dart',
        'Failure errorMapper(Object error) => Failure(error);\n');
    for (final name in ['one', 'two', 'three']) {
      write('lib/${name}_provider.dart', '''
part '${name}_provider.craft.dart';

@provider
Future<int> $name(Ref ref) async => 0;
''');
    }

    final builder = builderWith(errorMapper: 'lib/error_mapper.dart');
    for (final name in ['one', 'two', 'three']) {
      build(builder, 'lib/${name}_provider.dart');
    }

    for (final name in ['one', 'two', 'three']) {
      expect(
        read('lib/${name}_provider.craft.dart'),
        allOf(contains(r'_$errorMapper'), contains('Failure')),
        reason: name,
      );
    }
  });

  test('a missing mapper falls back instead of failing', () {
    write('lib/counter_provider.dart', '''
part 'counter_provider.craft.dart';

@provider
Future<int> counter(Ref ref) async => 0;
''');

    final builder = builderWith(errorMapper: 'lib/nope.dart');
    build(builder, 'lib/counter_provider.dart');

    final output = read('lib/counter_provider.craft.dart');
    expect(output, contains('Object'));
    expect(output, isNot(contains(r'_$errorMapper(')));
  });

  test('the error mapper is inlined from the configured file', () {
    write('lib/error_mapper.dart',
        'Failure errorMapper(Object error) => Failure(error);\n');
    write('lib/counter_provider.dart', '''
part 'counter_provider.craft.dart';

@provider
Future<int> counter(Ref ref) async => 0;
''');

    build(builderWith(errorMapper: 'lib/error_mapper.dart'),
        'lib/counter_provider.dart');

    expect(read('lib/counter_provider.craft.dart'), contains(r'_$errorMapper'));
  });

  test('fromConfig reads the mapper paths craft_runner passes', () {
    write('lib/error_mapper.dart',
        'Failure errorMapper(Object error) => Failure(error);\n');

    final builder = RiverpodCraftBuilder.fromConfig({
      'error_mapper': at('lib/error_mapper.dart'),
    });

    expect(builder.options.hasErrorMapper, isTrue);
    expect(builder.options.errorType, 'Failure');
    expect(builder.scope, ['lib']);
  });
}
