import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';


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
  ProviderInfo? collect(DartElementInfo element, RiverpodCraftOptions options) {
    if (element is DartClassElement) {
      return collectClass(element.classInfo, options);
    } else if (element is DartFunctionElement) {
      return collectFunction(element.functionInfo, options);
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
  ProviderInfo? collectClass(DartClassInfo classInfo, RiverpodCraftOptions options) {
    if (!classInfo.hasAnnotation('provider')) return null;

    final createMethod = classInfo.findMethod('create');
    if (createMethod == null) return null;

    final pageParam = createMethod.params
        .where((p) => p.isPositional && p.name == 'page')
        .firstOrNull;
    final hasPageParam = pageParam != null;
    final providerType = getProviderType(createMethod.returnType, options, hasPageParam: hasPageParam);
    final dataType = extractGenericType(createMethod.returnType, isPaged: providerType == ProviderType.paged);
    final pageKeyType = pageParam?.type ?? 'int';

    // Create method params become family params
    var familyParams = createMethod.params
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

    // For paged providers, strip the positional `page` param
    // — it's managed internally by PagedDataNotifier
    if (providerType == ProviderType.paged) {
      familyParams = familyParams
          .where((p) => !(p.isPositional && p.name == 'page'))
          .toList();
    }

    final commands = extractCommands(classInfo, options);
    final publicMethods = extractPublicMethods(classInfo);

    // @settable is ignored on class-based providers
    return ProviderInfo(
      options: options,
      name: classInfo.name,
      dataType: dataType,
      isKeepAlive: classInfo.hasAnnotation('keepAlive'),
      isNoInit: classInfo.hasAnnotation('noInit'),
      type: providerType,
      params: familyParams,
      commands: commands,
      publicMethods: publicMethods,
      hasPagedMapper: providerType == ProviderType.paged && options.hasPagedMapper,
      pageKeyType: pageKeyType,
    );
  }

  // ---------------------------------------------------------------------------
  // Functional provider collection
  // ---------------------------------------------------------------------------

  /// Collects metadata from a functional `@provider`.
  /// Override to customize functional provider collection.
  ProviderInfo? collectFunction(DartFunctionInfo functionInfo, RiverpodCraftOptions options) {
    if (!functionInfo.hasAnnotation('provider')) return null;

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

    final pageParam = params
        .where((p) => p.isPositional && p.name == 'page')
        .firstOrNull;
    final hasPageParam = pageParam != null;
    final providerType = getProviderType(functionInfo.returnType, options, hasPageParam: hasPageParam);
    final dataType = extractGenericType(functionInfo.returnType, isPaged: providerType == ProviderType.paged);
    final pageKeyType = pageParam?.type ?? 'int';

    // For paged providers, strip the `page` param — managed internally
    if (providerType == ProviderType.paged && pageParam != null) {
      params.remove(pageParam);
    }

    final functionName = functionInfo.name;

    return ProviderInfo(
      options: options,
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
      isNoInit: functionInfo.hasAnnotation('noInit'),
      hasPagedMapper: providerType == ProviderType.paged && options.hasPagedMapper,
      publicMethods: const <PublicMethod>[],
      pageKeyType: pageKeyType,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts the generic type from `Future<T>`, `Stream<T>`, `Paged<T>`,
  /// `Future<PaginatedResponse<T>>`, or returns as-is.
  ///
  /// When [isPaged] is true (mapper mode), extracts the innermost generic:
  /// `Future<ApiPagedResponse<Note>>` → `Note`
  String extractGenericType(String returnType, {bool isPaged = false}) {
    // Paged<T> → T
    final pagedMatch = RegExp(r'^Paged<(.+)>$').firstMatch(returnType);
    if (pagedMatch != null) return pagedMatch.group(1)!;

    // Future<PaginatedResponse<T>> → T
    final paginatedMatch = RegExp(r'^Future<PaginatedResponse<(.+)>>\??$').firstMatch(returnType);
    if (paginatedMatch != null) return paginatedMatch.group(1)!;

    // With paged mapper: Future<Wrapper<T>> → T (extract innermost generic)
    if (isPaged) {
      final nestedMatch = RegExp(r'^Future<\w+<(.+)>>\??$').firstMatch(returnType);
      if (nestedMatch != null) return nestedMatch.group(1)!;
    }

    final futureMatch = RegExp(r'^Future<(.+)>\??$').firstMatch(returnType);
    if (futureMatch != null) return futureMatch.group(1)!;

    final streamMatch = RegExp(r'^Stream<(.+)>\??$').firstMatch(returnType);
    if (streamMatch != null) return streamMatch.group(1)!;

    return returnType == 'dynamic' ? 'dynamic' : returnType;
  }

  /// Determines ProviderType from a return type string.
  ///
  /// When [hasPageParam] is true and mapper is configured,
  /// `Future<Wrapper<T>>` with `int page` first param → paged.
  ProviderType getProviderType(
    String returnType,
    RiverpodCraftOptions options, {
    bool hasPageParam = false,
  }) {
    // Paged<T> or Future<PaginatedResponse<T>> → paged
    if (returnType.startsWith('Paged<') ||
        returnType.contains('PaginatedResponse<')) {
      return ProviderType.paged;
    }
    // With paged mapper: Future<Wrapper<T>> + int page param → paged
    if (hasPageParam && options.hasPagedMapper && returnType.startsWith('Future<')) {
      return ProviderType.paged;
    }
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
  List<Command> extractCommands(DartClassInfo classInfo, RiverpodCraftOptions options) {
    final commands = <Command>[];
    for (final method in classInfo.methodsWithAnnotation('command')) {
      if (!method.returnType.startsWith('Future<')) continue;

      commands.add(
        Command(
          options: options,
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
