import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:craft_runner/src/project_wide_processor.dart';
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';
import 'package:test/test.dart';

/// Records, per pass, which file paths it was fed and whether each came with a
/// non-null parsed unit. Lets the test assert the processor still feeds every
/// `lib/` file on every pass (cache must be transparent to plugins).
class _RecordingPlugin implements ProjectWideCraftPlugin {
  final List<Set<String>> passes = [];
  Set<String> _current = {};

  @override
  String get id => 'recording';

  @override
  List<String> get sourceRoots => const ['lib'];

  @override
  void reset() {
    _current = {};
    passes.add(_current);
  }

  @override
  void collectFromUnit(ParseStringResult unit, String filePath) {
    _current.add(filePath);
  }

  @override
  Map<String, String> generate() => const {};
}

void main() {
  late Directory root;
  late Directory lib;

  setUp(() {
    root = Directory.systemTemp.createTempSync('craft_pwp_test');
    lib = Directory('${root.path}/lib')..createSync(recursive: true);
  });

  tearDown(() => root.deleteSync(recursive: true));

  File write(String name, String body) =>
      File('${lib.path}/$name')..writeAsStringSync(body);

  test('feeds every lib file on every pass (cache is transparent)', () async {
    write('a.dart', 'class A {}');
    write('b.dart', 'class B {}');
    final plugin = _RecordingPlugin();
    final proc = ProjectWideProcessor([plugin]);

    await proc.runFullPass(root.path);
    await proc.runFullPass(root.path);

    expect(plugin.passes, hasLength(2));
    for (final pass in plugin.passes) {
      expect(
        pass.map((p) => p.split(Platform.pathSeparator).last).toSet(),
        {'a.dart', 'b.dart'},
        reason: 'both files must be re-fed each pass even when cached',
      );
    }
  });

  test('reuses the exact same parse object for an unchanged file', () async {
    write('a.dart', 'class A {}');
    // A plugin that captures the unit identity it receives.
    final units = <ParseStringResult>[];
    final capture = _CapturePlugin(units);
    final proc = ProjectWideProcessor([capture]);

    await proc.runFullPass(root.path);
    await proc.runFullPass(root.path);

    expect(units, hasLength(2));
    expect(
      identical(units[0], units[1]),
      isTrue,
      reason: 'unchanged file must return the cached parse, not a fresh one',
    );
  });

  test('re-parses a file after its contents change', () async {
    final f = write('a.dart', 'class A {}');
    final units = <ParseStringResult>[];
    final proc = ProjectWideProcessor([_CapturePlugin(units)]);

    await proc.runFullPass(root.path);
    // Bump mtime forward so the stat fingerprint differs even on coarse clocks.
    final later = DateTime.now().add(const Duration(seconds: 2));
    f.writeAsStringSync('class A { int x = 1; }');
    f.setLastModifiedSync(later);
    await proc.runFullPass(root.path);

    expect(
      identical(units[0], units[1]),
      isFalse,
      reason: 'changed file must be re-parsed, not served from cache',
    );
  });
}

class _CapturePlugin implements ProjectWideCraftPlugin {
  _CapturePlugin(this.units);
  final List<ParseStringResult> units;

  @override
  String get id => 'capture';
  @override
  List<String> get sourceRoots => const ['lib'];
  @override
  void reset() {}
  @override
  void collectFromUnit(ParseStringResult unit, String filePath) =>
      units.add(unit);
  @override
  Map<String, String> generate() => const {};
}
