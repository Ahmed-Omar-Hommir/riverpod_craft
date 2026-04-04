import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/movie.dart';
import '../services/dio_client.dart';
import '../utils/http_utils.dart';

part 'now_playing_provider.craft.dart';

@provider
Stream<List<Movie>> nowPlaying(Ref ref) async* {
  while (true) {
    final response = await dio.get('/movie/now_playing');
    validateResponse(response);
    yield (response.data['results'] as List)
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
    await Future.delayed(const Duration(seconds: 30));
  }
}
