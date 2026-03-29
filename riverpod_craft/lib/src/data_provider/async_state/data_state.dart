part of 'async_state.dart';

sealed class DataState<T, E extends Object = Object>
    with EquatableMixin
    implements AsynchronousState<T, Record> {
  const DataState();

  const factory DataState.loading() = DataLoading<T, E>;
  const factory DataState.data(T data) = DataSuccess<T, E>;
  const factory DataState.error(E error) = DataError<T, E>;

  @override
  List<Object?> get props => [];
}

class DataLoading<T, E extends Object = Object> extends DataState<T, E> {
  const DataLoading();

  @override
  String toString() => 'DataState<$T>.loading()';

  @override
  List<Object?> get props => [];
}

class DataSuccess<T, E extends Object = Object> extends DataState<T, E> {
  final T data;
  const DataSuccess(this.data);

  @override
  String toString() => 'DataState<$T>.data(data: $data)';

  @override
  List<Object?> get props => [data];
}

class DataError<T, E extends Object = Object> extends DataState<T, E> {
  final E error;
  const DataError(this.error);

  @override
  String toString() => 'DataState<$T>.error(error: $error)';

  @override
  List<Object?> get props => [error];
}

extension DataStateExtension<T, E extends Object> on DataState<T, E> {
  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(E error) error,
  }) {
    return switch (this) {
      DataLoading() => loading(),
      DataSuccess(data: final d) => data(d),
      DataError(error: final e) => error(e),
    };
  }

  R maybeWhen<R>({
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading() => loading != null ? loading() : orElse(),
      DataSuccess(data: final d) => data != null ? data(d) : orElse(),
      DataError(error: final e) => error != null ? error(e) : orElse(),
    };
  }

  R? whenOrNull<R>({
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
  }) {
    return switch (this) {
      DataLoading() => loading?.call(),
      DataSuccess(data: final d) => data?.call(d),
      DataError(error: final e) => error?.call(e),
    };
  }

  bool get isLoading => this is DataLoading<T, E>;
  bool get isData => this is DataSuccess<T, E>;
  bool get isError => this is DataError<T, E>;

  T? get dataOrNull =>
      this is DataSuccess<T, E> ? (this as DataSuccess<T, E>).data : null;
  E? get errorOrNull =>
      this is DataError<T, E> ? (this as DataError<T, E>).error : null;
}
