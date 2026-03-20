part of 'async_state.dart';

sealed class DataState<T>
    with EquatableMixin
    implements AsynchronousState<T, Record> {
  const DataState();

  const factory DataState.loading() = DataLoading<T>;
  const factory DataState.data(T data) = DataSuccess<T>;
  const factory DataState.error(Object error) = DataError<T>;

  @override
  List<Object?> get props => [];
}

class DataLoading<T> extends DataState<T> {
  const DataLoading();

  @override
  String toString() => 'DataState<$T>.loading()';

  @override
  List<Object?> get props => [];
}

class DataSuccess<T> extends DataState<T> {
  final T data;
  const DataSuccess(this.data);

  @override
  String toString() => 'DataState<$T>.data(data: $data)';

  @override
  List<Object?> get props => [data];
}

class DataError<T> extends DataState<T> {
  final Object error;
  const DataError(this.error);

  @override
  String toString() => 'DataState<$T>.error(error: $error)';

  @override
  List<Object?> get props => [error];
}

extension DataStateExtension<T> on DataState<T> {
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

  bool get isLoading => this is DataLoading<T>;
  bool get isData => this is DataSuccess<T>;
  bool get isError => this is DataError<T>;

  T? get dataOrNull =>
      this is DataSuccess<T> ? (this as DataSuccess<T>).data : null;
  Object? get errorOrNull =>
      this is DataError<T> ? (this as DataError<T>).error : null;
}
