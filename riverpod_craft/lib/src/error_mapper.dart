import 'package:flutter/foundation.dart';

/// Hook for converting a raw caught error into the error stored in a
/// provider's state.
///
/// By default providers expose errors as plain `Object` — [mapError] simply
/// returns the error unchanged. Configure a global `error_mapper` in
/// `riverpod_craft.yaml`:
///
/// ```yaml
/// error_mapper: lib/error_mapper.dart
/// ```
///
/// with a top-level `errorMapper` function:
///
/// ```dart
/// AppError errorMapper(Object error) {
///   if (error is DioException) return AppError.network(error);
///   return AppError.unknown(error);
/// }
/// ```
///
/// The code generator then overrides [mapError] in every generated notifier to
/// route caught errors through your `errorMapper`, so `state.error` holds your
/// custom type instead of a raw `Object`.
mixin ErrorMapper {
  /// Maps a raw caught [error] into the error stored in the provider's state.
  ///
  /// Returns the error unchanged unless overridden by a generated notifier
  /// wired to your global `errorMapper`.
  @protected
  Object mapError(Object error) => error;
}
