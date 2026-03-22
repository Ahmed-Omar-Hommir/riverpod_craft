import 'package:riverpod_craft_cli/riverpod_craft_cli.dart';

/// Example: extends ProviderPlugin to add logState() to every facade.
class LoggingProviderPlugin extends ProviderPlugin {
  @override
  String get id => 'provider'; // same id → replaces built-in

  @override
  String generate(ProviderInfo data) {
    final base = super.generate(data);
    return base + _generateLogging(data);
  }

  String _generateLogging(ProviderInfo data) {
    return '''

extension \$${data.name}LoggingEx on ${data.facadeClassName}Ref {
  void logState() => print('[${data.name}] state: \${read()}');
}
''';
  }
}
