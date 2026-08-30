import 'package:path/path.dart' as p;

import 'api_cases_models.dart';

const _reservedWords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

ApiCasesGenerateResult generateApiCases({
  required List<ApiCaseSpec> cases,
  required String outputPath,
  List<String> initialDiagnostics = const [],
}) {
  final diagnostics = [...initialDiagnostics];
  final sortedCases = [...cases]..sort((a, b) {
      final group = a.group.compareTo(b.group);
      if (group != 0) return group;
      final accessor = caseAccessor(a.className).compareTo(
        caseAccessor(b.className),
      );
      if (accessor != 0) return accessor;
      final path = a.filePath.compareTo(b.filePath);
      if (path != 0) return path;
      return a.className.compareTo(b.className);
    });

  final groups = <String, List<ApiCaseSpec>>{};
  for (final apiCase in sortedCases) {
    if (!_validGroup.hasMatch(apiCase.group) ||
        _reservedWords.contains(apiCase.group)) {
      diagnostics.add(
        '${apiCase.sourceLocation}: ${apiCase.className} has invalid group '
        '"${apiCase.group}". Use lower_snake_case beginning with a letter.',
      );
      continue;
    }
    groups.putIfAbsent(apiCase.group, () => []).add(apiCase);
  }

  _validateGroupSymbols(groups, diagnostics);
  _validateCaseAccessors(groups, diagnostics);
  if (diagnostics.isNotEmpty) {
    return ApiCasesGenerateResult.failed(diagnostics);
  }

  final generatedClassNames = {
    'ApiCases',
    for (final group in groups.keys) groupClassName(group),
  };
  final aliases = _importAliases(sortedCases, generatedClassNames);
  final hasNonConstCase = sortedCases.any(
    (apiCase) => !apiCase.isConstConstructor,
  );
  final importedPaths = sortedCases.map((apiCase) => apiCase.importPath).toSet()
    ..remove(outputPath);
  final outputDirectory = p.dirname(outputPath);
  final importLines = <String>[];
  for (final importPath in importedPaths.toList()..sort()) {
    final relative =
        p.relative(importPath, from: outputDirectory).replaceAll(r'\', '/');
    final alias = aliases[importPath];
    importLines.add(
      alias == null ? "import '$relative';" : "import '$relative' as $alias;",
    );
  }

  final buffer = StringBuffer();
  if (importLines.isNotEmpty) {
    buffer
      ..writeln(importLines.join('\n'))
      ..writeln();
  }
  buffer
    ..writeln(
      hasNonConstCase
          ? 'final apiCases = ApiCases();'
          : 'const apiCases = ApiCases();',
    )
    ..writeln()
    ..writeln('class ApiCases {')
    ..writeln(hasNonConstCase ? '  ApiCases();' : '  const ApiCases();')
    ..writeln();

  for (final group in groups.keys.toList()..sort()) {
    final groupHasNonConstCase = groups[group]!.any(
      (apiCase) => !apiCase.isConstConstructor,
    );
    if (hasNonConstCase) {
      final constPrefix = groupHasNonConstCase ? '' : 'const ';
      buffer.writeln(
        '  late final ${groupClassName(group)} ${groupAccessor(group)} = '
        '$constPrefix${groupClassName(group)}();',
      );
    } else {
      buffer.writeln(
        '  ${groupClassName(group)} get ${groupAccessor(group)} => '
        'const ${groupClassName(group)}();',
      );
    }
  }

  final defaults =
      sortedCases.where((apiCase) => apiCase.defaultMethod != null).toList();
  final hasAsyncDefault = defaults.any(
    (apiCase) => apiCase.defaultMethod!.isAsync,
  );
  if (groups.isNotEmpty) buffer.writeln();
  if (hasAsyncDefault) {
    buffer.writeln('  Future<void> setUpDefaults() async {');
  } else {
    buffer.writeln('  void setUpDefaults() {');
  }
  for (final apiCase in defaults) {
    final prefix = apiCase.defaultMethod!.isAsync ? 'await ' : '';
    buffer.writeln(
      '    $prefix${groupAccessor(apiCase.group)}.'
      '${caseAccessor(apiCase.className)}.${apiCase.defaultMethod!.name}();',
    );
  }
  buffer
    ..writeln('  }')
    ..writeln('}')
    ..writeln();

  for (final group in groups.keys.toList()..sort()) {
    final groupHasNonConstCase = groups[group]!.any(
      (apiCase) => !apiCase.isConstConstructor,
    );
    buffer
      ..writeln('class ${groupClassName(group)} {')
      ..writeln(
        groupHasNonConstCase
            ? '  ${groupClassName(group)}();'
            : '  const ${groupClassName(group)}();',
      )
      ..writeln();
    for (final apiCase in groups[group]!) {
      final reference = _classReference(apiCase, aliases);
      if (apiCase.isConstConstructor) {
        buffer.writeln(
          '  $reference get ${caseAccessor(apiCase.className)} => '
          'const $reference();',
        );
      } else {
        buffer.writeln(
          '  late final $reference ${caseAccessor(apiCase.className)} = '
          '$reference();',
        );
      }
    }
    buffer
      ..writeln('}')
      ..writeln();
  }

  return ApiCasesGenerateResult.source(buffer.toString());
}

final _validGroup = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');

String groupClassName(String group) => '${_pascalCase(group)}Cases';

String groupAccessor(String group) => _camelCase(group);

String caseAccessor(String className) => className.isEmpty
    ? className
    : className[0].toLowerCase() + className.substring(1);

void _validateGroupSymbols(
  Map<String, List<ApiCaseSpec>> groups,
  List<String> diagnostics,
) {
  final classOwners = <String, String>{'ApiCases': '<root>'};
  final accessorOwners = <String, String>{'setUpDefaults': '<root method>'};
  for (final group in groups.keys.toList()..sort()) {
    final sourceLocation = groups[group]!.first.sourceLocation;
    final className = groupClassName(group);
    final previousClass = classOwners[className];
    if (previousClass != null) {
      diagnostics.add(
        '$sourceLocation: Groups "$previousClass" and "$group" both '
        'generate class '
        '"$className".',
      );
    } else {
      classOwners[className] = group;
    }

    final accessor = groupAccessor(group);
    final previousAccessor = accessorOwners[accessor];
    if (previousAccessor != null) {
      diagnostics.add(
        '$sourceLocation: Groups "$previousAccessor" and "$group" both '
        'generate ApiCases '
        'member "$accessor".',
      );
    } else {
      accessorOwners[accessor] = group;
    }
  }
}

void _validateCaseAccessors(
  Map<String, List<ApiCaseSpec>> groups,
  List<String> diagnostics,
) {
  for (final entry in groups.entries) {
    final owners = <String, ApiCaseSpec>{};
    for (final apiCase in entry.value) {
      final accessor = caseAccessor(apiCase.className);
      if (accessor.isEmpty || _reservedWords.contains(accessor)) {
        diagnostics.add(
          '${apiCase.sourceLocation}: ${apiCase.className} generates invalid '
          'accessor "$accessor".',
        );
        continue;
      }
      final previous = owners[accessor];
      if (previous != null) {
        diagnostics.add(
          '${apiCase.sourceLocation}: Group "${entry.key}" has duplicate '
          'generated accessor "$accessor" from ${previous.className} '
          '(${previous.sourceLocation}) and ${apiCase.className}.',
        );
      } else {
        owners[accessor] = apiCase;
      }
    }
  }
}

Map<String, String> _importAliases(
  List<ApiCaseSpec> cases,
  Set<String> generatedClassNames,
) {
  final classPaths = <String, Set<String>>{};
  for (final apiCase in cases) {
    classPaths
        .putIfAbsent(apiCase.className, () => <String>{})
        .add(apiCase.importPath);
  }

  final pathsToAlias = <String>{};
  for (final entry in classPaths.entries) {
    if (entry.value.length > 1 || generatedClassNames.contains(entry.key)) {
      pathsToAlias.addAll(entry.value);
    }
  }

  final sorted = pathsToAlias.toList()..sort();
  return {for (var i = 0; i < sorted.length; i++) sorted[i]: 'http_cases_$i'};
}

String _classReference(ApiCaseSpec apiCase, Map<String, String> aliases) {
  final alias = aliases[apiCase.importPath];
  return alias == null ? apiCase.className : '$alias.${apiCase.className}';
}

String _pascalCase(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => part[0].toUpperCase() + part.substring(1))
    .join();

String _camelCase(String value) {
  final pascal = _pascalCase(value);
  return pascal.isEmpty
      ? pascal
      : pascal[0].toLowerCase() + pascal.substring(1);
}
