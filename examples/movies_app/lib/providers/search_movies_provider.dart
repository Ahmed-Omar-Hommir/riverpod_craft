import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/movie.dart';
import '../services/dio_client.dart';
import '../utils/http_utils.dart';

part 'search_movies_provider.craft.dart';

@command
@restartable
Future<List<Movie>> searchMovies(Ref ref, {required String query}) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final response = await dio.get(
    '/search/movie',
    queryParameters: {'query': query},
  );
  validateResponse(response);
  return (response.data['results'] as List)
      .map((e) => Movie.fromJson(e as Map<String, dynamic>))
      .toList();
}
