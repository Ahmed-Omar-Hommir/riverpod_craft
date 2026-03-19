sealed class Result<T> {
  const Result();

  factory Result.ok(T value) => Ok(value);

  factory Result.error(Object error) => Error(error);

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

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.error);

  final dynamic error;
}

// Extensions for Result to access value or exception

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

extension FutureResultAccess<T> on Future<Result<T>> {
  Future<T> get valueOrThrow async {
    final result = await this;
    return result.valOrThrow;
  }

  Future<T?> get valueOrNull async {
    final result = await this;
    return result.valueOrNull;
  }

  Future<dynamic> get errorOrNull async {
    final result = await this;
    return result.errorOrNull;
  }
}

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
