/// A sealed union representing either a successful value or an error.
sealed class Result<T> {
  /// Creates a [Result].
  const Result();

  /// Creates a successful [Result] containing [value].
  factory Result.ok(T value) => Ok(value);

  /// Creates an error [Result] containing [error].
  factory Result.error(Object error) => Error(error);

  /// Returns the value if this is [Ok], otherwise throws.
  T get valOrThrow {
    if (this is Ok<T>) {
      return (this as Ok<T>).value;
    } else if (this is Error<T>) {
      throw (this as Error<T>);
    } else {
      throw Exception('Unknown Result type');
    }
  }
}

/// A successful [Result] containing a [value].
final class Ok<T> extends Result<T> {
  /// Creates an [Ok] result with the given [value].
  const Ok(this.value);

  /// The success value.
  final T value;
}

/// An error [Result] containing an [error] object.
final class Error<T> extends Result<T> {
  /// Creates an [Error] result with the given [error].
  const Error(this.error);

  /// The error object.
  final dynamic error;
}

/// Convenience getters for synchronous [Result] access.
extension ResultValueOrError<T> on Result<T> {
  /// Returns the value if Ok, otherwise returns null.
  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;

  /// Returns the error if Error, otherwise returns null.
  dynamic get errorOrNull => this is Error<T> ? (this as Error<T>).error : null;

  /// Returns true if this is Ok.
  bool get isOk => this is Ok<T>;

  /// Returns true if this is Error.
  bool get isError => this is Error<T>;
}

// Extensions for Future/Stream of Result to access value or error

/// Convenience getters for `Future<Result>` access.
extension FutureResultAccess<T> on Future<Result<T>> {
  /// Awaits the result and returns the value, or throws if error.
  Future<T> get valueOrThrow async {
    final result = await this;
    return result.valOrThrow;
  }

  /// Awaits the result and returns the value, or null if error.
  Future<T?> get valueOrNull async {
    final result = await this;
    return result.valueOrNull;
  }

  /// Awaits the result and returns the error, or null if ok.
  Future<dynamic> get errorOrNull async {
    final result = await this;
    return result.errorOrNull;
  }
}

/// Convenience getters for `Stream<Result>` access.
extension StreamResultAccess<T> on Stream<Result<T>> {
  /// Emits only the value from Ok results, throws if Error.
  Stream<T> get valueOrThrow async* {
    await for (final result in this) {
      if (result is Ok<T>) {
        yield result.value;
      } else if (result is Error<T>) {
        throw result.error;
      } else {
        throw StateError('Unknown Result type');
      }
    }
  }

  /// Emits the value if Ok, otherwise emits null.
  Stream<T?> get valueOrNull async* {
    await for (final result in this) {
      yield result.valueOrNull;
    }
  }

  /// Emits the error if Error, otherwise emits null.
  Stream<dynamic> get errorOrNull async* {
    await for (final result in this) {
      yield result.errorOrNull;
    }
  }
}
