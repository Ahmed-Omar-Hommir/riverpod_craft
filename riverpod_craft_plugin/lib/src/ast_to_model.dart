import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

import 'resolved_types.dart';

/// Converts a parsed Dart file (AST) into clean [DartElementInfo] objects.
///
/// This bridges the raw analyzer AST and the clean data models that plugins
/// work with. Plugins never see AST nodes — only [DartClassInfo] and
/// [DartFunctionInfo].
List<DartElementInfo> astToModel(
  ParseStringResult parsedResult, {
  ResolvedReturnTypes resolved = const ResolvedReturnTypes.empty(),
}) {
  final unit = parsedResult.unit;
  final elements = <DartElementInfo>[];

  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      elements.add(DartClassElement(_convertClass(declaration, resolved)));
    } else if (declaration is FunctionDeclaration) {
      elements.add(DartFunctionElement(_convertFunction(declaration, resolved)));
    }
  }

  return elements;
}

DartClassInfo _convertClass(
  ClassDeclaration declaration,
  ResolvedReturnTypes resolved,
) {
  return DartClassInfo(
    name: declaration.namePart.typeName.lexeme,
    annotations: _convertAnnotations(declaration.metadata),
    methods: _convertMethods(declaration, resolved),
    superclass: declaration.extendsClause?.superclass.name.lexeme,
    mixins: declaration.withClause?.mixinTypes
            .map((t) => t.name.lexeme)
            .toList() ??
        const [],
    interfaces: declaration.implementsClause?.interfaces
            .map((t) => t.name.lexeme)
            .toList() ??
        const [],
  );
}

List<MethodInfo> _convertMethods(
  ClassDeclaration declaration,
  ResolvedReturnTypes resolved,
) {
  final className = declaration.namePart.typeName.lexeme;
  final methods = <MethodInfo>[];
  for (final member in declaration.body.members) {
    if (member is MethodDeclaration) {
      final DartType? type = member.returnType?.type;
      final returnType =
          resolved.forMethod(className, member.name.lexeme) ??
          type?.getDisplayString() ??
          member.returnType?.toSource() ??
          'void';

      methods.add(
        MethodInfo(
          name: member.name.lexeme,
          returnType: returnType,
          params: _convertParameters(member.parameters),
          annotations: _convertAnnotations(member.metadata),
          isStatic: member.isStatic,
          isGetter: member.isGetter,
          isSetter: member.isSetter,
          isOperator: member.isOperator,
        ),
      );
    }
  }
  return methods;
}

DartFunctionInfo _convertFunction(
  FunctionDeclaration declaration,
  ResolvedReturnTypes resolved,
) {
  final DartType? type = declaration.returnType?.type;
  final returnType =
      resolved.forFunction(declaration.name.lexeme) ??
      type?.getDisplayString() ??
      declaration.returnType?.toSource() ??
      'void';

  return DartFunctionInfo(
    name: declaration.name.lexeme,
    returnType: returnType,
    params: _convertParameters(declaration.functionExpression.parameters),
    annotations: _convertAnnotations(declaration.metadata),
  );
}

List<ParameterInfo> _convertParameters(FormalParameterList? parameters) {
  if (parameters == null || parameters.parameters.isEmpty) {
    return [];
  }

  return parameters.parameters.map((param) {
    return ParameterInfo(
      name: param.name?.lexeme ?? '',
      type: param.type?.toSource() ?? 'dynamic',
      isRequired: param.isRequired,
      defaultValue: param.defaultClause?.value.toSource(),
      isPositional: param.isPositional,
      isFamily: param.metadata.any((a) => a.name.name == 'family'),
    );
  }).toList();
}

List<AnnotationInfo> _convertAnnotations(NodeList<Annotation> metadata) {
  return metadata.map((annotation) {
    final args = <String, String>{};
    final arguments = annotation.arguments;
    if (arguments != null) {
      for (final arg in arguments.arguments) {
        if (arg is NamedArgument) {
          args[arg.name.lexeme] = arg.argumentExpression.toSource();
        }
      }
    }
    return AnnotationInfo(
      name: annotation.name.name,
      arguments: args,
    );
  }).toList();
}
