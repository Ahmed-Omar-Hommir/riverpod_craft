import 'package:test/test.dart';

import 'http_cases/http_cases.craft.dart';

void main() {
  test('generated catalog exposes defaults and specific cases', () async {
    await apiCases.setUpDefaults();
    apiCases.cart.getV1.failed();
    apiCases.cart.deleteItemV1.failed();
  });
}
