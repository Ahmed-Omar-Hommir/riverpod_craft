import 'package:http_cases_generator/http_cases_generator.dart';
import 'package:test/test.dart';

ApiCaseSpec _case(
  String className,
  String group,
  String path, {
  DefaultMethodSpec? defaultMethod,
  String? importPath,
  bool isConstConstructor = true,
  int line = 1,
  int column = 1,
}) =>
    ApiCaseSpec(
      className: className,
      filePath: path,
      importPath: importPath ?? path,
      group: group,
      isConstConstructor: isConstConstructor,
      line: line,
      column: column,
      defaultMethod: defaultMethod,
    );

String _normalized(String value) =>
    value.replaceAll(RegExp(r'\s+'), ' ').trim();

void main() {
  group('naming', () {
    test('converts required group and class forms', () {
      expect(groupClassName('cart'), 'CartCases');
      expect(groupAccessor('cart'), 'cart');
      expect(groupClassName('device_management'), 'DeviceManagementCases');
      expect(groupAccessor('device_management'), 'deviceManagement');
      expect(caseAccessor('GetV1'), 'getV1');
      expect(caseAccessor('DeleteItemV1'), 'deleteItemV1');
    });
  });

  group('generateApiCases', () {
    test('generates groups and only invokes declared defaults', () {
      final result = generateApiCases(
        cases: [
          _case(
            'GetV1',
            'cart',
            'test/http_cases/cart/get_v1.dart',
            defaultMethod: const DefaultMethodSpec(
              name: 'success',
              isAsync: false,
            ),
          ),
          _case(
            'DeleteItemV1',
            'cart',
            'test/http_cases/cart/delete_item_v1.dart',
          ),
          _case(
            'RefreshV1',
            'device_management',
            'test/http_cases/devices/refresh_v1.dart',
          ),
        ],
        outputPath: 'test/http_cases/http_cases.craft.dart',
      );

      expect(result.success, isTrue, reason: result.diagnostics.toString());
      final source = _normalized(result.source!);
      expect(source, contains('const apiCases = ApiCases();'));
      expect(source, contains('CartCases get cart => const CartCases();'));
      expect(
        source,
        contains(
          'DeviceManagementCases get deviceManagement => const DeviceManagementCases();',
        ),
      );
      expect(
          source, contains('void setUpDefaults() { cart.getV1.success(); }'));
      expect(
        source,
        contains('DeleteItemV1 get deleteItemV1 => const DeleteItemV1();'),
      );
      expect(source, isNot(contains('deleteItemV1.success')));
    });

    test('awaits only asynchronous defaults', () {
      final result = generateApiCases(
        cases: [
          _case(
            'SyncV1',
            'cart',
            'test/sync.dart',
            defaultMethod: const DefaultMethodSpec(
              name: 'success',
              isAsync: false,
            ),
          ),
          _case(
            'AsyncV1',
            'cart',
            'test/async.dart',
            defaultMethod: const DefaultMethodSpec(
              name: 'success',
              isAsync: true,
            ),
          ),
        ],
        outputPath: 'test/catalog.craft.dart',
      );

      final source = _normalized(result.source!);
      expect(source, contains('Future<void> setUpDefaults() async {'));
      expect(source, contains('await cart.asyncV1.success();'));
      expect(source, contains('cart.syncV1.success();'));
      expect(source, isNot(contains('await cart.syncV1.success();')));
    });

    test('caches non-const cases and their groups', () {
      final result = generateApiCases(
        cases: [
          _case('StatusV1', 'auth', 'test/auth/status.dart'),
          _case('GetV1', 'cart', 'test/cart/get.dart'),
          _case(
            'MutableV1',
            'cart',
            'test/cart/mutable.dart',
            isConstConstructor: false,
          ),
        ],
        outputPath: 'test/http_cases.craft.dart',
      );

      expect(result.success, isTrue, reason: result.diagnostics.toString());
      final source = _normalized(result.source!);
      expect(source, contains('final apiCases = ApiCases();'));
      expect(source, contains('class ApiCases { ApiCases();'));
      expect(
        source,
        contains('late final AuthCases auth = const AuthCases();'),
      );
      expect(source, contains('late final CartCases cart = CartCases();'));
      expect(source, contains('class CartCases { CartCases();'));
      expect(source, contains('GetV1 get getV1 => const GetV1();'));
      expect(
        source,
        contains('late final MutableV1 mutableV1 = MutableV1();'),
      );
    });

    test('aliases identical class names from different libraries', () {
      final result = generateApiCases(
        cases: [
          _case('StatusV1', 'cart', 'test/cart/status.dart'),
          _case('StatusV1', 'devices', 'test/devices/status.dart'),
        ],
        outputPath: 'test/http_cases.craft.dart',
      );

      expect(result.success, isTrue, reason: result.diagnostics.toString());
      expect(
        result.source,
        contains("import 'cart/status.dart' as http_cases_0;"),
      );
      expect(
        result.source,
        contains("import 'devices/status.dart' as http_cases_1;"),
      );
      expect(result.source, contains('http_cases_0.StatusV1 get statusV1'));
      expect(result.source, contains('http_cases_1.StatusV1 get statusV1'));
    });

    test('is deterministic regardless of input order', () {
      final cases = [
        _case('ZetaV1', 'zeta', 'test/zeta.dart'),
        _case('BetaV1', 'alpha', 'test/beta.dart'),
        _case('AlphaV1', 'alpha', 'test/alpha.dart'),
      ];

      final first = generateApiCases(
        cases: cases,
        outputPath: 'test/http_cases.craft.dart',
      );
      final second = generateApiCases(
        cases: cases.reversed.toList(),
        outputPath: 'test/http_cases.craft.dart',
      );

      expect(first.source, second.source);
      expect(first.source!.indexOf('AlphaV1 get'),
          lessThan(first.source!.indexOf('BetaV1 get')));
    });

    test('rejects invalid groups and duplicate accessors', () {
      final invalid = generateApiCases(
        cases: [_case('GetV1', 'Device Management', 'test/get.dart')],
        outputPath: 'test/http_cases.craft.dart',
      );
      final duplicate = generateApiCases(
        cases: [
          _case('GetV1', 'cart', 'test/one.dart'),
          _case('GetV1', 'cart', 'test/two.dart'),
        ],
        outputPath: 'test/http_cases.craft.dart',
      );

      expect(invalid.diagnostics, contains(contains('invalid group')));
      expect(invalid.diagnostics.single, startsWith('test/get.dart:1:1:'));
      expect(
        duplicate.diagnostics,
        contains(contains('duplicate generated accessor')),
      );
    });

    test('rejects conflicting generated group symbols', () {
      final rootConflict = generateApiCases(
        cases: [_case('GetV1', 'api', 'test/get.dart')],
        outputPath: 'test/http_cases.craft.dart',
      );
      final normalizedConflict = generateApiCases(
        cases: [
          _case('One', 'foo1', 'test/one.dart'),
          _case('Two', 'foo_1', 'test/two.dart'),
        ],
        outputPath: 'test/http_cases.craft.dart',
      );
      final memberConflict = generateApiCases(
        cases: [_case('GetV1', 'set_up_defaults', 'test/get.dart')],
        outputPath: 'test/http_cases.craft.dart',
      );

      expect(rootConflict.diagnostics,
          contains(contains('generate class "ApiCases"')));
      expect(normalizedConflict.diagnostics,
          contains(contains('generate class "Foo1Cases"')));
      expect(memberConflict.diagnostics,
          contains(contains('member "setUpDefaults"')));
    });

    test('generates an empty but usable catalog when no cases exist', () {
      final result = generateApiCases(
        cases: const [],
        outputPath: 'test/http_cases.craft.dart',
      );

      expect(result.success, isTrue);
      expect(
        _normalized(result.source!),
        contains(
            'class ApiCases { const ApiCases(); void setUpDefaults() { } }'),
      );
    });
  });
}
