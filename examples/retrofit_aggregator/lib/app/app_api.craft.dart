// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering,unnecessary_import,library_private_types_in_public_api
import 'package:dio/dio.dart';
import 'api/entries.dart';
import 'api/versions.dart';
import '../features/auth/auth_api_v1.dart';
import '../features/auth/auth_api_v3.dart';
import '../features/health/health_api.dart';
import '../features/order/order_api.dart';

class AppApi {
  AppApi({required this.dio});
  final Dio dio;

  late final consumer = _ConsumerEntry(dio);
  late final identity = _IdentityEntry(dio);
}

class _ConsumerEntry {
  _ConsumerEntry(this._dio);
  final Dio _dio;

  late final order = _ConsumerOrderVersions(_dio);
}

class _ConsumerOrderVersions {
  _ConsumerOrderVersions(this._dio);
  final Dio _dio;

  late final v2 = OrderApi(
    _dio,
    baseUrl: '${Entry.consumer.baseUrl}${Version.v2.path}',
  );
}

class _IdentityEntry {
  _IdentityEntry(this._dio);
  final Dio _dio;

  late final auth = _IdentityAuthVersions(_dio);
  late final health = HealthApi(_dio, baseUrl: Entry.identity.baseUrl);
}

class _IdentityAuthVersions {
  _IdentityAuthVersions(this._dio);
  final Dio _dio;

  late final v1 = AuthApiV1(
    _dio,
    baseUrl: '${Entry.identity.baseUrl}${Version.v1.path}',
  );
  late final v3 = AuthApiV3(
    _dio,
    baseUrl: '${Entry.identity.baseUrl}${Version.v3.path}',
  );
}
