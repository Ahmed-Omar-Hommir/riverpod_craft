class ApiCasesConfig {
  const ApiCasesConfig({
    this.output = 'test/http_cases.craft.dart',
    this.scope = const ['lib', 'test'],
  });

  final String output;
  final List<String> scope;

  factory ApiCasesConfig.fromOptions(Map<String, Object?> options) {
    final output = options['output'];
    final rawScope = options['scope'];
    final scope = rawScope is List
        ? rawScope
            .whereType<String>()
            .map((value) => value.trim())
            .where(
              (value) => value.isNotEmpty,
            )
            .toList()
        : const <String>[];

    return ApiCasesConfig(
      output: output is String && output.trim().isNotEmpty
          ? output.trim()
          : 'test/http_cases.craft.dart',
      scope: scope.isEmpty ? const ['lib', 'test'] : scope,
    );
  }
}
