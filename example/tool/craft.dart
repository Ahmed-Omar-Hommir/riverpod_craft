import 'package:riverpod_craft_cli/riverpod_craft_cli.dart';
import '../lib/plugins/logging_provider_plugin.dart';

void main(List<String> args) {
  runWithPlugins([LoggingProviderPlugin()], args);
}
