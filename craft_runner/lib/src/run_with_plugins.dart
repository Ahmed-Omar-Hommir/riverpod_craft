import '../file_processor.dart';
import 'cli.dart';
import 'project_wide_plugin.dart';

/// Runs the craft_runner CLI with the given project-wide plugins registered.
///
/// Create a `tool/craft.dart` in your project:
///
/// ```dart
/// import 'package:craft_runner/craft_runner.dart';
/// import 'package:my_generator/my_generator.dart';
///
/// void main(List<String> args) => runWithPlugins([MyGeneratorPlugin()], args);
/// ```
///
/// Then run: `dart run tool/craft.dart watch`
Future<void> runWithPlugins(
  List<ProjectWideCraftPlugin> plugins,
  List<String> args,
) async {
  if (plugins.isNotEmpty) {
    print('🌐 plugins · project-wide: ${plugins.map((p) => p.id).join(', ')}');
  }
  FileProcessor.registerProjectWidePlugins(plugins);
  await CraftRunnerCli.main(args);
}
