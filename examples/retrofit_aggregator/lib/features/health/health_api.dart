import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit_craft/retrofit_craft.dart';

import '../../app/api/entries.dart';

part 'health_api.g.dart';

// No `version:` argument => no version layer in the generated aggregator;
// accessible as `api.identity.health.check()` directly.
@Api(entry: Entry.identity)
@RestApi()
abstract class HealthApi {
  factory HealthApi(Dio dio, {String? baseUrl}) = _HealthApi;

  @GET('/health')
  Future<void> check();
}
