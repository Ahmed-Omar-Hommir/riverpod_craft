class ApiCaseSpec {
  const ApiCaseSpec({
    required this.className,
    required this.filePath,
    required this.importPath,
    required this.group,
    this.line = 1,
    this.column = 1,
    this.isConstConstructor = true,
    this.defaultMethod,
  });

  final String className;
  final String filePath;
  final String importPath;
  final String group;
  final int line;
  final int column;
  final bool isConstConstructor;
  final DefaultMethodSpec? defaultMethod;

  String get sourceLocation => '$filePath:$line:$column';
}

class DefaultMethodSpec {
  const DefaultMethodSpec({required this.name, required this.isAsync});

  final String name;
  final bool isAsync;
}

class ApiCasesScanResult {
  const ApiCasesScanResult({required this.cases, required this.diagnostics});

  final List<ApiCaseSpec> cases;
  final List<String> diagnostics;
}

class ApiCasesGenerateResult {
  const ApiCasesGenerateResult._({this.source, required this.diagnostics});

  factory ApiCasesGenerateResult.source(String source) =>
      ApiCasesGenerateResult._(source: source, diagnostics: const []);

  factory ApiCasesGenerateResult.failed(List<String> diagnostics) =>
      ApiCasesGenerateResult._(diagnostics: diagnostics);

  final String? source;
  final List<String> diagnostics;

  bool get success => source != null;
}

class ApiCasesGenerationError implements Exception {
  const ApiCasesGenerationError(this.diagnostics);

  final List<String> diagnostics;

  @override
  String toString() =>
      'http_cases_generator:\n${diagnostics.map((message) => '  - $message').join('\n')}';
}
