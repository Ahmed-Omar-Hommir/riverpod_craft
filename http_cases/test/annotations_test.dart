import 'package:http_cases/http_cases.dart';
import 'package:test/test.dart';

void main() {
  test('ApiCase stores its group', () {
    expect(const ApiCase('cart').group, 'cart');
  });

  test('DefaultCase is const constructible', () {
    expect(const DefaultCase(), isA<DefaultCase>());
  });
}
