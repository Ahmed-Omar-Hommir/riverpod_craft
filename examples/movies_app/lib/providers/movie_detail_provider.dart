import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/movie.dart';
import '../services/dio_client.dart';
import '../utils/http_utils.dart';

part 'movie_detail_provider.craft.dart';

@provider
Future<Movie> movieDetail(Ref ref, {required int id}) async {
  final response = await dio.get('/movie/$id');
  validateResponse(response);
  final data = Map<String, dynamic>.from(response.data as Map);
  // The detail endpoint uses 'genres' array instead of 'genre_ids'
  data['genre_ids'] = (data['genres'] as List<dynamic>?)
          ?.map((g) => (g as Map<String, dynamic>)['id'] as int)
          .toList() ??
      [];
  return Movie.fromJson(data);
}
