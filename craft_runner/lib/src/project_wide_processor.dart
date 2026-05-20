import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

/// Drives a full-project pass over the registered [ProjectWideCraftPlugin]s.
///
/// Walks every Dart file under `lib/` (skipping generator outputs), invokes
/// each plugin's [ProjectWideCraftPlugin.collectFromUnit], then writes each
/// `{path: contents}` entry returned by [ProjectWideCraftPlugin.generate]
/// after prepending the `GENERATED CODE` header and running `dart_style`.
///
/// Calls are de-duplicated by [runFullPass]: a second call while one is in
/// flight queues at most one follow-up pass, so a burst of file-change events
/// produces no more than one extra full scan.
class ProjectWideProcessor {
  ProjectWideProcessor(this._plugins);

  final List<ProjectWideCraftPlugin> _plugins;

  bool _running = false;
  bool _queued = false;

  bool get hasPlugins => _plugins.isNotEmpty;

  /// Run a full pass. If already running, mark that another pass is needed
  /// and return immediately; the in-flight pass will re-run once on completion.
  Future<void> runFullPass(String rootDir) async {
    if (_plugins.isEmpty) return;
    if (_running) {
      _queued = true;
      return;
    }
    _running = true;
    try {
      do {
        _queued = false;
        await _runOnce(rootDir);
      } while (_queued);
    } finally {
      _running = false;
    }
  }

  Future<void> _runOnce(String rootDir) async {
    final libDir = Directory(p.join(rootDir, 'lib'));
    if (!libDir.existsSync()) return;

    for (final plugin in _plugins) {
      plugin.reset();
    }

    await for (final entity in libDir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final path = entity.path;
      if (!path.endsWith('.dart')) continue;
      if (path.endsWith('.craft.dart') ||
          path.endsWith('.g.dart') ||
          path.endsWith('.freezed.dart')) {
        continue;
      }
      final String content;
      try {
        content = await entity.readAsString();
      } on FileSystemException {
        continue;
      }
      final parsed = parseString(content: content, throwIfDiagnostics: false);
      for (final plugin in _plugins) {
        try {
          plugin.collectFromUnit(parsed, path);
        } catch (e) {
          print('Project-wide plugin "${plugin.id}" failed on $path: $e');
        }
      }
    }

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );

    for (final plugin in _plugins) {
      Map<String, String> outputs;
      try {
        outputs = plugin.generate();
      } catch (e) {
        print('Project-wide plugin "${plugin.id}" generate() failed: $e');
        continue;
      }
      for (final entry in outputs.entries) {
        final outPath = p.isAbsolute(entry.key)
            ? entry.key
            : p.join(rootDir, entry.key);
        final wrapped =
            '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
            '// ignore_for_file: directives_ordering,unnecessary_import,library_private_types_in_public_api\n'
            '${entry.value}';
        String formatted;
        try {
          formatted = formatter.format(wrapped);
        } catch (e) {
          print(
            'Project-wide plugin "${plugin.id}" produced un-formattable output for $outPath: $e',
          );
          formatted = wrapped;
        }
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsString(formatted);
        print('🔧 Generated ${p.relative(outPath, from: rootDir)}');
      }
    }
  }
}
