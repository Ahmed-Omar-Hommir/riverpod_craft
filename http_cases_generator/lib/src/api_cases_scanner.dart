import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'api_cases_models.dart';

class ApiCasesScanner {
  final List<ApiCaseSpec> _cases = [];
  final List<String> _diagnostics = [];

  ApiCasesScanResult get result => ApiCasesScanResult(
        cases: List.unmodifiable(_cases),
        diagnostics: List.unmodifiable(_diagnostics),
      );

  void collectFromUnit(
    ParseStringResult result,
    String filePath, {
    String? importPath,
  }) {
    for (final declaration in result.unit.declarations) {
      if (declaration is! ClassDeclaration) continue;
      final annotations = declaration.metadata
          .where((annotation) => _annotationName(annotation) == 'ApiCase')
          .toList();
      if (annotations.isEmpty) continue;

      final className = declaration.namePart.typeName.lexeme;
      final classLocation = result.lineInfo.getLocation(
        declaration.namePart.typeName.offset,
      );
      final context =
          '$filePath:${classLocation.lineNumber}:${classLocation.columnNumber}: '
          '$className';
      if (annotations.length > 1) {
        _diagnostics.add('$context has more than one @ApiCase annotation.');
        continue;
      }

      final group = _readGroup(annotations.single);
      if (group == null) {
        _diagnostics.add(
          '$context must use @ApiCase with exactly one string argument.',
        );
        continue;
      }

      if (className.startsWith('_')) {
        _diagnostics.add('$context must be public so it can be imported.');
      }
      if (declaration.abstractKeyword != null) {
        _diagnostics.add('$context must not be abstract.');
      }

      final isConstConstructor = _validateConstructor(
        declaration,
        result,
        filePath,
        context,
      );
      final defaultMethod = _readDefaultMethod(
        declaration,
        result,
        filePath,
        context,
      );

      _cases.add(
        ApiCaseSpec(
          className: className,
          filePath: filePath,
          importPath: importPath ?? filePath,
          group: group,
          line: classLocation.lineNumber,
          column: classLocation.columnNumber,
          isConstConstructor: isConstConstructor,
          defaultMethod: defaultMethod,
        ),
      );
    }
  }

  void addDiagnostic(String message) => _diagnostics.add(message);

  bool _validateConstructor(
    ClassDeclaration declaration,
    ParseStringResult result,
    String filePath,
    String classContext,
  ) {
    final constructors =
        declaration.body.members.whereType<ConstructorDeclaration>().toList();
    if (constructors.isEmpty) return false;

    final unnamed =
        constructors.where((constructor) => constructor.name == null).toList();
    if (unnamed.isEmpty) {
      _diagnostics.add(
        '$classContext must have an unnamed parameterless constructor.',
      );
      return false;
    }

    final constructor = unnamed.single;
    if (constructor.parameters.parameters.isNotEmpty) {
      final location = result.lineInfo.getLocation(
        constructor.parameters.offset,
      );
      _diagnostics.add(
        '$filePath:${location.lineNumber}:${location.columnNumber}: '
        '${declaration.namePart.typeName.lexeme} must have an unnamed '
        'parameterless constructor.',
      );
    }
    return constructor.constKeyword != null;
  }

  DefaultMethodSpec? _readDefaultMethod(
    ClassDeclaration declaration,
    ParseStringResult result,
    String filePath,
    String classContext,
  ) {
    final methods = <MethodDeclaration>[];
    for (final member in declaration.body.members) {
      final count = member.metadata
          .where((annotation) => _annotationName(annotation) == 'DefaultCase')
          .length;
      if (member is! MethodDeclaration) {
        if (count > 0) {
          final location = result.lineInfo.getLocation(member.offset);
          _diagnostics.add(
            '$filePath:${location.lineNumber}:${location.columnNumber}: '
            '${declaration.namePart.typeName.lexeme} uses @DefaultCase on a '
            'non-method declaration.',
          );
        }
        continue;
      }
      if (count > 1) {
        final location = result.lineInfo.getLocation(member.name.offset);
        _diagnostics.add(
          '$filePath:${location.lineNumber}:${location.columnNumber}: '
          '${declaration.namePart.typeName.lexeme}.${member.name.lexeme} has '
          'more than one @DefaultCase annotation.',
        );
      }
      if (count > 0) methods.add(member);
    }

    if (methods.length > 1) {
      _diagnostics.add(
        '$classContext may contain at most one @DefaultCase method.',
      );
      for (final method in methods) {
        _validateDefaultMethod(method, declaration, result, filePath);
      }
      return null;
    }
    if (methods.isEmpty) return null;

    final method = methods.single;
    return _validateDefaultMethod(method, declaration, result, filePath);
  }

  DefaultMethodSpec _validateDefaultMethod(
    MethodDeclaration method,
    ClassDeclaration declaration,
    ParseStringResult result,
    String filePath,
  ) {
    final location = result.lineInfo.getLocation(method.name.offset);
    final methodContext =
        '$filePath:${location.lineNumber}:${location.columnNumber}: '
        '${declaration.namePart.typeName.lexeme}.${method.name.lexeme}';
    if (method.isStatic ||
        method.isGetter ||
        method.isSetter ||
        method.isOperator ||
        method.name.lexeme.startsWith('_')) {
      _diagnostics.add(
        '$methodContext must be a public instance method.',
      );
    }

    final parameters = method.parameters?.parameters ?? const [];
    if (parameters.any((parameter) => parameter.isRequired)) {
      _diagnostics.add('$methodContext must not require arguments.');
    }
    if (method.body.isGenerator) {
      _diagnostics.add('$methodContext must not be a generator method.');
    }

    final returnType = method.returnType?.toSource();
    if (method.body.isAsynchronous && returnType == 'void') {
      _diagnostics.add(
        '$methodContext is async void; return Future<void> or omit the return type.',
      );
    }

    return DefaultMethodSpec(
      name: method.name.lexeme,
      isAsync: method.body.isAsynchronous || _isFutureType(returnType),
    );
  }

  String? _readGroup(Annotation annotation) {
    final arguments = annotation.arguments?.arguments;
    if (arguments == null || arguments.length != 1) return null;
    final argument = arguments.single;
    return argument is StringLiteral ? argument.stringValue : null;
  }

  String _annotationName(Annotation annotation) =>
      annotation.name.toSource().split('.').last;

  bool _isFutureType(String? returnType) =>
      returnType != null &&
      RegExp(r'(^|\.)(Future|FutureOr)(<|$)').hasMatch(returnType);
}
