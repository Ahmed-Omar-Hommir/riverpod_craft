import 'package:shared_preferences/shared_preferences.dart';

import '../utils/http_utils.dart';
import 'dio_client.dart';

/// Manages a TMDB guest session ID.
///
/// Priority: in-memory cache → SharedPreferences → new API call.
/// A new session is only created when none is stored.
class GuestSessionService {
  GuestSessionService._();
  static final instance = GuestSessionService._();

  static const _prefsKey = 'tmdb_guest_session_id';

  String? _cached;

  /// Returns the stored guest session ID, creating and persisting one if needed.
  Future<String> getId() async {
    if (_cached != null) return _cached!;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      _cached = stored;
      return stored;
    }

    final response = await dio.get('/authentication/guest_session/new');
    validateResponse(response);

    final id = response.data['guest_session_id'] as String;
    await prefs.setString(_prefsKey, id);
    _cached = id;
    return id;
  }

  /// Returns the stored session ID without creating one.
  /// Returns null if no session has been created yet.
  Future<String?> getStoredId() async {
    if (_cached != null) return _cached;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  /// Clears the cached session (e.g. if TMDB returns 401 on a rating call).
  Future<void> clear() async {
    _cached = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
