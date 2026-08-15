import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:craft_runner/craft_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class EchoBuilder extends CraftBuilderSingleFile {
  EchoBuilder(this.root);

  final String root;
  final List<String> calls = [];

  @override
  List<String> get scope => ['lib'];

  @override
  void build(String path, ParseStringResult result) {
    calls.add(path);
    if (!result.content.contains('@echo')) return;
    writeIfChanged(p.join(root, path.replaceFirst('.dart', '.echo')), 'echo\n');
  }
}

class IndexBuilder extends CraftBuilderMultiFile {
  IndexBuilder(this.root);

  final String root;
  int builds = 0;
  int filesSeen = 0;

  @override
  List<String> get scope => ['lib'];

  @override
  void build(Map<String, ParseStringResult> results) {
    builds++;
    filesSeen = results.length;
    final names = results.values
        .map((r) => RegExp(r'// class: (\w+)').firstMatch(r.content)?.group(1))
        .whereType<String>();
    writeIfChanged(p.join(root, 'lib/index.txt'), '${names.join(",")}\n');
  }
}

late Directory root;

String at(String path) => p.join(root.path, path);

void write(String path, String content) => File(at(path))
  ..parent.createSync(recursive: true)
  ..writeAsStringSync(content);

String read(String path) => File(at(path)).readAsStringSync();

CraftRunner runnerFor(List<CraftBuilder> builders) => CraftRunner(
  builders: builders,
  rootDir: root.path,
  roots: const ['lib', 'test'],
  log: (_) {},
);

void main() {
  setUp(() => root = Directory.systemTemp.createTempSync('craft_test'));
  tearDown(() => root.deleteSync(recursive: true));

  test('a single-file builder runs once per file in its scope', () {
    write('lib/a.dart', '// @echo\n');
    write('lib/b.dart', 'const b = 1;\n');
    write('test/c.dart', '// @echo\n');

    final echo = EchoBuilder(root.path);
    runnerFor([echo]).start();

    expect(read('lib/a.echo'), 'echo\n');
    expect(File(at('lib/b.echo')).existsSync(), isFalse);
    // scope is ['lib'], so test/ is never handed over.
    expect(echo.calls, ['lib/a.dart', 'lib/b.dart']);
  });

  test('a multi-file builder receives every file in scope at once', () {
    write('lib/a.dart', '// class: Alpha\n');
    write('lib/b.dart', '// class: Beta\n');

    final index = IndexBuilder(root.path);
    runnerFor([index]).start();

    expect(index.filesSeen, 2);
    expect(read('lib/index.txt'), 'Alpha,Beta\n');
  });

  test('editing a file rebuilds only that file for a single-file builder', () {
    write('lib/a.dart', '// @echo\n');
    write('lib/b.dart', '// @echo\n');

    final echo = EchoBuilder(root.path);
    final runner = runnerFor([echo])..start();
    echo.calls.clear();

    write('lib/a.dart', '// @echo edited\n');
    runner.rebuild(['lib/a.dart']);

    expect(echo.calls, ['lib/a.dart']);
  });

  test('a multi-file builder re-runs over cached files, not re-read ones', () {
    write('lib/a.dart', '// class: Alpha\n');
    write('lib/b.dart', '// class: Beta\n');

    final index = IndexBuilder(root.path);
    final runner = runnerFor([index])..start();
    expect(index.builds, 1);

    write('lib/a.dart', '// class: Gamma\n');
    runner.rebuild(['lib/a.dart']);

    expect(index.builds, 2);
    expect(index.filesSeen, 2);
    expect(read('lib/index.txt'), 'Gamma,Beta\n');
  });

  test('a deleted file drops out of a multi-file build', () {
    write('lib/a.dart', '// class: Alpha\n');
    write('lib/b.dart', '// class: Beta\n');

    final runner = runnerFor([IndexBuilder(root.path)])..start();
    File(at('lib/a.dart')).deleteSync();
    runner.rebuild(['lib/a.dart']);

    expect(read('lib/index.txt'), 'Beta\n');
  });

  test('an unchanged file rebuilds nothing', () {
    write('lib/a.dart', '// @echo\n');

    final echo = EchoBuilder(root.path);
    final runner = runnerFor([echo])..start();
    echo.calls.clear();

    // The watcher fired, but the bytes match what is cached.
    runner.rebuild(['lib/a.dart']);
    expect(echo.calls, isEmpty);
  });

  test('scope keeps a builder out of directories it did not ask for', () {
    write('test/a.dart', '// @echo\n');

    final echo = EchoBuilder(root.path);
    final runner = runnerFor([echo])..start();
    runner.rebuild(['test/a.dart']);

    expect(echo.calls, isEmpty);
  });

  test('excluded suffixes are never parsed', () {
    write('lib/a.dart', '// @echo\n');
    write('lib/a.g.dart', '// @echo\n');

    final echo = EchoBuilder(root.path);
    runnerFor([echo]).start();

    expect(echo.calls, ['lib/a.dart']);
  });

  test('writeIfChanged skips a write when the bytes already match', () {
    final path = at('lib/out.txt');
    expect(writeIfChanged(path, 'same\n'), isTrue);
    expect(writeIfChanged(path, 'same\n'), isFalse);
    expect(writeIfChanged(path, 'different\n'), isTrue);
  });

  test('a throwing builder is reported and skipped, not fatal', () {
    write('lib/a.dart', 'const a = 1;\n');

    final logs = <String>[];
    CraftRunner(
      builders: [_ExplodingBuilder()],
      rootDir: root.path,
      roots: const ['lib'],
      log: logs.add,
    ).start();

    expect(logs.join('\n'), contains('boom'));
  });
}

class _ExplodingBuilder extends CraftBuilderSingleFile {
  @override
  List<String> get scope => ['lib'];

  @override
  void build(String path, ParseStringResult result) =>
      throw StateError('boom');
}
