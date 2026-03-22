import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

import '../file_processor.dart';
import 'cli.dart';

/// Runs the Riverpod Craft CLI with custom plugins registered.
///
/// Create a `tool/craft.dart` file in your project:
///
/// ```dart
/// import 'package:riverpod_craft_cli/riverpod_craft_cli.dart';
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
Future<void> runWithPlugins(
  List<RiverpodCraftPlugin> plugins,
  List<String> args,
) async {
  if (plugins.isNotEmpty) {
    final ids = plugins.map((p) => p.id).join(', ');
    print('🔌 Registered ${plugins.length} custom plugin(s): $ids');
  }
  FileProcessor.registerPlugins(plugins);
  await RiverpodCraftCLI.main(args);
}
