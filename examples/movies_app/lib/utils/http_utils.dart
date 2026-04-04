import 'package:dio/dio.dart';

import '../exceptions/api_exception.dart';

void validateResponse(Response response) {
  if (response.statusCode == 401) {
    throw const InvalidApiKeyException(
      'Invalid or expired API key. '
      'Update tmdbApiKey in lib/config.dart.',
    );
  }
}
