import 'package:http_cases/http_cases.dart';

@ApiCase('cart')
class DeleteItemV1 {
  DeleteItemV1();

  @DefaultCase()
  Future<void> success() async {}

  void failed() {}
}
