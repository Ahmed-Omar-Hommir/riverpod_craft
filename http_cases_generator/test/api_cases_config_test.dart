import 'package:http_cases_generator/http_cases_generator.dart';
import 'package:test/test.dart';

void main() {
  test('uses test-oriented defaults', () {
    final config = ApiCasesConfig.fromOptions(const {});

    expect(config.output, 'test/http_cases.craft.dart');
    expect(config.scope, ['lib', 'test']);
  });

  test('reads output and scope', () {
    final config = ApiCasesConfig.fromOptions({
      'output': 'test/http_cases/http_cases.craft.dart',
      'scope': ['test/http_cases'],
    });

    expect(config.output, 'test/http_cases/http_cases.craft.dart');
    expect(config.scope, ['test/http_cases']);
  });
}
