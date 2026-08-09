import 'package:craft_runner/parameters_converter.dart';
import 'package:craft_runner/provider_info.dart';
import 'package:craft_runner/src/plugin_loader.dart';

/// The `mapError` override emitted into generated notifiers when a global
/// `error_mapper` is configured. Routes every caught error through the inlined
/// (privately renamed) `errorMapper` function. Empty when no mapper is
/// configured.
String get mapErrorOverride => CraftConfig.hasErrorMapper
    ? '\n  @override\n  ${CraftConfig.errorType} mapError(Object error) => ${CraftConfig.errorMapperInlineName}(error);\n'
    : '';

class ProviderCodeGenerator {
  final ProviderInfo _info;

  const ProviderCodeGenerator(this._info);

  String generate() {
    final familyParams = _info.params.where((p) => p.isFamily).toList();
    final nonFamilyParams = _info.params.where((p) => !p.isFamily).toList();
    final hasFamily = familyParams.isNotEmpty;
    final familyRecordType = familyParams.isEmpty
        ? '()'
        : '({${familyParams.map((p) => '${p.type} ${p.name}').join(', ')}})';
    final nonFamilyRecordType = nonFamilyParams.isEmpty
        ? '()'
        : '({${nonFamilyParams.map((p) => '${p.type} ${p.name}').join(', ')}})';
    // Only non-family params are controller args; family params key the provider
    final argType = nonFamilyParams.isNotEmpty ? ', $nonFamilyRecordType' : '';
    final paramSig = nonFamilyParams.toParameterSignature();
    final recordArg = nonFamilyParams.isNotEmpty
        ? '$nonFamilyRecordType arg'
        : '';
    final callArgs = nonFamilyParams.isNotEmpty
        ? nonFamilyParams.fromRecordToFunctionCall()
        : '';
    final nonFamilyCallArgs = nonFamilyParams.isEmpty
        ? ''
        : nonFamilyParams.map((p) => 'arg.${p.name}').join(', ');
    final familyCallArgs = familyParams.isNotEmpty
        ? familyParams.fromRecordToFunctionCall()
        : '';
    final controllerType = _controllerType();

    if (_info.isFunctional) {
      return '''
    ${_buildProvider(hasFamily: hasFamily, familyRecordType: familyRecordType, nonFamilyRecordType: nonFamilyRecordType, familyCallArgs: familyCallArgs)}

${_buildFunctionalNotifierClass(controllerType, argType, recordArg, callArgs, hasFamily: hasFamily, nonFamilyRecordType: nonFamilyRecordType, nonFamilyCallArgs: nonFamilyCallArgs)}

${_buildRefFacadeClass()}

${_buildDataProviderFacadeClass()}

${_buildExtensions()}
''';
    }

    return '''
${_buildAbstractClass(controllerType, argType, paramSig, recordArg, callArgs, familyRecordType: familyRecordType)}

  ${_buildProvider(hasFamily: hasFamily, familyRecordType: familyRecordType, nonFamilyRecordType: nonFamilyRecordType, familyCallArgs: familyCallArgs)}

${_buildRefFacadeClass()}

${_buildDataProviderFacadeClass()}

${_info.commands.map((c) => c.builder(parent: _info).buildCommandClassInsideParent()).join('\n')}

${_info.commands.map((c) => c.builder(parent: _info).buildFacadeCommandClassRef()).join('\n')}

${_info.commands.map((c) => c.builder(parent: _info).buildFacadeCommandClassWidgetRef()).join('\n')}

${_buildExtensions()}
''';
  }

  String _buildAbstractClass(
    String controllerType,
    String argType,
    String paramSig,
    String recordArg,
    String callArgs, {
    String familyRecordType = '()',
  }) {
    // For class-based providers, family params are the Arg type
    final familyParams = _info.params.where((p) => p.isFamily).toList();
    final classArgType = familyParams.isNotEmpty
        ? '({${familyParams.map((p) => '${p.type} ${p.name}').join(', ')}})'
        : '()';

    // Create method signature with family params - respecting positional vs named
    final createParamSig = familyParams.toParameterSignature();
    // Call args from arg record: arg.field1, arg.field2, ... respecting named params
    final createCallArgs = familyParams.fromRecordToFunctionCall();

    // `@noInit` opts the notifier out of the global providerInit hook.
    final noInitOverride = _info.isNoInit
        ? '\n  @override\n  Future<void> init() async {}\n'
        : '';

    // For PagedDataNotifier: buildPagedData(int page) delegates to create(page, ...familyParams...)
    if (_info.type == ProviderType.paged) {
      final pk = _info.pageKeyType;
      final pagedCreateCall = familyParams.isEmpty ? '' : ', ${createCallArgs}';
      final buildPagedLine = _info.hasPagedMapper
          ? 'Future<PaginatedResponse<${_info.dataType}, $pk>> buildPagedData($pk page) async => pagedMapper(await create(page$pagedCreateCall));'
          : 'Future<PaginatedResponse<${_info.dataType}, $pk>> buildPagedData($pk page) => create(page$pagedCreateCall);';
      final firstPageKeyBlock = _info.firstPageKey == null
          ? ''
          : '  @override\n  final $pk firstPageKey = ${_info.firstPageKey};\n\n';
      return '''
abstract class _\$${_info.name} extends $controllerType<${_info.dataType}, ${_info.errorType}, $classArgType, $pk> {
$firstPageKeyBlock  Paged<${_info.dataType}> create($pk page${familyParams.isEmpty ? '' : ', $createParamSig'});
  @override
  $buildPagedLine
$mapErrorOverride$noInitOverride
${_info.commands.map((c) => c.builder(parent: _info).buildCommandInsideParent()).join('\n')}
}''';
    }

    // For DataNotifier (Future/Stream): use isFuture getter and buildDataWithFuture()/buildDataWithStream()
    if (_info.type == ProviderType.future ||
        _info.type == ProviderType.stream) {
      final dataCreateCall = familyParams.isEmpty ? '' : createCallArgs;
      final isFuture = _info.type == ProviderType.future;
      final buildMethodName = isFuture
          ? 'buildDataWithFuture'
          : 'buildDataWithStream';
      return '''
abstract class _\$${_info.name} extends $controllerType<${_info.dataType}, ${_info.errorType}, $classArgType> {
  @override
  bool get isFuture => $isFuture;

  ${_info.returnName} create($createParamSig);
  @override
  ${_info.returnName} $buildMethodName() => create($dataCreateCall);
$mapErrorOverride$noInitOverride
${_info.commands.map((c) => c.builder(parent: _info).buildCommandInsideParent()).join('\n')}
}''';
    }

    // For StateDataNotifier (sync providers) - use same pattern as Future/Stream
    final syncCreateCall = familyParams.isEmpty ? '' : createCallArgs;
    return '''
abstract class _\$${_info.name} extends $controllerType<${_info.dataType}, $classArgType> {
  ${_info.returnName} create($createParamSig);
  @override
  ${_info.returnName} buildData($classArgType arg) => create($syncCreateCall);

${_info.commands.map((c) => c.builder(parent: _info).buildCommandInsideParent()).join('\n')}
}''';
  }

  String _buildProvider({
    bool hasFamily = false,
    String familyRecordType = '()',
    String nonFamilyRecordType = '()',
    String familyCallArgs = '',
  }) {
    final className = _info.isFunctional ? _info.notifierType : _info.name;
    final isFamilyProvider = _info.params.isNotEmpty;
    final autoDisposeArg = _info.isKeepAlive ? '' : ', isAutoDispose: true';

    if (!isFamilyProvider) {
      return 'final _${_info.providerVarName} = NotifierProvider<$className, ${_info.stateType}>(() => $className()..arg = ()$autoDisposeArg);';
    }

    final argRecordType = hasFamily ? familyRecordType : nonFamilyRecordType;
    final ctor = '($argRecordType arg) => $className()..arg = arg';
    return 'final _${_info.providerVarName} = NotifierProvider.family<$className, ${_info.stateType}, $argRecordType>($ctor$autoDisposeArg);';
  }

  String _buildFunctionalNotifierClass(
    String controllerType,
    String argType,
    String recordArg,
    String callArgs, {
    bool hasFamily = false,
    String nonFamilyRecordType = '()',
    String nonFamilyCallArgs = '',
  }) {
    // Build function call - use arg.fieldName for family params (respecting positional/named)
    final pieces = <String>[];
    if (_info.requiresRef) pieces.add('ref');

    // Add arg.fieldName for each family param using fromRecordToFunctionCall
    final paramsCall = _info.params.fromRecordToFunctionCall();
    if (paramsCall.isNotEmpty) {
      pieces.add(paramsCall);
    }

    final functionCall = '${_info.functionName}(${pieces.join(', ')})';

    // `@noInit` opts the notifier out of the global providerInit hook.
    final noInitOverride = _info.isNoInit
        ? '\n  @override\n  Future<void> init() async {}\n'
        : '';

    // For PagedDataNotifier (paged): buildPagedData(int page) delegates to function(ref, page, ...args)
    if (_info.type == ProviderType.paged) {
      final dataArgType = _info.params.isNotEmpty ? nonFamilyRecordType : '()';
      // Build the paged function call — inject `page` as first arg after ref
      final pagedPieces = <String>[];
      if (_info.requiresRef) pagedPieces.add('ref');
      pagedPieces.add('page');
      final paramsCallPaged = _info.params.fromRecordToFunctionCall();
      if (paramsCallPaged.isNotEmpty) pagedPieces.add(paramsCallPaged);
      final pagedFunctionCall =
          '${_info.functionName}(${pagedPieces.join(', ')})';

      final pk = _info.pageKeyType;
      final functionalBuildLine = _info.hasPagedMapper
          ? 'Future<PaginatedResponse<${_info.dataType}, $pk>> buildPagedData($pk page) async => pagedMapper(await $pagedFunctionCall);'
          : 'Future<PaginatedResponse<${_info.dataType}, $pk>> buildPagedData($pk page) => $pagedFunctionCall;';
      final firstPageKeyBlock = _info.firstPageKey == null
          ? ''
          : '  @override\n  final $pk firstPageKey = ${_info.firstPageKey};\n\n';
      return '''
class ${_info.notifierType} extends $controllerType<${_info.dataType}, ${_info.errorType}, $dataArgType, $pk> {
$firstPageKeyBlock  @override
  $functionalBuildLine
$mapErrorOverride$noInitOverride}''';
    }

    // For DataNotifier (Future/Stream): use isFuture getter and buildDataWithFuture()/buildDataWithStream()
    if (_info.type == ProviderType.future ||
        _info.type == ProviderType.stream) {
      final dataArgType = _info.params.isNotEmpty ? nonFamilyRecordType : '()';
      final isFuture = _info.type == ProviderType.future;
      final buildMethodName = isFuture
          ? 'buildDataWithFuture'
          : 'buildDataWithStream';
      return '''
class ${_info.notifierType} extends $controllerType<${_info.dataType}, ${_info.errorType}, $dataArgType> {
  @override
  bool get isFuture => $isFuture;

  @override
  ${_info.returnName} $buildMethodName() => $functionCall;
$mapErrorOverride$noInitOverride}''';
    }

    // For StateDataNotifier (sync providers) - use same pattern as Future/Stream
    final syncArgType = _info.params.isNotEmpty ? nonFamilyRecordType : '()';
    return '''
class ${_info.notifierType} extends $controllerType<${_info.dataType}, $syncArgType> {
  @override
  ${_info.returnName} buildData($syncArgType arg) => $functionCall;
}''';
  }

  String _refFacadeClassName() => '${_info.facadeClassName}Ref';
  String _widgetFacadeClassName() => '${_info.facadeClassName}Widget';

  /// Builds command getters/methods for Ref facade
  String _buildCommandGettersRef() {
    return _info.commands
        .map((c) {
          final builder = c.builder(parent: _info);
          if (c.hasFamily) {
            // Family command: return a method that takes family params
            return '${builder.facadeCommandClassNameRef} ${c.publicName}Command(${c.familyParams.toParameterSignature()}) => ${builder.facadeCommandClassNameRef}(_ref, _ref.read(_provider.notifier), ${c.familyParams.toRecordValue()});';
          } else {
            // Non-family command: return a getter
            return '${builder.facadeCommandClassNameRef} get ${c.publicName}Command => ${builder.facadeCommandClassNameRef}(_ref, _ref.read(_provider.notifier));';
          }
        })
        .join('\n');
  }

  /// Builds command getters/methods for WidgetRef facade
  String _buildCommandGettersWidgetRef() {
    return _info.commands
        .map((c) {
          final builder = c.builder(parent: _info);
          if (c.hasFamily) {
            // Family command: return a method that takes family params
            return '${builder.facadeCommandClassNameWidgetRef} ${c.publicName}Command(${c.familyParams.toParameterSignature()}) => ${builder.facadeCommandClassNameWidgetRef}(_ref, _ref.read(_provider.notifier), ${c.familyParams.toRecordValue()});';
          } else {
            // Non-family command: return a getter
            return '${builder.facadeCommandClassNameWidgetRef} get ${c.publicName}Command => ${builder.facadeCommandClassNameWidgetRef}(_ref, _ref.read(_provider.notifier));';
          }
        })
        .join('\n');
  }

  String _buildRefFacadeClass() {
    final commandsGetters = _buildCommandGettersRef();

    // Add setState for sync providers only with @settable
    final hasSetState = _info.type == ProviderType.sync && _info.isSettable;
    final setStateMethod = hasSetState
        ? 'void setState(${_info.dataType} value) => _ref.read(_provider.notifier).state = value;'
        : '';

    // Paged providers get fetchNextPage() and reload()
    final pagedMethods = _info.type == ProviderType.paged
        ? '''
  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();
  Future<void> reload() => _ref.read(_provider.notifier).reload();
  Future<void> retry() => _ref.read(_provider.notifier).retry();'''
        : '';

    // Future providers get a `future` accessor: `.read()` (one-shot),
    // `.watch()` (reactive), and `.select(...)` to await a derived value.
    final futureMethod = _info.type == ProviderType.future
        ? '''DataFuture<${_info.dataType}, ${_info.errorType}> get future => DataFuture(
    DataWatchHandle<${_info.dataType}, ${_info.errorType}>(
      read: () => _ref.read(_provider),
      reload: () => _ref.read(_provider.notifier).reload(),
      listen: (listener) => _ref.listen(_provider, listener),
      invalidateSelf: () => _ref.invalidateSelf(),
    ),
    (forceRefetch) =>
        _ref.read(_provider.notifier).future(forceRefetch: forceRefetch),
  );'''
        : '';

    return '''
class ${_refFacadeClassName()} {
  ${_refFacadeClassName()}(this._ref${_info.hasArg ? ', this._arg' : ''});
  final Ref _ref;
  ${_info.hasArg ? 'final ${_info.params.toRecordType()} _arg;' : ''}

  late final _provider = _${_info.providerVarName}${_info.hasArg ? '(_arg)' : ''};

  ${_info.stateType} read() => _ref.read(_provider);
  ${_info.stateType} watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(${_info.stateType} state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  $futureMethod
  $setStateMethod
  $pagedMethods

  void listen(
    void Function(${_info.nullableStateType} previous, ${_info.stateType} next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<${_info.stateType}>(_provider, listener, onError: onError);
  }

  $commandsGetters
  ${_buildPublicMethods()}
}''';
  }

  String _buildWidgetRefFacadeClass() {
    final commandsGetters = _buildCommandGettersWidgetRef();

    // Add setState for sync providers only with @settable
    final hasSetState = _info.type == ProviderType.sync && _info.isSettable;
    final setStateMethod = hasSetState
        ? 'void setState(${_info.dataType} value) => _ref.read(_provider.notifier).state = value;'
        : '';

    return '''
class ${_widgetFacadeClassName()} {
  ${_widgetFacadeClassName()}(this._ref${_info.hasArg ? ', this._arg' : ''});
  final WidgetRef _ref;
  ${_info.hasArg ? 'final ${_info.params.toRecordType()} _arg;' : ''}

  late final _provider = _${_info.providerVarName}${_info.hasArg ? '(_arg)' : ''};

  ${_info.stateType} read() => _ref.read(_provider);
  ${_info.stateType} watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(R Function(${_info.stateType} state) selector) =>
      SelectedWidgetRefFacade(_ref, _provider.select(selector));

  $setStateMethod

  void listen(
    void Function(${_info.nullableStateType} previous, ${_info.stateType} next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<${_info.stateType}>(_provider, listener, onError: onError);
  }

  $commandsGetters
  ${_buildPublicMethods()}
}''';
  }

  String _buildExtensions() {
    if (!_info.hasArg) {
      return '''
extension ${_info.name}FacadeRefEx on Ref {
  ${_refFacadeClassName()} get ${_info.providerVarName} =>
      ${_refFacadeClassName()}(this);
}

extension ${_info.name}FacadeWidgetRefEx on WidgetRef {
  ${_widgetFacadeClassName()} get ${_info.providerVarName} =>
      ${_widgetFacadeClassName()}(this);
}''';
    } else {
      // For family providers, use callable class pattern
      return '''
class ${_refFacadeClassName()}Callable {
  ${_refFacadeClassName()}Callable(this._ref);
  final Ref _ref;

  ${_refFacadeClassName()} call(${_info.params.toParameterSignature()}) =>
      ${_refFacadeClassName()}(_ref, ${_info.params.toRecordValue()});

  void invalidateFamily() => _ref.invalidate(_${_info.providerVarName});
}

class ${_widgetFacadeClassName()}Callable {
  ${_widgetFacadeClassName()}Callable(this._ref);
  final WidgetRef _ref;

  ${_widgetFacadeClassName()} call(${_info.params.toParameterSignature()}) =>
      ${_widgetFacadeClassName()}(_ref, ${_info.params.toRecordValue()});

  void invalidateFamily() => _ref.invalidate(_${_info.providerVarName});
}

extension ${_info.name}FacadeRefEx on Ref {
  ${_refFacadeClassName()}Callable get ${_info.providerVarName} =>
      ${_refFacadeClassName()}Callable(this);
}

extension ${_info.name}FacadeWidgetRefEx on WidgetRef {
  ${_widgetFacadeClassName()}Callable get ${_info.providerVarName} =>
      ${_widgetFacadeClassName()}Callable(this);
}''';
    }
  }

  String _controllerType() {
    switch (_info.type) {
      case ProviderType.future:
      case ProviderType.stream:
        return 'DataNotifier';
      case ProviderType.sync:
        return 'StateDataNotifier';
      case ProviderType.paged:
        return 'PagedDataNotifier';
    }
  }

  /// Builds the DataProviderFacade class for Data Providers
  String _buildDataProviderFacadeClass() {
    final asyncMethods = _info.type == ProviderType.paged
        ? '''
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();

  Future<void> reload() => _ref.read(_provider.notifier).reload();

  Future<void> retry() => _ref.read(_provider.notifier).retry();'''
        : _info.type == ProviderType.sync
        ? '''
  @override
  void invalidate() => _ref.invalidate(_provider);'''
        : '''
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() =>
      _ref.watch(_provider.notifier).silentReload();''';

    // Add setState for sync providers only with @settable
    final setStateMethod = _info.type == ProviderType.sync && _info.isSettable
        ? 'void setState(${_info.dataType} value) => _ref.read(_provider.notifier).state = value;'
        : '';

    final argRecordTypeForData = _info.params.isEmpty
        ? '()'
        : _info.params.toRecordType();
    final implementsClause = _info.type == ProviderType.paged
        ? ' implements PagedProviderFacade<${_info.dataType}, ${_info.errorType}, ${_info.pageKeyType}>, PagedProviderValue<${_info.dataType}, ${_info.errorType}, ${_info.pageKeyType}>'
        : _info.type == ProviderType.sync
        ? ' implements ProviderFacade<${_info.dataType}>, ProviderValue<${_info.dataType}>'
        : ' implements DataProviderFacade<${_info.dataType}, ${_info.errorType}>, DataProviderValue<${_info.dataType}, ${_info.errorType}>';

    final overrideAnnotations = _info.type == ProviderType.paged
        ? ''
        : '@override\n  ';

    final ofMethodArg = _info.hasArg ? ', _arg' : '';
    final ofMethod = _info.type == ProviderType.paged
        ? '''
  @override
  PagedProviderFacade<${_info.dataType}, ${_info.errorType}, ${_info.pageKeyType}> of(WidgetRef ref) =>
      ${_info.facadeClassName}Widget(ref$ofMethodArg);'''
        : _info.type == ProviderType.sync
        ? '''
  @override
  ProviderFacade<${_info.dataType}> of(WidgetRef ref) =>
      ${_info.facadeClassName}Widget(ref$ofMethodArg);'''
        : '''
  @override
  DataProviderFacade<${_info.dataType}, ${_info.errorType}> of(WidgetRef ref) =>
      ${_info.facadeClassName}Widget(ref$ofMethodArg);''';

    final commandsGetters = _buildCommandGettersWidgetRef();

    return '''
class ${_info.facadeClassName}Widget$implementsClause {
  ${_info.facadeClassName}Widget(this._ref${_info.hasArg ? ', this._arg' : ''});
  final WidgetRef _ref;
  ${_info.hasArg ? 'final ${_info.params.toRecordType()} _arg;' : ''}

  late final _provider = _${_info.providerVarName}${_info.hasArg ? '(_arg)' : ''};

  ${_info.type != ProviderType.paged ? '@override\n  ' : ''}${_info.stateType} read() => _ref.read(_provider);
  ${_info.type != ProviderType.paged ? '@override\n  ' : ''}${_info.stateType} watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(R Function(${_info.stateType} state) selector) =>
      SelectedWidgetRefFacade(_ref, _provider.select(selector));
$asyncMethods

  $setStateMethod

  ${overrideAnnotations}void listen(
    void Function(${_info.nullableStateType} previous, ${_info.stateType} next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<${_info.stateType}>(_provider, listener, onError: onError);
  }
$ofMethod

  $commandsGetters
  ${_buildPublicMethods()}
}''';
  }

  String _buildPublicMethods() {
    if (_info.publicMethods.isEmpty) return '';

    return _info.publicMethods
        .map(
          (m) =>
              '${m.returnType} ${m.name}(${m.params.toParameterSignature()}) => _ref.read(_provider.notifier).${m.name}(${m.params.toFunctionCallArguments()});',
        )
        .join('\n\n');
  }
}
