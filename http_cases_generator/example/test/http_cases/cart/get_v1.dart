import 'package:http_cases/http_cases.dart';

@ApiCase('cart')
class GetV1 {
  const GetV1();

  @DefaultCase()
  void success() {}

  void failed() {}
}
