import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

import 'package:riverpod_craft_cli/command_info.dart';
import 'package:riverpod_craft_cli/concurrency_type.dart';
import 'package:riverpod_craft_cli/provider_info.dart';

/// Built-in plugin that handles `@provider` annotations.
///
/// Collects class-based and functional providers into [ProviderInfo],
/// then delegates code generation to [ProviderInfo.build()] which uses
/// the existing [ProviderCodeGenerator].
class ProviderPlugin extends RiverpodCraftPlugin<ProviderInfo> {
  @override
  String get id => 'provider';

  @override
  List<String> get annotations => ['provider'];

  @override
  ProviderInfo? collect(DartElementInfo element) {
    if (element is DartClassElement) {
      return collectClass(element.classInfo);
    } else if (element is DartFunctionElement) {
      return collectFunction(element.functionInfo);
    }
    return null;
  }

  @override
  String generate(ProviderInfo data) => data.build();

  // ---------------------------------------------------------------------------
  // Class-based provider collection
  // ---------------------------------------------------------------------------

  /// Collects metadata from a class-based `@provider`.
  /// Override to customize class-based provider collection.
  ProviderInfo? collectClass(DartClassInfo classInfo) {
    if (!classInfo.hasAnnotation('provider')) return null;

    final createMethod = classInfo.findMethod('create');
    if (createMethod == null) return null;

    final dataType = extractGenericType(createMethod.returnType);
    final providerType = getProviderType(createMethod.returnType);

    // Create method params become family params
    final familyParams = createMethod.params
        .map(
          (p) => ParameterInfo(
            name: p.name,
            type: p.type,
            isRequired: p.isRequired,
            defaultValue: p.defaultValue,
            isPositional: p.isPositional,
            isFamily: true,
          ),
        )
        .toList();

    final commands = extractCommands(classInfo);
    final publicMethods = extractPublicMethods(classInfo);

    // @settable is ignored on class-based providers
    return ProviderInfo(
      name: classInfo.name,
      dataType: dataType,
      isKeepAlive: classInfo.hasAnnotation('keepAlive'),
      type: providerType,
      params: familyParams,
      commands: commands,
      publicMethods: publicMethods,
    );
  }

  // ---------------------------------------------------------------------------
  // Functional provider collection
  // ---------------------------------------------------------------------------

  /// Collects metadata from a functional `@provider`.
  /// Override to customize functional provider collection.
  ProviderInfo? collectFunction(DartFunctionInfo functionInfo) {
    if (!functionInfo.hasAnnotation('provider')) return null;

    final providerType = getProviderType(functionInfo.returnType);
    final dataType = extractGenericType(functionInfo.returnType);

    var params = List<ParameterInfo>.from(functionInfo.params);

    // Check for Ref ref as first parameter
    bool requiresRef = false;
    final firstPositional = params.where((p) => p.isPositional).firstOrNull;
    if (firstPositional != null &&
        firstPositional.name == 'ref' &&
        firstPositional.type == 'Ref') {
      requiresRef = true;
      params.remove(firstPositional);
    }

    final functionName = functionInfo.name;

    return ProviderInfo(
      name: functionName[0].toUpperCase() + functionName.substring(1),
      dataType: dataType,
      isKeepAlive: functionInfo.hasAnnotation('keepAlive'),
      type: providerType,
      params: params,
      commands: const [],
      isFunctional: true,
      functionName: functionName,
      requiresRef: requiresRef,
      isSettable: functionInfo.hasAnnotation('settable'),
      publicMethods: const <PublicMethod>[],
    );
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

  /// Determines ProviderType (sync/future/stream) from a return type string.
  ProviderType getProviderType(String returnType) {
    if (returnType.startsWith('Future<')) return ProviderType.future;
    if (returnType.startsWith('Stream<')) return ProviderType.stream;
    return ProviderType.sync;
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

  /// Extracts `@command`-annotated methods from a class.
  /// Override to customize command extraction behavior.
  List<Command> extractCommands(DartClassInfo classInfo) {
    final commands = <Command>[];
    for (final method in classInfo.methodsWithAnnotation('command')) {
      if (!method.returnType.startsWith('Future<')) continue;

      commands.add(
        Command(
          name: method.name,
          params: method.params,
          concurrency: getConcurrencyType(method.annotations),
          dataType: extractGenericType(method.returnType),
          isKeepAlive: method.annotations.any((a) => a.name == 'keepAlive'),
        ),
      );
    }
    return commands;
  }

  /// Extracts public non-special methods from a class.
  /// Override to customize which methods appear in the facade.
  List<PublicMethod> extractPublicMethods(DartClassInfo classInfo) {
    final methods = <PublicMethod>[];
    for (final method in classInfo.methods) {
      final isPublic = !method.name.startsWith('_');
      final isSpecial = method.isGetter || method.isSetter || method.isOperator;
      final isCreate = method.name == 'create';
      final isStatic = method.isStatic;
      final isCommand = method.hasAnnotation('command');
      if (isPublic && !isSpecial && !isCreate && !isStatic && !isCommand) {
        methods.add(
          PublicMethod(
            name: method.name,
            returnType: method.returnType,
            params: method.params,
          ),
        );
      }
    }
    return methods;
  }
}
