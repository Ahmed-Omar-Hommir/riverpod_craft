import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

/// Converts a parsed Dart file (AST) into clean [DartElementInfo] objects.
///
/// This bridges the raw analyzer AST and the clean data models that plugins
/// work with. Plugins never see AST nodes — only [DartClassInfo] and
/// [DartFunctionInfo].
List<DartElementInfo> astToModel(ParseStringResult parsedResult) {
  final unit = parsedResult.unit;
  final elements = <DartElementInfo>[];

  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      elements.add(DartClassElement(_convertClass(declaration)));
    } else if (declaration is FunctionDeclaration) {
      elements.add(DartFunctionElement(_convertFunction(declaration)));
    }
  }

  return elements;
}

DartClassInfo _convertClass(ClassDeclaration declaration) {
  return DartClassInfo(
    name: declaration.name.lexeme,
    annotations: _convertAnnotations(declaration.metadata),
    methods: _convertMethods(declaration),
    superclass: declaration.extendsClause?.superclass.name2.lexeme,
    mixins: declaration.withClause?.mixinTypes
            .map((t) => t.name2.lexeme)
            .toList() ??
        const [],
    interfaces: declaration.implementsClause?.interfaces
            .map((t) => t.name2.lexeme)
            .toList() ??
        const [],
  );
}

List<MethodInfo> _convertMethods(ClassDeclaration declaration) {
  final methods = <MethodInfo>[];
  for (final member in declaration.members) {
    if (member is MethodDeclaration) {
      final DartType? type = member.returnType?.type;
      final returnType =
          type?.getDisplayString() ?? member.returnType?.toSource() ?? 'void';

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

DartFunctionInfo _convertFunction(FunctionDeclaration declaration) {
  final DartType? type = declaration.returnType?.type;
  final returnType =
      type?.getDisplayString() ?? declaration.returnType?.toSource() ?? 'void';

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
    String type = 'dynamic';
    String? defaultValue;
    bool isPositional = param.isPositional;
    bool isRequired =
        param.isRequired ||
        (param is DefaultFormalParameter && param.requiredKeyword != null);
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
    } else if (param is SimpleFormalParameter) {
      type = param.type?.toSource() ?? 'dynamic';
      name = param.name?.lexeme ?? name;
      isPositional = param.isPositional;
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

List<AnnotationInfo> _convertAnnotations(NodeList<Annotation> metadata) {
  return metadata.map((annotation) {
    final args = <String, String>{};
    final arguments = annotation.arguments;
    if (arguments != null) {
      for (final arg in arguments.arguments) {
        if (arg is NamedExpression) {
          args[arg.name.label.name] = arg.expression.toSource();
        }
      }
    }
    return AnnotationInfo(
      name: annotation.name.name,
      arguments: args,
    );
  }).toList();
}
