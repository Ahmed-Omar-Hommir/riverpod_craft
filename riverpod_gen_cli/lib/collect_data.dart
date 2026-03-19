import 'package:riverpod_gen_cli/command_info.dart';
import 'package:riverpod_gen_cli/concurrency_type.dart';
import 'package:riverpod_gen_cli/parameter_info.dart';
import 'package:riverpod_gen_cli/provider_info.dart';
import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';

import 'provider_data_collection.dart';

ProviderDataCollection collectData(ParseStringResult content) {
  final unit = content.unit;

  final providers = <ProviderInfo>[];

  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      if (!_hasAnnotation(declaration.metadata, 'provider')) continue;

      final className = declaration.name.lexeme;
      final isKeepAlive = _hasAnnotation(declaration.metadata, 'keepAlive');

      final createMethod = _findCreateMethod(declaration);
      if (createMethod == null) continue;

      final dataType = _extractGenericTypeMethod(createMethod);

      // Get create method params - these are the family args
      final createParams = _extractParametersMothod(createMethod);

      final providerType = _getProviderTypeMethod(createMethod);

      final commands = _extractCommands(declaration);
      final publicMethods = _extractPublicMethods(declaration);

      // For class-based providers, create method params are family params
      final familyParams = createParams
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

      providers.add(
        ProviderInfo(
          name: className,
          dataType: dataType,
          isKeepAlive: isKeepAlive,
          type: providerType,
          params: familyParams,
          commands: commands,
          publicMethods: publicMethods,
        ),
      );
    }
  }

  // Top-level functional providers
  for (final declaration in unit.declarations) {
    if (declaration is FunctionDeclaration) {
      final metadata = declaration.metadata;
      final isProvider = _hasAnnotation(metadata, 'provider');
      final isProviderValue = _hasAnnotation(metadata, 'providerValue');
      if (!isProvider && !isProviderValue) continue;

      final functionName = declaration.name.lexeme;
      final isKeepAlive = _hasAnnotation(metadata, 'keepAlive');
      final providerType = isProviderValue
          ? ProviderType.sync
          : _getProviderTypeFunction(declaration);
      final dataType = _extractGenericTypeFunction(declaration);

      // parameters
      var params = _extractParametersFunction(declaration);

      // For providers (including providerValue), check for Ref ref as first parameter
      bool requiresRef = false;
      final firstPositional = params.where((p) => p.isPositional).firstOrNull;
      if (firstPositional != null &&
          firstPositional.name == 'ref' &&
          firstPositional.type == 'Ref') {
        requiresRef = true;
        params = List<ParameterInfo>.from(params)..remove(firstPositional);
      }

      providers.add(
        ProviderInfo(
          name: functionName[0].toUpperCase() + functionName.substring(1),
          dataType: dataType,
          isKeepAlive: isKeepAlive,
          type: providerType,
          params: params,
          commands: const [],
          isFunctional: true,
          functionName: functionName,
          requiresRef: requiresRef,
          isValueProvider: isProviderValue,
          publicMethods: const <PublicMethod>[],
        ),
      );
    }
  }

  final topLevelCommands = _extractTopLevelCommands(unit);

  return ProviderDataCollection(
    providers: providers,
    commands: topLevelCommands,
  );
}

bool _hasAnnotation(NodeList<Annotation> metadata, String name) {
  return metadata.any((annotation) => annotation.name.name == name);
}

String _extractGenericType(String? returnType) {
  if (returnType == null) return 'dynamic';

  final futureMatch = RegExp(r'^Future<(.+)>\??$').firstMatch(returnType);
  if (futureMatch != null) {
    return futureMatch.group(1)!;
  }

  final streamMatch = RegExp(r'^Stream<(.+)>\??$').firstMatch(returnType);
  if (streamMatch != null) {
    return streamMatch.group(1)!;
  }

  return returnType;
}

String _extractGenericTypeMethod(MethodDeclaration createMethod) {
  final DartType? type = createMethod.returnType?.type;
  final returnType =
      type?.getDisplayString() ?? createMethod.returnType?.toSource();
  return _extractGenericType(returnType);
}

String _extractGenericTypeFunction(FunctionDeclaration createMethod) {
  final DartType? type = createMethod.returnType?.type;
  final returnType =
      type?.getDisplayString() ?? createMethod.returnType?.toSource();
  return _extractGenericType(returnType);
}

MethodDeclaration? _findCreateMethod(ClassDeclaration classDeclaration) {
  for (final member in classDeclaration.members) {
    if (member is MethodDeclaration && member.name.lexeme == 'create') {
      return member;
    }
  }
  return null;
}

ProviderType _getProviderTypeMethod(MethodDeclaration method) {
  final returnType = method.returnType?.toSource() ?? '';
  return _getProviderType(returnType);
}

ProviderType _getProviderType(String returnType) {
  if (returnType.startsWith('Future<')) {
    return ProviderType.future;
  } else if (returnType.startsWith('Stream<')) {
    return ProviderType.stream;
  } else {
    return ProviderType.sync;
  }
}

ProviderType _getProviderTypeFunction(FunctionDeclaration method) {
  final returnType = method.returnType?.toSource() ?? '';
  return _getProviderType(returnType);
}

List<ParameterInfo> _extractParameters(FormalParameterList? parameters) {
  if (parameters == null || parameters.parameters.isEmpty) {
    return [];
  }

  return parameters.parameters.map((param) {
    String type = 'dynamic';
    String? defaultValue;
    bool isPositional = param.isPositional;
    bool isRequired =
        param.isRequired || // covers required positional
        (param is DefaultFormalParameter &&
            param.requiredKeyword != null); // covers required named
    String name = param.name?.lexeme ?? '';
    bool isFamily = false;

    if (param is DefaultFormalParameter) {
      final inner = param.parameter;

      if (inner is SimpleFormalParameter) {
        type = inner.type?.toSource() ?? 'dynamic';
        name = inner.name?.lexeme ?? name;
      } else if (inner is FieldFormalParameter) {
        type = inner.type?.toSource() ?? 'dynamic';
        name = inner.name.lexeme;
      }

      defaultValue = param.defaultValue?.toSource();
      isPositional = param.isPositional;
      // isRequired already handled above
    } else if (param is SimpleFormalParameter) {
      type = param.type?.toSource() ?? 'dynamic';
      name = param.name?.lexeme ?? name;
      isPositional = param.isPositional;
      // isRequired already set correctly
    } else if (param is FieldFormalParameter) {
      type = param.type?.toSource() ?? 'dynamic';
      name = param.name.lexeme;
      isPositional = param.isPositional;
    }

    // Detect @family annotation on parameter
    final metadata = (param is DefaultFormalParameter)
        ? ((param.parameter is SimpleFormalParameter)
              ? (param.parameter as SimpleFormalParameter).metadata
              : (param.parameter is FieldFormalParameter)
              ? (param.parameter as FieldFormalParameter).metadata
              : null)
        : (param is SimpleFormalParameter)
        ? param.metadata
        : (param is FieldFormalParameter)
        ? param.metadata
        : null;
    if (metadata != null && metadata.any((a) => a.name.name == 'family')) {
      isFamily = true;
    }

    return ParameterInfo(
      name: name,
      type: type,
      isRequired: isRequired,
      defaultValue: defaultValue,
      isPositional: isPositional,
      isFamily: isFamily,
    );
  }).toList();
}

List<ParameterInfo> _extractParametersMothod(MethodDeclaration? method) {
  final parameters = method?.parameters;
  return _extractParameters(parameters);
}

List<ParameterInfo> _extractParametersFunction(FunctionDeclaration? function) {
  final parameters = function?.functionExpression.parameters;
  return _extractParameters(parameters);
}

List<Command> _extractCommands(ClassDeclaration classDeclaration) {
  final commands = <Command>[];

  for (final member in classDeclaration.members) {
    if (member is MethodDeclaration) {
      if (!_hasAnnotation(member.metadata, 'command')) continue;
      if (_getProviderTypeMethod(member) != ProviderType.future) continue;

      final methodName = member.name.lexeme;
      final methodParams = _extractParametersMothod(member);
      final concurrencyType = _getConcurrencyType(member.metadata);
      final dataType = _extractGenericTypeMethod(member);
      final isKeepAlive = _hasAnnotation(member.metadata, 'keepAlive');

      commands.add(
        Command(
          name: methodName,
          params: methodParams,
          concurrency: concurrencyType,
          dataType: dataType,
          isKeepAlive: isKeepAlive,
        ),
      );
    }
  }

  return commands;
}

List<Command> _extractTopLevelCommands(CompilationUnit unit) {
  final commands = <Command>[];

  for (final declaration in unit.declarations) {
    if (declaration is FunctionDeclaration) {
      final metadata = declaration.metadata;
      if (!_hasAnnotation(metadata, 'command')) continue;

      // Only consider top-level functions that return Future (ProviderType.future)
      if (_getProviderTypeFunction(declaration) != ProviderType.future) {
        continue;
      }

      final functionName = declaration.name.lexeme;
      var params = _extractParametersFunction(declaration);

      // Remove the first positional parameter if it is 'ref' of type 'Ref'
      final firstParam = params.where((p) => p.isPositional).firstOrNull;
      if (firstParam != null &&
          firstParam.name == 'ref' &&
          firstParam.type == 'Ref') {
        params = List<ParameterInfo>.from(params)..remove(firstParam);
      }

      final concurrencyType = _getConcurrencyType(metadata);
      final dataType = _extractGenericTypeFunction(declaration);
      final isKeepAlive = _hasAnnotation(metadata, 'keepAlive');

      commands.add(
        Command(
          name: functionName,
          params: params,
          concurrency: concurrencyType,
          dataType: dataType,
          isKeepAlive: isKeepAlive,
        ),
      );
    }
  }

  return commands;
}

ConcurrencyType _getConcurrencyType(NodeList<Annotation> metadata) {
  if (_hasAnnotation(metadata, 'droppable')) return ConcurrencyType.droppable;
  if (_hasAnnotation(metadata, 'restartable')) {
    return ConcurrencyType.restartable;
  }
  if (_hasAnnotation(metadata, 'concurrent')) return ConcurrencyType.concurrent;
  if (_hasAnnotation(metadata, 'sequential')) return ConcurrencyType.sequential;

  return ConcurrencyType.droppable;
}

List<PublicMethod> _extractPublicMethods(ClassDeclaration declaration) {
  final methods = <PublicMethod>[];

  for (final member in declaration.members) {
    if (member is MethodDeclaration) {
      final methodName = member.name.lexeme;
      final isPublic = !methodName.startsWith('_');
      final isConstructor =
          member.isGetter || member.isSetter || member.isOperator;
      final isCreate = methodName == 'create';
      final isStatic = member.isStatic == true;
      final isCommand = _hasAnnotation(member.metadata, 'command');
      if (isPublic && !isConstructor && !isCreate && !isStatic && !isCommand) {
        final returnType = member.returnType?.toSource() ?? 'void';
        final params = _extractParametersMothod(member);
        methods.add(
          PublicMethod(
            name: methodName,
            returnType: returnType,
            params: params,
          ),
        );
      }
    }
  }

  return methods;
}
