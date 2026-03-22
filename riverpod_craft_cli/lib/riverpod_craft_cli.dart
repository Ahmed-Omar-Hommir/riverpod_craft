/// Riverpod Craft CLI — code generation toolkit for Riverpod.
///
/// ## Extend a built-in plugin
///
/// ```dart
/// import 'package:riverpod_craft_cli/riverpod_craft_cli.dart';
///
/// class LoggingProviderPlugin extends ProviderPlugin {
///   @override
///   String get id => 'provider';
///
///   @override
///   String generate(ProviderInfo data) {
///     final base = super.generate(data);
///     return base + '// custom logging code';
///   }
/// }
/// ```
///
/// ## Run with custom plugins
///
/// Create `tool/craft.dart` in your project:
///
/// ```dart
/// import 'package:riverpod_craft_cli/riverpod_craft_cli.dart';
/// import '../lib/plugins/logging_provider_plugin.dart';
///
/// void main(List<String> args) {
///   runWithPlugins([LoggingProviderPlugin()], args);
/// }
/// ```
///
/// Then run: `dart run tool/craft.dart watch`

// Built-in plugins (extend these to customize code generation)
export 'src/plugins/provider_plugin.dart';
export 'src/plugins/command_plugin.dart';

// Data types used by plugins
export 'provider_info.dart';
export 'command_info.dart';
export 'concurrency_type.dart';
export 'parameter_info.dart';

// CLI entry points
export 'file_processor.dart' show FileProcessor;
export 'src/run_with_plugins.dart';

// Plugin interface (re-export from plugin package)
export 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';
