import 'package:flutter/foundation.dart';

/// Hook for converting a raw caught error into the typed error [F] stored in a
/// provider's state.
///
/// The error type [F] defaults to `Object` in generated code when no mapper is
/// configured, so [mapError] is the identity. Configure a global `error_mapper`
/// in `riverpod_craft.yaml`:
///
/// ```yaml
/// error_mapper: lib/error_mapper.dart
/// ```
///
/// with a top-level `errorMapper` function whose return type becomes [F]:
///
/// ```dart
/// AppError errorMapper(Object error) {
///   if (error is DioException) return AppError.network(error);
///   return AppError.unknown(error);
/// }
/// ```
///
/// The code generator then types every notifier as `... <Data, AppError, Arg>`
/// and overrides [mapError] to route caught errors through your `errorMapper`,
/// so `state.error` is `AppError` instead of a raw `Object`.
mixin ErrorMapper<F extends Object> {
  /// Maps a raw caught [error] into the typed error [F] stored in state.
  ///
  /// Returns the error unchanged (when `F` is `Object`) unless overridden by a
  /// generated notifier wired to your global `errorMapper`.
  @protected
  F mapError(Object error) => error as F;
}
