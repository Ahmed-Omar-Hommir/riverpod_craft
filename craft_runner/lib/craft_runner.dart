/// Resident, incremental code-generation watcher.
///
/// ```dart
/// // tool/craft.dart
/// class MyBuilder extends CraftBuilderSingleFile {
///   @override
///   List<String> get scope => ['lib'];
///
///   @override
///   void build(String path, ParseStringResult result) {}
/// }
///
/// void main() => craft(builders: [MyBuilder()]);
/// ```
library;

import 'src/craft_builder.dart';
import 'src/runner.dart';

export 'src/craft_builder.dart';
export 'src/version.dart';
export 'src/runner.dart' show CraftRunner;

/// [args] selects the mode: `watch` stays resident, anything else builds once.
Future<void> craft({
  required List<CraftBuilder> builders,
  List<String> args = const [],
  List<String> roots = const ['lib', 'test'],
  List<String> exclude = const ['.craft.dart', '.g.dart', '.freezed.dart'],
  String? rootDir,
}) async {
  final runner = CraftRunner(
    builders: builders,
    roots: roots,
    exclude: exclude,
    rootDir: rootDir,
  );
  if (args.contains('watch')) return runner.run();
  runner.start();
}
