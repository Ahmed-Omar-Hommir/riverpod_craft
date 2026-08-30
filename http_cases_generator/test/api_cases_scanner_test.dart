import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:http_cases_generator/http_cases_generator.dart';
import 'package:test/test.dart';

ApiCasesScanResult _scan(String source, {String path = 'test/cases.dart'}) {
  final scanner = ApiCasesScanner();
  scanner.collectFromUnit(
    parseString(content: source, path: path, throwIfDiagnostics: false),
    path,
  );
  return scanner.result;
}

void main() {
  group('ApiCasesScanner', () {
    test('collects groups, sync defaults, async defaults, and no-default cases',
        () {
      final result = _scan('''
@ApiCase('cart')
class GetV1 {
  const GetV1();
  @DefaultCase()
  void success() {}
}

@api.ApiCase('cart')
class DeleteItemV1 {
  const DeleteItemV1();
  @api.DefaultCase()
  Future<void> success() async {}
}

@ApiCase('device_management')
class RefreshV1 {
  const RefreshV1();
  void failed() {}
}
''');

      expect(result.diagnostics, isEmpty);
      expect(
        result.cases.map((apiCase) => apiCase.group),
        ['cart', 'cart', 'device_management'],
      );
      expect(result.cases[0].defaultMethod?.name, 'success');
      expect(result.cases[0].defaultMethod?.isAsync, isFalse);
      expect(result.cases[1].defaultMethod?.isAsync, isTrue);
      expect(result.cases[2].defaultMethod, isNull);
    });

    test('allows optional default parameters', () {
      final result = _scan('''
@ApiCase('cart')
class GetV1 {
  const GetV1();
  @DefaultCase()
  void success({int statusCode = 200, String? label}) {}
}
''');

      expect(result.diagnostics, isEmpty);
    });

    test('accepts const, non-const, and implicit parameterless constructors',
        () {
      final result = _scan('''
@ApiCase('cart')
class ConstCase {
  const ConstCase();
}
@ApiCase('cart')
class NonConstCase {
  NonConstCase();
}
@ApiCase('cart')
class ImplicitCase {}
''');

      expect(result.diagnostics, isEmpty);
      expect(
        result.cases.map((apiCase) => apiCase.isConstConstructor),
        [true, false, false],
      );
      expect(result.cases.first.sourceLocation, 'test/cases.dart:2:7');
    });

    test('rejects multiple defaults and required parameters', () {
      final result = _scan('''
@ApiCase('cart')
class GetV1 {
  const GetV1();
  @DefaultCase()
  void success(int statusCode) {}
  @DefaultCase()
  void fallback() {}
}
''');

      expect(
        result.diagnostics,
        contains(contains('at most one @DefaultCase method')),
      );
      expect(
          result.diagnostics, contains(contains('must not require arguments')));
    });

    test('rejects unsupported constructors', () {
      for (final source in [
        "@ApiCase('cart') class Required { const Required(this.value); final int value; }",
        "@ApiCase('cart') class NamedOnly { const NamedOnly.value(); }",
        "@ApiCase('cart') class Optional { Optional([int? value]); }",
      ]) {
        final result = _scan(source);
        expect(
          result.diagnostics,
          contains(contains('unnamed parameterless constructor')),
          reason: source,
        );
      }
    });

    test('diagnostics include the exact method location', () {
      final result = _scan('''
@ApiCase('cart')
class GetV1 {
  const GetV1();
  @DefaultCase()
  void success(int statusCode) {}
}
''');

      expect(
        result.diagnostics.single,
        startsWith('test/cases.dart:5:8: GetV1.success'),
      );
    });

    test('rejects async void and generator defaults', () {
      final asyncVoid = _scan('''
@ApiCase('cart')
class AsyncVoid {
  const AsyncVoid();
  @DefaultCase()
  void success() async {}
}
''');
      final generator = _scan('''
@ApiCase('cart')
class Generator {
  const Generator();
  @DefaultCase()
  Iterable<int> success() sync* { yield 1; }
}
''');

      expect(asyncVoid.diagnostics, contains(contains('async void')));
      expect(generator.diagnostics, contains(contains('generator method')));
    });

    test('requires a single string group argument', () {
      for (final annotation in [
        '@ApiCase()',
        '@ApiCase(1)',
        "@ApiCase('a', 'b')"
      ]) {
        final result = _scan('''
$annotation
class Invalid {
  const Invalid();
}
''');
        expect(result.diagnostics, contains(contains('one string argument')));
      }
    });

    test('rejects DefaultCase on a non-method declaration', () {
      final result = _scan('''
@ApiCase('cart')
class Invalid {
  const Invalid();
  @DefaultCase()
  static const value = 1;
}
''');

      expect(result.diagnostics, contains(contains('non-method declaration')));
    });
  });
}
