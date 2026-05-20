import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit_craft/retrofit_craft.dart';

import '../../app/api/entries.dart';
import '../../app/api/versions.dart';

part 'order_api.g.dart';

@Api(entry: Entry.consumer, version: Version.v2)
@RestApi()
abstract class OrderApi {
  factory OrderApi(Dio dio, {String? baseUrl}) = _OrderApi;

  // `v2/` lives on `Version.v2.path` now; method path is relative.
  @POST('checkout')
  Future<void> checkout(@Body() Map<String, dynamic> cart);
}
