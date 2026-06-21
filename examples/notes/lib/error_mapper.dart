import 'models/app_error.dart';

/// Global mapper: converts any raw caught error into your typed [AppError].
///
/// Configure in riverpod_craft.yaml:
///   error_mapper: lib/error_mapper.dart
///
/// The code generator inlines this function into every generated provider and
/// routes caught errors through it, so `state.error` is your [AppError] type
/// instead of a raw `Object`.
///
/// NOTE: this function is copied verbatim into each `.craft.dart` part file, so
/// it may only reference symbols importable from your provider files (here:
/// `AppError`). Keep it free of imports your providers don't already have.
AppError errorMapper(Object error) {
  final text = error.toString();
  if (text.contains('SocketException') || text.contains('Failed host lookup')) {
    return const NetworkError('No internet connection');
  }
  if (text.contains('404') || text.contains('Not Found')) {
    return const NotFoundError('The requested note was not found');
  }
  return UnknownError(text, error);
}
