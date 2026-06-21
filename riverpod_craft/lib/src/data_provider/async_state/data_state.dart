part of 'async_state.dart';

/// Represents the state of an asynchronous data operation without arguments.
///
/// [F] is the error type — `Object` by default, or your custom type when a
/// global `error_mapper` is configured.
sealed class DataState<T, F>
    with EquatableMixin
    implements AsynchronousState<T, F, Record> {
  const DataState();

  /// Creates a loading state.
  const factory DataState.loading() = DataLoading<T, F>;

  /// Creates a success state with the given [data].
  const factory DataState.data(T data) = DataSuccess<T, F>;

  /// Creates an error state with the given [error].
  const factory DataState.error(F error) = DataError<T, F>;

  @override
  List<Object?> get props => [];
}

/// The loading substate of [DataState].
class DataLoading<T, F> extends DataState<T, F> {
  /// Creates a [DataLoading] instance.
  const DataLoading();

  @override
  String toString() => 'DataState<$T, $F>.loading()';

  @override
  List<Object?> get props => [];
}

/// The success substate of [DataState], holding the resulting data.
class DataSuccess<T, F> extends DataState<T, F> {
  /// The successfully loaded data.
  final T data;

  /// Creates a [DataSuccess] instance with the given [data].
  const DataSuccess(this.data);

  @override
  String toString() => 'DataState<$T, $F>.data(data: $data)';

  @override
  List<Object?> get props => [data];
}

/// The error substate of [DataState], holding the typed error object.
class DataError<T, F> extends DataState<T, F> {
  /// The error that occurred during the operation.
  final F error;

  /// Creates a [DataError] instance with the given [error].
  const DataError(this.error);

  @override
  String toString() => 'DataState<$T, $F>.error(error: $error)';

  @override
  List<Object?> get props => [error];
}

/// Convenience methods for pattern-matching and inspecting [DataState].
extension DataStateExtension<T, F> on DataState<T, F> {
  /// Calls the matching callback based on the current state.
  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(F error) error,
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
    R Function(F error)? error,
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
    R Function(F error)? error,
  }) {
    return switch (this) {
      DataLoading() => loading?.call(),
      DataSuccess(data: final d) => data?.call(d),
      DataError(error: final e) => error?.call(e),
    };
  }

  /// Calls the matching callback, passing the full substate object.
  R map<R>({
    required R Function(DataLoading<T, F> state) loading,
    required R Function(DataSuccess<T, F> state) data,
    required R Function(DataError<T, F> state) error,
  }) {
    return switch (this) {
      DataLoading<T, F>() && final s => loading(s),
      DataSuccess<T, F>() && final s => data(s),
      DataError<T, F>() && final s => error(s),
    };
  }

  /// Like [map], but unhandled states fall through to [orElse].
  R maybeMap<R>({
    R Function(DataLoading<T, F> state)? loading,
    R Function(DataSuccess<T, F> state)? data,
    R Function(DataError<T, F> state)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading<T, F>() && final s => loading != null ? loading(s) : orElse(),
      DataSuccess<T, F>() && final s => data != null ? data(s) : orElse(),
      DataError<T, F>() && final s => error != null ? error(s) : orElse(),
    };
  }

  /// Like [map], but returns `null` for unhandled states.
  R? mapOrNull<R>({
    R Function(DataLoading<T, F> state)? loading,
    R Function(DataSuccess<T, F> state)? data,
    R Function(DataError<T, F> state)? error,
  }) {
    return switch (this) {
      DataLoading<T, F>() && final s => loading?.call(s),
      DataSuccess<T, F>() && final s => data?.call(s),
      DataError<T, F>() && final s => error?.call(s),
    };
  }

  /// Whether this state is [DataLoading].
  bool get isLoading => this is DataLoading<T, F>;

  /// Whether this state is [DataSuccess].
  bool get isData => this is DataSuccess<T, F>;

  /// Whether this state is [DataError].
  bool get isError => this is DataError<T, F>;

  /// Returns the data if this is [DataSuccess], otherwise `null`.
  T? get dataOrNull =>
      this is DataSuccess<T, F> ? (this as DataSuccess<T, F>).data : null;

  /// Returns the error if this is [DataError], otherwise `null`.
  F? get errorOrNull =>
      this is DataError<T, F> ? (this as DataError<T, F>).error : null;
}
