import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

import '../file_processor.dart';
import 'cli.dart';

/// Runs the Riverpod Craft CLI with custom plugins registered.
///
/// Create a `tool/craft.dart` file in your project:
///
/// ```dart
/// import 'package:craft_runner/craft_runner.dart';
/// import '../lib/plugins/my_plugin.dart';
///
/// void main(List<String> args) {
///   runWithPlugins([MyPlugin()], args);
/// }
/// ```
///
/// Then run: `dart run tool/craft.dart watch`
///
/// Plugins with the same [RiverpodCraftPlugin.id] as a built-in plugin
/// will **replace** the built-in. For example, a custom `ProviderPlugin`
/// subclass with `id => 'provider'` replaces the default provider plugin.
///
/// Pass [projectWidePlugins] for generators that aggregate across the whole
/// project and emit standalone output files (e.g. an `AppApi` aggregator
/// built from `@Api`-annotated retrofit classes scattered across the
/// codebase).
Future<void> runWithPlugins(
  List<RiverpodCraftPlugin> plugins,
  List<String> args, {
  List<ProjectWideCraftPlugin> projectWidePlugins = const [],
}) async {
  if (plugins.isNotEmpty) {
    print('🔌 plugins · per-file: ${plugins.map((p) => p.id).join(', ')}');
  }
  if (projectWidePlugins.isNotEmpty) {
    print(
      '🌐 plugins · project-wide: '
      '${projectWidePlugins.map((p) => p.id).join(', ')}',
    );
  }
  FileProcessor.registerPlugins(plugins);
  FileProcessor.registerProjectWidePlugins(projectWidePlugins);
  await RiverpodCraftCLI.main(args);
}
