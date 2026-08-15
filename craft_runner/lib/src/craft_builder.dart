import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';

abstract class CraftBuilder {
  abstract final List<String> scope;
}

abstract class CraftBuilderSingleFile extends CraftBuilder {
  // `path` is separate because ParseStringResult drops the one parseString took.
  void build(String path, ParseStringResult result);
}

abstract class CraftBuilderMultiFile extends CraftBuilder {
  void build(Map<String, ParseStringResult> results);
}

/// Paths written this session, drained by the runner so a builder's own
/// output doesn't come back as a source change.
final Set<String> craftWrites = {};

/// Skipping an unchanged write is what stops output from waking the watcher.
bool writeIfChanged(String path, String content) {
  final file = File(path);
  if (file.existsSync() && file.readAsStringSync() == content) return false;
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
  craftWrites.add(path);
  return true;
}
