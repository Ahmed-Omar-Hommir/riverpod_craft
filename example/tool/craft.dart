import 'package:craft_runner/craft_runner.dart';
import '../lib/plugins/logging_provider_plugin.dart';

void main(List<String> args) {
  runWithPlugins([LoggingProviderPlugin()], args);
}
