import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

import 'package:riverpod_craft_cli/command_info.dart';
import 'package:riverpod_craft_cli/concurrency_type.dart';

/// Built-in plugin that handles top-level `@command` functions.
///
/// Commands inside `@provider` classes are handled by [ProviderPlugin] instead.
/// This plugin only handles standalone `@command`-annotated top-level functions.
class CommandPlugin extends RiverpodCraftPlugin<List<Command>> {
  @override
  String get id => 'command';

  @override
  List<String> get annotations =>
      ['command', 'droppable', 'restartable', 'concurrent', 'sequential'];

  @override
  List<Command>? collect(DartElementInfo element) {
    // Only handle top-level functions, not classes.
    // Class-level @command methods are handled by ProviderPlugin.
    if (element is! DartFunctionElement) return null;

    final functionInfo = element.functionInfo;
    if (!functionInfo.hasAnnotation('command')) return null;

    // Only Future-returning functions are commands
    if (!functionInfo.returnType.startsWith('Future<')) return null;

    var params = List<ParameterInfo>.from(functionInfo.params);

    // Remove the first positional parameter if it is 'ref' of type 'Ref'
    final firstParam = params.where((p) => p.isPositional).firstOrNull;
    if (firstParam != null &&
        firstParam.name == 'ref' &&
        firstParam.type == 'Ref') {
      params.remove(firstParam);
    }

    final dataType = extractGenericType(functionInfo.returnType);

    return [
      Command(
        name: functionInfo.name,
        params: params,
        concurrency: getConcurrencyType(functionInfo.annotations),
        dataType: dataType,
        isKeepAlive:
            functionInfo.annotations.any((a) => a.name == 'keepAlive'),
      ),
    ];
  }

  @override
  String generate(List<Command> data) {
    return data.map((command) => command.build()).join('\n');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts the generic type from `Future<T>`, `Stream<T>`, or returns as-is.
  String extractGenericType(String returnType) {
    final futureMatch = RegExp(r'^Future<(.+)>\??$').firstMatch(returnType);
    if (futureMatch != null) return futureMatch.group(1)!;

    final streamMatch = RegExp(r'^Stream<(.+)>\??$').firstMatch(returnType);
    if (streamMatch != null) return streamMatch.group(1)!;

    return returnType == 'dynamic' ? 'dynamic' : returnType;
  }

  /// Maps annotation names to ConcurrencyType.
  ConcurrencyType getConcurrencyType(List<AnnotationInfo> annotations) {
    if (annotations.any((a) => a.name == 'droppable')) {
      return ConcurrencyType.droppable;
    }
    if (annotations.any((a) => a.name == 'restartable')) {
      return ConcurrencyType.restartable;
    }
    if (annotations.any((a) => a.name == 'concurrent')) {
      return ConcurrencyType.concurrent;
    }
    if (annotations.any((a) => a.name == 'sequential')) {
      return ConcurrencyType.sequential;
    }
    return ConcurrencyType.droppable;
  }
}
