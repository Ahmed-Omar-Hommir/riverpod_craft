/// Example: your app's domain error type.
///
/// Instead of widgets receiving a raw `Object` error, the global error mapper
/// converts every caught error into one of these typed variants.
sealed class AppError {
  const AppError(this.message);

  /// A human-readable message describing the failure.
  final String message;
}

/// A network/connectivity failure.
class NetworkError extends AppError {
  const NetworkError(super.message);
}

/// A "not found" failure (e.g. HTTP 404).
class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

/// Any error that doesn't map to a more specific variant.
class UnknownError extends AppError {
  const UnknownError(super.message, this.cause);

  /// The original error object.
  final Object cause;
}
