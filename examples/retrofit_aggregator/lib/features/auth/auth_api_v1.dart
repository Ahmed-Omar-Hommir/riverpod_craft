import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit_craft/retrofit_craft.dart';

import '../../app/api/entries.dart';
import '../../app/api/versions.dart';

part 'auth_api_v1.g.dart';

@Api(entry: Entry.identity, version: Version.v1)
@RestApi()
abstract class AuthApiV1 {
  factory AuthApiV1(Dio dio, {String? baseUrl}) = _AuthApiV1;

  // Path is relative to the per-version baseUrl
  // (`https://identity.example.com/api/v1/`), so no leading `/`.
  @POST('login')
  Future<void> login({
    required String phone,
    required String password,
  });
}
