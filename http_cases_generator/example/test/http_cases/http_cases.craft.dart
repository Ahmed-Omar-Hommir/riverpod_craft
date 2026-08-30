// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering

import 'cart/delete_item_v1.dart';
import 'cart/get_v1.dart';

final apiCases = ApiCases();

class ApiCases {
  ApiCases();

  late final CartCases cart = CartCases();

  Future<void> setUpDefaults() async {
    await cart.deleteItemV1.success();
    cart.getV1.success();
  }
}

class CartCases {
  CartCases();

  late final DeleteItemV1 deleteItemV1 = DeleteItemV1();
  GetV1 get getV1 => const GetV1();
}
