import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit_craft/retrofit_craft.dart';

import '../../app/api/entries.dart';
import '../../app/api/versions.dart';

part 'auth_api_v3.g.dart';

@Api(entry: Entry.identity, version: Version.v3)
@RestApi()
abstract class AuthApiV3 {
  factory AuthApiV3(Dio dio, {String? baseUrl}) = _AuthApiV3;

  // The `v3/` segment now lives on `Version.v3.path`, so this is relative
  // and the leading slash is dropped.
  @POST('login')
  Future<void> login({
    required String phone,
    required String password,
    required String otp,
  });
}
