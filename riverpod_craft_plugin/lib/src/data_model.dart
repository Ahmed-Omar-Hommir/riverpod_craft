import 'parameter_info.dart';

/// Metadata about a Dart annotation (e.g., `@provider`, `@command`).
class AnnotationInfo {
  const AnnotationInfo({required this.name, this.arguments = const {}});

  final String name;
  final Map<String, String> arguments;
}

/// Metadata about a class method.
class MethodInfo {
  const MethodInfo({
    required this.name,
    required this.returnType,
    required this.params,
    required this.annotations,
    this.isStatic = false,
    this.isGetter = false,
    this.isSetter = false,
    this.isOperator = false,
  });

  final String name;
  final String returnType;
  final List<ParameterInfo> params;
  final List<AnnotationInfo> annotations;
  final bool isStatic;
  final bool isGetter;
  final bool isSetter;
  final bool isOperator;

  /// Whether this method has a specific annotation.
  bool hasAnnotation(String name) =>
      annotations.any((a) => a.name == name);
}

/// Metadata about a Dart class declaration.
class DartClassInfo {
  const DartClassInfo({
    required this.name,
    required this.annotations,
    required this.methods,
    this.superclass,
    this.mixins = const [],
    this.interfaces = const [],
  });

  final String name;
  final List<AnnotationInfo> annotations;
  final List<MethodInfo> methods;
  final String? superclass;
  final List<String> mixins;
  final List<String> interfaces;

  /// Whether this class has a specific annotation.
  bool hasAnnotation(String name) =>
      annotations.any((a) => a.name == name);

  /// Find a method by name, or null if not found.
  MethodInfo? findMethod(String name) {
    for (final m in methods) {
      if (m.name == name) return m;
    }
    return null;
  }

  /// All methods that have a specific annotation.
  List<MethodInfo> methodsWithAnnotation(String name) =>
      methods.where((m) => m.hasAnnotation(name)).toList();
}

/// Metadata about a top-level function declaration.
class DartFunctionInfo {
  const DartFunctionInfo({
    required this.name,
    required this.returnType,
    required this.params,
    required this.annotations,
  });

  final String name;
  final String returnType;
  final List<ParameterInfo> params;
  final List<AnnotationInfo> annotations;

  /// Whether this function has a specific annotation.
  bool hasAnnotation(String name) =>
      annotations.any((a) => a.name == name);
}

/// A parsed Dart element (class or function) with clean metadata.
///
/// Plugins receive this instead of raw AST nodes.
sealed class DartElementInfo {
  /// All annotations on this element.
  List<AnnotationInfo> get annotations;
}

/// A class element with its metadata.
class DartClassElement extends DartElementInfo {
  DartClassElement(this.classInfo);

  final DartClassInfo classInfo;

  @override
  List<AnnotationInfo> get annotations => classInfo.annotations;
}

/// A function element with its metadata.
class DartFunctionElement extends DartElementInfo {
  DartFunctionElement(this.functionInfo);

  final DartFunctionInfo functionInfo;

  @override
  List<AnnotationInfo> get annotations => functionInfo.annotations;
}
