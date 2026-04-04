import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/movie.dart';
import '../services/dio_client.dart';
import '../services/guest_session_service.dart';
import '../utils/http_utils.dart';

part 'trending_movies_provider.craft.dart';

@provider
class TrendingMovies extends _$TrendingMovies {
  @override
  Future<List<Movie>> create() async {
    final guestSessionId = await GuestSessionService.instance.getId();
    final response = await dio.get(
      '/trending/movie/week',
      queryParameters: {'guest_session_id': guestSessionId},
    );
    validateResponse(response);
    return (response.data['results'] as List)
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  @command
  @droppable
  Future<double> rateMovie({
    required int movieId,
    required double rating,
  }) async {
    final guestSessionId = await GuestSessionService.instance.getId();
    final res = await dio.post(
      '/movie/$movieId/rating',
      queryParameters: {'guest_session_id': guestSessionId},
      data: {'value': rating},
    );
    if (res.statusCode == 401) {
      await GuestSessionService.instance.clear();
      throw Exception('Guest session expired. Please try again.');
    }
    return rating;
  }
}
