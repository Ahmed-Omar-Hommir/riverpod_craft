import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:http_cases_generator/http_cases_generator.dart';
import 'package:test/test.dart';

void main() {
  test('imports an annotated part through its owning library', () {
    final previous = Directory.current;
    final temporary =
        Directory.systemTemp.createTempSync('http_cases_builder_');
    addTearDown(() {
      Directory.current = previous;
      temporary.deleteSync(recursive: true);
    });
    Directory.current = temporary;

    const libraryPath = 'test/http_cases/cart.dart';
    const partPath = 'test/http_cases/cart/get_v1.dart';
    final results = {
      libraryPath: parseString(
        content: "part 'cart/get_v1.dart';",
        path: libraryPath,
        throwIfDiagnostics: false,
      ),
      partPath: parseString(
        content: '''
part of '../cart.dart';
@ApiCase('cart')
class GetV1 {
  const GetV1();
}
''',
        path: partPath,
        throwIfDiagnostics: false,
      ),
    };

    HttpCasesBuilder(
      const ApiCasesConfig(
        output: 'test/http_cases/http_cases.craft.dart',
        scope: ['test/http_cases'],
      ),
    ).build(results);

    final output =
        File('test/http_cases/http_cases.craft.dart').readAsStringSync();
    expect(output, contains("import 'cart.dart';"));
    expect(output, isNot(contains("import 'cart/get_v1.dart';")));
  });

  test('rejects an output that can be scanned as user source', () {
    expect(
      () => HttpCasesBuilder(
        const ApiCasesConfig(output: 'test/http_cases.dart'),
      ).build(const {}),
      throwsA(
        isA<ApiCasesGenerationError>().having(
          (error) => error.toString(),
          'message',
          contains('must end with .craft.dart'),
        ),
      ),
    );
  });

  test('reports the location of an orphan annotated part', () {
    const path = 'test/http_cases/orphan.dart';
    final result = parseString(
      content: '''
part of 'missing.dart';
@ApiCase('cart')
class GetV1 {
  const GetV1();
}
''',
      path: path,
      throwIfDiagnostics: false,
    );

    expect(
      () => HttpCasesBuilder(
        const ApiCasesConfig(scope: ['test/http_cases']),
      ).build({path: result}),
      throwsA(
        isA<ApiCasesGenerationError>().having(
          (error) => error.toString(),
          'message',
          contains('$path:1:1:'),
        ),
      ),
    );
  });
}
