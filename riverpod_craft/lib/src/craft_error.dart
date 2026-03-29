/// Typed error wrapper for providers with `@ErrorResult`.
///
/// When a provider declares `@ErrorResult(MyError)`, all caught exceptions
/// are wrapped: known errors become [Expected], unknown become [Unexpected].
///
/// ```dart
/// error: (e) => switch(e) {
///   Expected(:final error) => Text(error.message), // typed!
///   Unexpected(:final error) => Text('Unexpected: $error'),
/// }
/// ```
sealed class CraftError<E> {
  const CraftError();
}

/// The error matches the declared `@ErrorResult` type.
class Expected<E> extends CraftError<E> {
  const Expected(this.error);

  /// The typed error value.
  final E error;

  @override
  String toString() => 'Expected($error)';
}

/// The error does NOT match the declared type — an unexpected failure.
class Unexpected<E> extends CraftError<E> {
  const Unexpected(this.error, [this.stackTrace]);

  /// The raw error object.
  final Object error;

  /// Stack trace from the original throw, if available.
  final StackTrace? stackTrace;

  @override
  String toString() => 'Unexpected($error)';
}

/// Convenience extensions on [CraftError].
extension CraftErrorX<E> on CraftError<E> {
  /// Returns the typed error if [Expected], otherwise `null`.
  E? get expectedOrNull => switch (this) {
    Expected(:final error) => error,
    _ => null,
  };

  /// Whether this is an expected (declared) error.
  bool get isExpected => this is Expected<E>;

  /// Whether this is an unexpected error.
  bool get isUnexpected => this is Unexpected<E>;
}
