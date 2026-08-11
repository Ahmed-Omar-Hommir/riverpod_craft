/// craft_runner — a generic, build_runner-style orchestrator for AST-based
/// project-wide code generation plugins.
///
/// It knows nothing about any specific generator. Register generators (each a
/// [ProjectWideCraftPlugin]) via `craft_runner.yaml`'s `plugins:` list, or
/// programmatically with [runWithPlugins] from a custom `tool/craft.dart`.
///
/// ```dart
/// import 'package:craft_runner/craft_runner.dart';
/// import 'package:my_generator/my_generator.dart';
///
/// Future<void> main(List<String> args) =>
///     runWithPlugins([MyGeneratorPlugin()], args);
/// ```
library;

// The single plugin interface craft_runner drives.
export 'src/project_wide_plugin.dart';

// CLI entry points.
export 'file_processor.dart' show FileProcessor;
export 'src/run_with_plugins.dart';
