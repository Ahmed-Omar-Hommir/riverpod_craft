import 'package:riverpod_craft/riverpod_craft.dart';

import '../services/dio_client.dart';
import '../services/guest_session_service.dart';
import '../utils/http_utils.dart';

part 'guest_ratings_provider.craft.dart';

@provider
Future<Map<int, double>> guestRatings(Ref ref) async {
  final sessionId = await GuestSessionService.instance.getStoredId();
  if (sessionId == null) return {};

  final response = await dio.get('/guest_session/$sessionId/rated/movies');
  validateResponse(response);

  return {
    for (final movie in response.data['results'] as List)
      (movie['id'] as int): (movie['rating'] as num).toDouble(),
  };
}
