part of 'async_state.dart';

/// Represents the state of an asynchronous data operation without arguments.
sealed class DataState<T>
    with EquatableMixin
    implements AsynchronousState<T, Record> {
  const DataState();

  /// Creates a loading state.
  const factory DataState.loading() = DataLoading<T>;

  /// Creates a success state with the given [data].
  const factory DataState.data(T data) = DataSuccess<T>;

  /// Creates an error state with the given [error].
  const factory DataState.error(Object error) = DataError<T>;

  @override
  List<Object?> get props => [];
}

/// The loading substate of [DataState].
class DataLoading<T> extends DataState<T> {
  /// Creates a [DataLoading] instance.
  const DataLoading();

  @override
  String toString() => 'DataState<$T>.loading()';

  @override
  List<Object?> get props => [];
}

/// The success substate of [DataState], holding the resulting data.
class DataSuccess<T> extends DataState<T> {
  /// The successfully loaded data.
  final T data;

  /// Creates a [DataSuccess] instance with the given [data].
  const DataSuccess(this.data);

  @override
  String toString() => 'DataState<$T>.data(data: $data)';

  @override
  List<Object?> get props => [data];
}

/// The error substate of [DataState], holding the error object.
class DataError<T> extends DataState<T> {
  /// The error that occurred during the operation.
  final Object error;

  /// Creates a [DataError] instance with the given [error].
  const DataError(this.error);

  @override
  String toString() => 'DataState<$T>.error(error: $error)';

  @override
  List<Object?> get props => [error];
}

/// Convenience methods for pattern-matching and inspecting [DataState].
extension DataStateExtension<T> on DataState<T> {
  /// Calls the matching callback based on the current state.
  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
  }) {
    return switch (this) {
      DataLoading() => loading(),
      DataSuccess(data: final d) => data(d),
      DataError(error: final e) => error(e),
    };
  }

  /// Like [when], but unhandled states fall through to [orElse].
  R maybeWhen<R>({
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading() => loading != null ? loading() : orElse(),
      DataSuccess(data: final d) => data != null ? data(d) : orElse(),
      DataError(error: final e) => error != null ? error(e) : orElse(),
    };
  }

  /// Like [when], but returns `null` for unhandled states.
  R? whenOrNull<R>({
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error)? error,
  }) {
    return switch (this) {
      DataLoading() => loading?.call(),
      DataSuccess(data: final d) => data?.call(d),
      DataError(error: final e) => error?.call(e),
    };
  }

  /// Calls the matching callback, passing the full substate object.
  R map<R>({
    required R Function(DataLoading<T> state) loading,
    required R Function(DataSuccess<T> state) data,
    required R Function(DataError<T> state) error,
  }) {
    return switch (this) {
      DataLoading<T>() && final s => loading(s),
      DataSuccess<T>() && final s => data(s),
      DataError<T>() && final s => error(s),
    };
  }

  /// Like [map], but unhandled states fall through to [orElse].
  R maybeMap<R>({
    R Function(DataLoading<T> state)? loading,
    R Function(DataSuccess<T> state)? data,
    R Function(DataError<T> state)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading<T>() && final s => loading != null ? loading(s) : orElse(),
      DataSuccess<T>() && final s => data != null ? data(s) : orElse(),
      DataError<T>() && final s => error != null ? error(s) : orElse(),
    };
  }

  /// Like [map], but returns `null` for unhandled states.
  R? mapOrNull<R>({
    R Function(DataLoading<T> state)? loading,
    R Function(DataSuccess<T> state)? data,
    R Function(DataError<T> state)? error,
  }) {
    return switch (this) {
      DataLoading<T>() && final s => loading?.call(s),
      DataSuccess<T>() && final s => data?.call(s),
      DataError<T>() && final s => error?.call(s),
    };
  }

  /// Whether this state is [DataLoading].
  bool get isLoading => this is DataLoading<T>;

  /// Whether this state is [DataSuccess].
  bool get isData => this is DataSuccess<T>;

  /// Whether this state is [DataError].
  bool get isError => this is DataError<T>;

  /// Returns the data if this is [DataSuccess], otherwise `null`.
  T? get dataOrNull =>
      this is DataSuccess<T> ? (this as DataSuccess<T>).data : null;

  /// Returns the error if this is [DataError], otherwise `null`.
  Object? get errorOrNull =>
      this is DataError<T> ? (this as DataError<T>).error : null;
}
