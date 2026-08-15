import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as p;

class SourceCache {
  SourceCache({
    required this.rootDir,
    required this.roots,
    required this.exclude,
  });

  final String rootDir;
  final List<String> roots;
  final List<String> exclude;

  final Map<String, ParseStringResult> _files = {};

  int get length => _files.length;

  ParseStringResult? operator [](String path) => _files[path];

  Map<String, ParseStringResult> inScope(List<String> scope) {
    final keys = _files.keys.where((path) => covers(path, scope)).toList()
      ..sort();
    return {for (final key in keys) key: _files[key]!};
  }

  bool covers(String path, [List<String>? scope]) =>
      (scope ?? roots).any((r) => path == r || path.startsWith('$r/')) &&
      path.endsWith('.dart') &&
      !exclude.any(path.endsWith);

  List<String> loadAll() {
    _files.clear();
    for (final root in roots) {
      final directory = Directory(p.join(rootDir, root));
      if (!directory.existsSync()) continue;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File) continue;
        final path = _relative(entity.path);
        if (!covers(path)) continue;
        _files[path] = _parse(path, entity.readAsStringSync());
      }
    }
    return _files.keys.toList()..sort();
  }

  /// False when the bytes match what is cached, which is how a builder's own
  /// write stops here instead of causing a rebuild.
  bool refresh(String path) {
    final file = File(p.join(rootDir, path));
    if (!file.existsSync()) return _files.remove(path) != null;

    final content = file.readAsStringSync();
    if (_files[path]?.content == content) return false;
    _files[path] = _parse(path, content);
    return true;
  }

  ParseStringResult _parse(String path, String content) =>
      parseString(content: content, path: path, throwIfDiagnostics: false);

  String _relative(String absolute) =>
      p.relative(absolute, from: rootDir).replaceAll(r'\', '/');
}
