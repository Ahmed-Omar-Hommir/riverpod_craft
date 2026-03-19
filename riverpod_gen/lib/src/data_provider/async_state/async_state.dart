import 'package:riverpod_gen/riverpod_gen.dart';
import 'package:equatable/equatable.dart';
part 'data_state.dart';
part 'command_state.dart';
part 'arg_command_state.dart';

sealed class AsynchronousState<T, ArgT extends Record> with EquatableMixin {
  const AsynchronousState();

  @override
  List<Object?> get props => [];
}

extension AsynchronousStateExtension<T, ArgT extends Record>
    on AsynchronousState<T, ArgT> {
  bool get isLoading => switch (this) {
    DataLoading<T>() => true,
    CommandLoading<T, ArgT>() => true,
    ArgCommandLoading<T, Record>() => true,
    _ => false,
  };

  bool get isData => switch (this) {
    DataSuccess<T>() => true,
    CommandData<T, ArgT>() => true,
    ArgCommandData<T, Record>() => true,
    _ => false,
  };

  bool get isError => switch (this) {
    DataError<T>() => true,
    CommandError<T, ArgT>() => true,
    ArgCommandError<T, Record>() => true,
    _ => false,
  };

  T? get data => switch (this) {
    DataSuccess<T>(data: final data) => data,
    CommandData<T, ArgT>(data: final data) => data,
    ArgCommandData<T, Record>(data: final data) => data,
    _ => null,
  };

  Object? get error => switch (this) {
    DataError<T>(error: final error) => error,
    CommandError<T, ArgT>(error: final error) => error,
    ArgCommandError<T, Record>(error: final error) => error,
    _ => null,
  };

  R when<R>({
    required R Function() init,
    required R Function(ArgT? arg) loading,
    required R Function(ArgT? arg, T data) data,
    required R Function(ArgT? arg, Object error) error,
  }) {
    return switch (this) {
      DataLoading<T>() => loading(null),
      DataSuccess<T>(data: final dataValue) => data(null, dataValue),
      DataError<T>(error: final errorValue) => error(null, errorValue),
      CommandInit<T, ArgT>() => init(),
      CommandLoading<T, ArgT>() => loading(null),
      CommandData<T, ArgT>(data: final dataValue) => data(null, dataValue),
      CommandError<T, ArgT>(error: final errorValue) => error(null, errorValue),
      ArgCommandInit<T, ArgT>() => init(),
      ArgCommandLoading<T, ArgT>(arg: final arg) => loading(arg),
      ArgCommandData<T, ArgT>(arg: final arg, data: final dataValue) => data(
        arg,
        dataValue,
      ),
      ArgCommandError<T, ArgT>(arg: final arg, error: final errorValue) =>
        error(arg, errorValue),
      _ => throw UnimplementedError(),
    };
  }

  R maybeWhen<R>({
    R Function()? init,
    R Function(ArgT? arg)? loading,
    R Function(ArgT? arg, T data)? data,
    R Function(ArgT? arg, Object error)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading<T>() => loading?.call(null) ?? orElse(),
      DataSuccess<T>(data: final dataValue) =>
        data?.call(null, dataValue) ?? orElse(),
      DataError<T>(error: final errorValue) =>
        error?.call(null, errorValue) ?? orElse(),
      CommandInit<T, ArgT>() => init?.call() ?? orElse(),
      CommandLoading<T, ArgT>() => loading?.call(null) ?? orElse(),
      CommandData<T, ArgT>(data: final dataValue) =>
        data?.call(null, dataValue) ?? orElse(),
      CommandError<T, ArgT>(error: final errorValue) =>
        error?.call(null, errorValue) ?? orElse(),
      ArgCommandInit<T, ArgT>() => init?.call() ?? orElse(),
      ArgCommandLoading<T, ArgT>(arg: final arg) =>
        loading?.call(arg) ?? orElse(),
      ArgCommandData<T, ArgT>(arg: final arg, data: final dataValue) =>
        data?.call(arg, dataValue) ?? orElse(),
      ArgCommandError<T, ArgT>(arg: final arg, error: final errorValue) =>
        error?.call(arg, errorValue) ?? orElse(),
      _ => orElse(),
    };
  }

  R? whenOrNull<R>({
    R Function()? init,
    R Function(ArgT? arg)? loading,
    R Function(ArgT? arg, T data)? data,
    R Function(ArgT? arg, Object error)? error,
  }) {
    return switch (this) {
      DataLoading<T>() => loading?.call(null),
      DataSuccess<T>(data: final dataValue) => data?.call(null, dataValue),
      DataError<T>(error: final errorValue) => error?.call(null, errorValue),
      CommandInit<T, ArgT>() => init?.call(),
      CommandLoading<T, ArgT>() => loading?.call(null),
      CommandData<T, ArgT>(data: final dataValue) => data?.call(
        null,
        dataValue,
      ),
      CommandError<T, ArgT>(error: final errorValue) => error?.call(
        null,
        errorValue,
      ),
      ArgCommandInit<T, ArgT>() => init?.call(),
      ArgCommandLoading<T, ArgT>(arg: final arg) => loading?.call(arg),
      ArgCommandData<T, ArgT>(arg: final arg, data: final dataValue) =>
        data?.call(arg, dataValue),
      ArgCommandError<T, ArgT>(arg: final arg, error: final errorValue) =>
        error?.call(arg, errorValue),
      _ => null,
    };
  }
}
