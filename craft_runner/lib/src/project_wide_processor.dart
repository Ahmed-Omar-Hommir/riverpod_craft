import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

import 'project_wide_plugin.dart';

/// Drives a full-project pass over the registered [ProjectWideCraftPlugin]s.
///
/// Walks every Dart file under the union of the plugins' [sourceRoots]
/// (default `lib/`, skipping generator outputs), feeds each parsed unit to the
/// plugins that requested its enclosing root via
/// [ProjectWideCraftPlugin.collectFromUnit], then writes each
/// `{path: contents}` entry returned by [ProjectWideCraftPlugin.generate]
/// after prepending the `GENERATED CODE` header and running `dart_style`.
///
/// Calls are de-duplicated by [runFullPass]: a second call while one is in
/// flight queues at most one follow-up pass, so a burst of file-change events
/// produces no more than one extra full scan.
class ProjectWideProcessor {
  ProjectWideProcessor(this._plugins);

  final List<ProjectWideCraftPlugin> _plugins;

  /// Parse cache, keyed by absolute file path, persisted across passes for the
  /// lifetime of the watch process. A full pass re-feeds every `lib/` unit to
  /// the plugins, but only files whose mtime+size changed are re-read and
  /// re-parsed — turning a steady-state pass from "parse all N files" into
  /// "parse the one file that changed". The analyzer parse dominates pass cost
  /// (≈250ms for ~300 files), so this is the difference between a sub-50ms
  /// incremental pass and a quarter-second one on every keystroke-save.
  final Map<String, _ParseCacheEntry> _parseCache = {};

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
    final roots = {for (final plugin in _plugins) ...plugin.sourceRoots};

    final sw = Stopwatch()..start();
    var parsedCount = 0;

    for (final plugin in _plugins) {
      plugin.reset();
    }

    final seen = <String>{};
    for (final root in roots) {
      final dir = Directory(p.join(rootDir, root));
      if (!dir.existsSync()) continue;

      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final path = entity.path;
        if (!path.endsWith('.dart')) continue;
        if (path.endsWith('.craft.dart') ||
            path.endsWith('.g.dart') ||
            path.endsWith('.freezed.dart')) {
          continue;
        }
        seen.add(path);

        // Reuse the cached parse when the file is byte-for-byte unchanged since
        // the last pass (mtime + size match). A FileStat is a single cheap
        // syscall; the analyzer parse it lets us skip is ~100x more expensive.
        final stat = entity.statSync();
        final cached = _parseCache[path];
        final ParseStringResult parsed;
        if (cached != null &&
            cached.modified == stat.modified &&
            cached.size == stat.size) {
          parsed = cached.result;
        } else {
          final String content;
          try {
            content = await entity.readAsString();
          } on FileSystemException {
            continue;
          }
          final result = parseString(
            content: content,
            throwIfDiagnostics: false,
          );
          _parseCache[path] = _ParseCacheEntry(stat.modified, stat.size, result);
          parsed = result;
          parsedCount++;
        }

        for (final plugin in _plugins) {
          if (!plugin.sourceRoots.contains(root)) continue;
          try {
            plugin.collectFromUnit(parsed, path);
          } catch (e) {
            print('Project-wide plugin "${plugin.id}" failed on $path: $e');
          }
        }
      }
    }

    // Drop cache entries for files deleted/renamed since the last pass so the
    // map can't grow unbounded over a long watch session.
    if (_parseCache.length != seen.length) {
      _parseCache.removeWhere((path, _) => !seen.contains(path));
    }

    // Split the timing so the log shows where a pass spends its time: the
    // scan+parse phase (cheap once the cache is warm) vs. generate+format+write.
    final scanMs = sw.elapsedMilliseconds;

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );

    var written = 0;
    var unchanged = 0;
    for (final plugin in _plugins) {
      Map<String, String> outputs;
      try {
        outputs = plugin.generate();
      } catch (e) {
        print('   ⚠️  ${plugin.id}: generate() failed: $e');
        continue;
      }
      for (final entry in outputs.entries) {
        final outPath = p.isAbsolute(entry.key)
            ? entry.key
            : p.join(rootDir, entry.key);
        // A plugin may emit its own `// GENERATED CODE` header (e.g. a `part of`
        // file needs a different header than a standalone library). Only add the
        // standard header when the content doesn't already carry one.
        final wrapped =
            entry.value.startsWith('// GENERATED CODE - DO NOT MODIFY BY HAND')
            ? entry.value
            : '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
                  '// ignore_for_file: directives_ordering,unnecessary_import,library_private_types_in_public_api\n'
                  '${entry.value}';
        String formatted;
        try {
          formatted = formatter.format(wrapped);
        } catch (e) {
          print('   ⚠️  ${plugin.id}: un-formattable output for $outPath: $e');
          formatted = wrapped;
        }
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        // Skip the write when output is byte-identical to what's on disk. This
        // makes a pass idempotent: an unchanged output produces no file-system
        // event, so a watch-triggered pass cannot re-trigger itself into a
        // loop, and editors/analyzers aren't churned by no-op rewrites.
        if (outFile.existsSync() && outFile.readAsStringSync() == formatted) {
          unchanged++;
          continue;
        }
        await outFile.writeAsString(formatted);
        written++;
        print('   🔧 ${p.relative(outPath, from: rootDir)}  ·  ${plugin.id}');
      }
    }

    final totalMs = sw.elapsedMilliseconds;
    final cached = seen.length - parsedCount;
    final outcome = written == 0
        ? 'no changes'
        : '$written written${unchanged > 0 ? ', $unchanged unchanged' : ''}';
    print(
      '⚡ project-wide · ${totalMs}ms '
      '(scan ${scanMs}ms · generate ${totalMs - scanMs}ms) · '
      '${seen.length} files: $parsedCount parsed, $cached cached · '
      '$outcome',
    );
  }
}

/// A cached analyzer parse plus the file fingerprint it was produced from.
/// [modified] + [size] are compared against a fresh `FileStat` to decide
/// whether the cached [result] is still valid.
class _ParseCacheEntry {
  _ParseCacheEntry(this.modified, this.size, this.result);

  final DateTime modified;
  final int size;
  final ParseStringResult result;
}
