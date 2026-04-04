import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/movie.dart';
import '../services/dio_client.dart';
import '../utils/http_utils.dart';

part 'popular_movies_provider.craft.dart';

@provider
class PopularMovies extends _$PopularMovies {
  @override
  Paged<Movie> create(int page, {required int? genreId}) async {
    final response = await dio.get(
      '/discover/movie',
      queryParameters: {
        'page': page,
        'sort_by': 'popularity.desc',
        if (genreId != null) 'with_genres': genreId,
      },
    );
    validateResponse(response);
    final data = response.data;
    return PaginatedResponse(
      results: (data['results'] as List)
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: data['page'] as int,
      total: data['total_results'] as int,
      lastPage: data['total_pages'] as int,
      pageSize: 20,
    );
  }
}
