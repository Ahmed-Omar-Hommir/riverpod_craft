import 'package:craft_runner/src/provider_code_generator.dart';

import 'command_info.dart';
import 'parameter_info.dart';

enum ProviderType { sync, future, stream, paged }

class PublicMethod {
  const PublicMethod({
    required this.name,
    required this.returnType,
    required this.params,
  });

  final String name;
  final String returnType;
  final List<ParameterInfo> params;
}

class ProviderInfo {
  const ProviderInfo({
    required this.name,
    required String dataType,
    required this.isKeepAlive,
    required this.type,
    required this.params,
    required this.commands,
    this.isFunctional = false,
    this.functionName,
    this.requiresRef = false,
    this.isSettable = false,
    this.hasPagedMapper = false,
    this.errorType,
    this.allProviderVarNames = const [],
    this.publicMethods = const [],
  }) : _dataType = dataType;

  final String name;
  final String _dataType;
  final bool isKeepAlive;
  final ProviderType type;
  final List<ParameterInfo> params;
  final List<Command> commands;
  final bool isFunctional;
  final String? functionName;
  final bool requiresRef;
  final bool isSettable;
  final bool hasPagedMapper;
  final String? errorType;
  final List<String> allProviderVarNames;
  final List<PublicMethod> publicMethods;

  bool get hasArg => params.isNotEmpty;

  String get dataType => _dataType;

  String get returnName {
    if (type == ProviderType.sync) return dataType;
    if (type == ProviderType.future) return 'Future<$dataType>';
    if (type == ProviderType.stream) return 'Stream<$dataType>';
    if (type == ProviderType.paged) return 'Future<PaginatedResponse<$dataType>>';
    return '';
  }

  String get stateType {
    if (type == ProviderType.sync) {
      return dataType;
    } else if (type == ProviderType.paged) {
      return 'PagedDataState<$dataType>';
    } else if (errorType != null) {
      return 'DataState<$dataType, CraftError<$errorType>>';
    } else {
      return 'DataState<$dataType>';
    }
  }

  /// Returns the nullable version of stateType.
  /// If stateType already ends with '?', returns it as-is to avoid 'Type??'.
  String get nullableStateType {
    final st = stateType;
    return st.endsWith('?') ? st : '$st?';
  }

  String get notifierType => '\$\$$name';

  String get facadeClassName => '\$${name}Facade';

  String get providerVarName =>
      '${name[0].toLowerCase()}${name.substring(1)}Provider';

  String build() => ProviderCodeGenerator(this).generate();
}
