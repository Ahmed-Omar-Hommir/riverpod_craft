import 'package:riverpod_craft_cli/command_info.dart';
import 'package:riverpod_craft_cli/provider_info.dart';

class ProviderDataCollection {
  const ProviderDataCollection({
    required this.providers,
    required this.commands,
  });
  final List<ProviderInfo> providers;
  final List<Command> commands;

  String? build() {
    if (providers.isEmpty && commands.isEmpty) return null;
    final allVars = providers.map((p) => p.providerVarName).toSet().toList();
    final enriched = providers
        .map(
          (p) => ProviderInfo(
            name: p.name,
            dataType: p.dataType,
            isKeepAlive: p.isKeepAlive,
            type: p.type,
            params: p.params,
            commands: p.commands,
            isFunctional: p.isFunctional,
            functionName: p.functionName,
            requiresRef: p.requiresRef,
            isSettable: p.isSettable,
            allProviderVarNames: allVars,
            publicMethods: p.publicMethods,
          ),
        )
        .toList();

    return """
${enriched.map((provider) => provider.build()).join('\n')}
${commands.map((command) => command.build()).join('\n')}
""";
  }
}
