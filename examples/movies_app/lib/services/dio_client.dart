import 'package:dio/dio.dart';

import '../config.dart';

/// Shared Dio instance — baseUrl and api_key are pre-configured.
/// validateStatus: true so callers can check status codes manually.
final dio = Dio(BaseOptions(
  baseUrl: baseUrl,
  queryParameters: {'api_key': tmdbApiKey},
  validateStatus: (_) => true,
));
