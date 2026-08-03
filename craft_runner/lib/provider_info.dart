import 'package:craft_runner/src/plugin_loader.dart';
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
    this.allProviderVarNames = const [],
    this.publicMethods = const [],
    this.pageKeyType = 'int',
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
  final List<String> allProviderVarNames;
  final List<PublicMethod> publicMethods;

  /// The page-key type of a paged provider (the type of the `page` param).
  /// `int` for page-number pagination, or a nullable type (e.g. `String?`)
  /// for cursor pagination.
  final String pageKeyType;

  /// The initial page key, derived from [pageKeyType]: `int` → `1`, a nullable
  /// type → `null`. Other (non-int, non-nullable) types are unsupported and
  /// return `null` here — the developer must use a nullable key and the
  /// generator leaves `firstPageKey` abstract for them to provide.
  String? get firstPageKey {
    if (pageKeyType == 'int') return '1';
    if (pageKeyType.endsWith('?')) return 'null';
    return null;
  }

  bool get hasArg => params.isNotEmpty;

  String get dataType => _dataType;

  String get returnName {
    if (type == ProviderType.sync) return dataType;
    if (type == ProviderType.future) return 'Future<$dataType>';
    if (type == ProviderType.stream) return 'Stream<$dataType>';
    if (type == ProviderType.paged) {
      return 'Future<PaginatedResponse<$dataType, $pageKeyType>>';
    }
    return '';
  }

  /// The error type parameter (`F`) for generated state/notifiers: the
  /// configured `error_mapper`'s return type, or `Object` by default.
  String get errorType => CraftConfig.errorType;

  String get stateType {
    if (type == ProviderType.sync) {
      return dataType;
    } else if (type == ProviderType.paged) {
      return 'PagedDataState<$dataType, $errorType, $pageKeyType>';
    } else {
      return 'DataState<$dataType, $errorType>';
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
