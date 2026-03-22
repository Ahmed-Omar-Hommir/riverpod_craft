import 'package:riverpod_craft_cli/parameters_converter.dart';
import 'package:riverpod_craft_cli/provider_info.dart';

import 'concurrency_type.dart';
import 'parameter_info.dart';

class Command {
  const Command({
    required this.name,
    required this.params,
    required this.concurrency,
    required this.dataType,
    this.isKeepAlive = false,
  });
  final String name;
  final List<ParameterInfo> params;
  final ConcurrencyType concurrency;
  final String dataType;
  final bool isKeepAlive;

  /// Params marked with @family annotation - used as provider family key
  List<ParameterInfo> get familyParams =>
      params.where((p) => p.isFamily).toList();

  /// Non-family params - passed to the command's run() method
  List<ParameterInfo> get nonFamilyParams =>
      params.where((p) => !p.isFamily).toList();

  bool get hasFamily => familyParams.isNotEmpty;
  bool get hasNonFamilyArg => nonFamilyParams.isNotEmpty;
  bool get hasArg => params.isNotEmpty;

  String get publicName => name.startsWith('_') ? name.substring(1) : name;

  /// CommandNotifier type with data type and arg record type
  /// For no-arg commands, argRecordType is () (empty record)
  String get notifierType {
    final argRecordType = nonFamilyParams.isEmpty
        ? '()'
        : nonFamilyParams.toRecordType();
    return 'CommandNotifier<$dataType, $argRecordType>';
  }

  /// State type is always ArgCommandState with the appropriate arg record type
  /// For no-arg commands, argRecordType is () (empty record)
  String get stateType {
    final argRecordType = nonFamilyParams.isEmpty
        ? '()'
        : nonFamilyParams.toRecordType();
    return 'ArgCommandState<$dataType, $argRecordType>';
  }

  /// Returns the nullable version of stateType.
  /// If stateType already ends with '?', returns it as-is to avoid 'Type??'.
  String get nullableStateType {
    final st = stateType;
    return st.endsWith('?') ? st : '$st?';
  }

  String get strategyType {
    switch (concurrency) {
      case ConcurrencyType.droppable:
        return 'ActionStrategy.droppable';
      case ConcurrencyType.restartable:
        return 'ActionStrategy.restartable';
      case ConcurrencyType.sequential:
        return 'ActionStrategy.sequential';
      case ConcurrencyType.concurrent:
        return 'ActionStrategy.concurrent';
    }
  }

  /// Command controller type - same as notifierType for the new unified CommandNotifier
  String get commandControllerType => notifierType;

  CommandBuilder builder({required ProviderInfo? parent}) =>
      CommandBuilder(command: this, parent: parent);

  /// Builds the class name for the generated command notifier
  String get _generatedClassName =>
      '_\$${name[0].toUpperCase()}${name.substring(1)}Command';

  /// Builds the function call for the command action (class-based, no lambda wrapper)
  String _buildActionCall() {
    if (hasFamily) {
      // Family command: family params come from _familyArg, non-family from arg
      final positionalParams = params.where((p) => p.isPositional).toList();
      final namedParams = params.where((p) => !p.isPositional).toList();

      if (hasNonFamilyArg) {
        final positionalStr = positionalParams
            .map((p) {
              return p.isFamily ? '_familyArg.${p.name}' : 'arg.${p.name}';
            })
            .join(', ');

        final namedStr = namedParams
            .map((p) {
              return p.isFamily
                  ? '${p.name}: _familyArg.${p.name}'
                  : '${p.name}: arg.${p.name}';
            })
            .join(', ');

        final allArgs = [
          positionalStr,
          namedStr,
        ].where((s) => s.isNotEmpty).join(', ');
        return '$name(ref, $allArgs)';
      } else {
        final positionalStr = positionalParams
            .where((p) => p.isFamily)
            .map((p) => '_familyArg.${p.name}')
            .join(', ');
        final namedStr = namedParams
            .where((p) => p.isFamily)
            .map((p) => '${p.name}: _familyArg.${p.name}')
            .join(', ');
        final familyArgs = [
          positionalStr,
          namedStr,
        ].where((s) => s.isNotEmpty).join(', ');
        return '$name(ref, $familyArgs)';
      }
    } else if (hasNonFamilyArg) {
      return '$name(ref, ${nonFamilyParams.fromRecordToFunctionCall()})';
    } else {
      return '$name(ref)';
    }
  }

  /// Builds the complete provider declaration for top-level commands using class-based approach
  String _buildProviderDeclaration() {
    final argRecordType = nonFamilyParams.isEmpty
        ? '()'
        : nonFamilyParams.toRecordType();
    final isAutoDispose = !isKeepAlive;

    if (hasFamily) {
      final familyRecordType = familyParams.toRecordType();
      return '''final _\$${name}Command = NotifierProvider.family<$notifierType, $stateType, $familyRecordType>(
  ($familyRecordType familyArg) => $_generatedClassName(familyArg),
  isAutoDispose: $isAutoDispose,
);

class $_generatedClassName extends CommandNotifier<$dataType, $argRecordType> {
  $_generatedClassName(this._familyArg);
  final $familyRecordType _familyArg;

  @override
  Future<$dataType> action(Ref ref, $argRecordType arg) => ${_buildActionCall()};

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => $strategyType;
}''';
    }

    return '''final _\$${name}Command = NotifierProvider<$notifierType, $stateType>(
  () => $_generatedClassName(),
  isAutoDispose: $isAutoDispose,
);

class $_generatedClassName extends CommandNotifier<$dataType, $argRecordType> {
  @override
  Future<$dataType> action(Ref ref, $argRecordType arg) => ${_buildActionCall()};

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => $strategyType;
}''';
  }

  String build() {
    final builder = CommandBuilder(command: this, parent: null);

    if (hasFamily) {
      // For family commands, extension returns a method that takes family params
      return """
${_buildProviderDeclaration()}

${builder.buildFacadeCommandClassRef()}

${builder.buildFacadeCommandClassWidgetRef()}

extension \$${name[0].toUpperCase()}${name.substring(1)}CommandRefEx on Ref {
  ${builder.facadeCommandClassNameRef} ${name}Command(${familyParams.toParameterSignature()}) => ${builder.facadeCommandClassNameRef}(this, ${familyParams.toRecordValue()});
}

extension \$${name[0].toUpperCase()}${name.substring(1)}CommandWidgetRefEx on WidgetRef {
  ${builder.facadeCommandClassNameWidgetRef} ${name}Command(${familyParams.toParameterSignature()}) => ${builder.facadeCommandClassNameWidgetRef}(this, ${familyParams.toRecordValue()});
}
""";
    }

    return """
${_buildProviderDeclaration()}

${builder.buildFacadeCommandClassRef()}

${builder.buildFacadeCommandClassWidgetRef()}

extension \$${name[0].toUpperCase()}${name.substring(1)}CommandRefEx on Ref {
  ${builder.facadeCommandClassNameRef} get ${name}Command => ${builder.facadeCommandClassNameRef}(this);
}

extension \$${name[0].toUpperCase()}${name.substring(1)}CommandWidgetRefEx on WidgetRef {
  ${builder.facadeCommandClassNameWidgetRef} get ${name}Command => ${builder.facadeCommandClassNameWidgetRef}(this);
}
""";
  }
}

// extension SendMessage12CommandRefEx on Ref {
//   $SendMessage12CommandFacade get sendMessage12Command =>
//       $SendMessage12CommandFacade(this, null);
// }

// extension SendMessage12CommandWidgetRefEx on WidgetRef {
//   $SendMessage12CommandFacade get sendMessage12Command =>
//       $SendMessage12CommandFacade(null, this);
// }

class CommandBuilder {
  const CommandBuilder({required this.command, required this.parent});
  final Command command;
  final ProviderInfo? parent;

  // this for both
  bool get _hasParent => parent != null;
  bool get _hasFamily => command.hasFamily;
  List<ParameterInfo> get _familyParams => command.familyParams;
  List<ParameterInfo> get _nonFamilyParams => command.nonFamilyParams;

  // this for both
  String get facadeCommandClassName {
    final baseName =
        '\$${command.publicName[0].toUpperCase()}${command.publicName.substring(1)}CommandFacade';
    if (_hasParent) {
      return '$baseName${parent!.name}';
    }
    return baseName;
  }

  String get facadeCommandClassNameRef => '${facadeCommandClassName}Ref';
  String get facadeCommandClassNameWidgetRef =>
      '${facadeCommandClassName}Widget';

  // Ref-only facade class
  String buildFacadeCommandClassRef() {
    final hasFamily = _hasFamily;
    final hasParentAndFamily = _hasParent && hasFamily;

    String constructorParams;
    if (hasParentAndFamily) {
      constructorParams = '(this._ref, this._instance, this._familyArg)';
    } else if (_hasParent) {
      constructorParams = '(this._ref, this._instance)';
    } else if (hasFamily) {
      constructorParams = '(this._ref, this._familyArg)';
    } else {
      constructorParams = '(this._ref)';
    }

    final instanceField = _hasParent ? 'final ${parent!.name} _instance;' : '';
    final familyField = hasFamily
        ? 'final ${_familyParams.toRecordType()} _familyArg;'
        : '';

    final refField = 'final Ref _ref;';

    String commandInitialization;
    if (hasParentAndFamily) {
      commandInitialization =
          'late final _command = _instance._\$${command.name}Command(_familyArg);';
    } else if (_hasParent) {
      commandInitialization =
          'late final _command = _instance._\$${command.name}Command;';
    } else if (hasFamily) {
      commandInitialization =
          'late final _command = _\$${command.name}Command(_familyArg);';
    } else {
      commandInitialization =
          'late final _command = _\$${command.name}Command;';
    }

    // run() takes non-family params only
    // When no params, call run() without arguments but add(()) internally
    final hasNonFamilyParams = _nonFamilyParams.isNotEmpty;
    final runParams = hasNonFamilyParams
        ? _nonFamilyParams.toParameterSignature()
        : '';
    final runArgs = hasNonFamilyParams
        ? _nonFamilyParams.toRecordValue()
        : '()';

    return '''
class $facadeCommandClassNameRef {
  $facadeCommandClassNameRef$constructorParams;
  $instanceField
  $familyField
  $refField

  $commandInitialization

  ${command.stateType} read() => _ref.read(_command);
  ${command.stateType} watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(R Function(${command.stateType} state) selector) =>
      SelectedRefFacade(_ref, _command.select(selector));

  void run($runParams) => _ref.read(_command.notifier).add($runArgs);
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(${command.nullableStateType} previous, ${command.stateType} next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}''';
  }

  // WidgetRef-only facade class
  String buildFacadeCommandClassWidgetRef() {
    final hasFamily = _hasFamily;
    final hasParentAndFamily = _hasParent && hasFamily;

    String constructorParams;
    if (hasParentAndFamily) {
      constructorParams = '(this._ref, this._instance, this._familyArg)';
    } else if (_hasParent) {
      constructorParams = '(this._ref, this._instance)';
    } else if (hasFamily) {
      constructorParams = '(this._ref, this._familyArg)';
    } else {
      constructorParams = '(this._ref)';
    }

    final instanceField = _hasParent ? 'final ${parent!.name} _instance;' : '';
    final familyField = hasFamily
        ? 'final ${_familyParams.toRecordType()} _familyArg;'
        : '';

    final refField = 'final WidgetRef _ref;';

    String commandInitialization;
    if (hasParentAndFamily) {
      commandInitialization =
          'late final _command = _instance._\$${command.name}Command(_familyArg);';
    } else if (_hasParent) {
      commandInitialization =
          'late final _command = _instance._\$${command.name}Command;';
    } else if (hasFamily) {
      commandInitialization =
          'late final _command = _\$${command.name}Command(_familyArg);';
    } else {
      commandInitialization =
          'late final _command = _\$${command.name}Command;';
    }

    // run() takes non-family params only
    // When no params, call run() without arguments but add(()) internally
    final hasNonFamilyParams = _nonFamilyParams.isNotEmpty;
    final runParams = hasNonFamilyParams
        ? _nonFamilyParams.toParameterSignature()
        : '';
    final runArgs = hasNonFamilyParams
        ? _nonFamilyParams.toRecordValue()
        : '()';

    return '''
class $facadeCommandClassNameWidgetRef implements CommandProviderFacade<${command.dataType}, ${command.nonFamilyParams.isEmpty ? '()' : command.nonFamilyParams.toRecordType()}>, CommandProviderValue<${command.dataType}, ${command.nonFamilyParams.isEmpty ? '()' : command.nonFamilyParams.toRecordType()}> {
  $facadeCommandClassNameWidgetRef$constructorParams;
  $instanceField
  $familyField
  $refField

  $commandInitialization

  @override
  ${command.stateType} read() => _ref.read(_command);
  @override
  ${command.stateType} watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(R Function(${command.stateType} state) selector) =>
      SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run($runParams) => _ref.read(_command.notifier).add($runArgs);
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(${command.nullableStateType} previous, ${command.stateType} next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<${command.dataType}, ${command.nonFamilyParams.isEmpty ? '()' : command.nonFamilyParams.toRecordType()}> of(WidgetRef ref) => $facadeCommandClassNameWidgetRef(ref${_hasParent ? ', _instance' : ''}${hasFamily ? ', _familyArg' : ''});
}''';
  }

  // Builds the action call for commands inside parent (class-based, no lambda)
  // For parent commands: family params and non-family are handled together
  // Respects positional vs named parameter ordering
  String _buildParentActionCall() {
    if (_hasFamily) {
      // Commands inside parent with family: family params from _familyArg, non-family from arg
      final positionalParams = command.params
          .where((p) => p.isPositional)
          .toList();
      final namedParams = command.params.where((p) => !p.isPositional).toList();

      if (command.hasNonFamilyArg) {
        // Build positional args first
        final positionalStr = positionalParams
            .map((p) {
              if (p.isFamily) {
                return '_familyArg.${p.name}';
              } else {
                return 'arg.${p.name}';
              }
            })
            .join(', ');

        // Then named args
        final namedStr = namedParams
            .map((p) {
              if (p.isFamily) {
                return '${p.name}: _familyArg.${p.name}';
              } else {
                return '${p.name}: arg.${p.name}';
              }
            })
            .join(', ');

        final allArgs = [
          positionalStr,
          namedStr,
        ].where((s) => s.isNotEmpty).join(', ');
        return '_instance.${command.name}($allArgs)';
      } else {
        // Only family params
        final positionalStr = positionalParams
            .where((p) => p.isFamily)
            .map((p) => '_familyArg.${p.name}')
            .join(', ');

        final namedStr = namedParams
            .where((p) => p.isFamily)
            .map((p) => '${p.name}: _familyArg.${p.name}')
            .join(', ');

        final familyArgs = [
          positionalStr,
          namedStr,
        ].where((s) => s.isNotEmpty).join(', ');
        return '_instance.${command.name}($familyArgs)';
      }
    } else if (command.hasNonFamilyArg) {
      return '_instance.${command.name}(${_nonFamilyParams.fromRecordToFunctionCall()})';
    } else {
      // No args
      return '_instance.${command.name}()';
    }
  }

  /// Gets the generated class name for commands inside parent
  String get _parentCommandClassName =>
      '_\$${command.name[0].toUpperCase()}${command.name.substring(1)}Command${parent!.name}';

  // this for parent only - class-based approach
  String buildCommandInsideParent() {
    final isAutoDispose = !command.isKeepAlive;

    if (_hasFamily) {
      // Family command inside parent: generate family provider with class
      final familyRecordType = _familyParams.toRecordType();
      return '''
  Future<${command.dataType}> ${command.name}(${command.params.toParameterSignature()});

  late final _\$${command.name}Command = NotifierProvider.family<${command.notifierType}, ${command.stateType}, $familyRecordType>(
    ($familyRecordType familyArg) => $_parentCommandClassName(this as ${parent!.name}, familyArg),
    isAutoDispose: $isAutoDispose,
  );

  $facadeCommandClassNameRef ${command.publicName}Command(${_familyParams.toParameterSignature()}) => $facadeCommandClassNameRef(ref, this as ${parent!.name}, ${_familyParams.toRecordValue()});''';
    }

    return '''
  Future<${command.dataType}> ${command.name}(${command.params.toParameterSignature()});

  late final _\$${command.name}Command = NotifierProvider<${command.notifierType}, ${command.stateType}>(
    () => $_parentCommandClassName(this as ${parent!.name}),
    isAutoDispose: $isAutoDispose,
  );

  $facadeCommandClassNameRef get ${command.publicName}Command => $facadeCommandClassNameRef(ref, this as ${parent!.name});''';
  }

  /// Builds the command class for commands inside parent
  String buildCommandClassInsideParent() {
    final argRecordType = _nonFamilyParams.isEmpty
        ? '()'
        : _nonFamilyParams.toRecordType();

    if (_hasFamily) {
      final familyRecordType = _familyParams.toRecordType();
      return '''
class $_parentCommandClassName extends CommandNotifier<${command.dataType}, $argRecordType> {
  $_parentCommandClassName(this._instance, this._familyArg);
  final ${parent!.name} _instance;
  final $familyRecordType _familyArg;

  @override
  Future<${command.dataType}> action(Ref ref, $argRecordType arg) => ${_buildParentActionCall()};

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ${command.strategyType};
}''';
    }

    return '''
class $_parentCommandClassName extends CommandNotifier<${command.dataType}, $argRecordType> {
  $_parentCommandClassName(this._instance);
  final ${parent!.name} _instance;

  @override
  Future<${command.dataType}> action(Ref ref, $argRecordType arg) => ${_buildParentActionCall()};

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ${command.strategyType};
}''';
  }
}
