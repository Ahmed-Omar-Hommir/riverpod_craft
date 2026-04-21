import 'package:equatable/equatable.dart';
part 'data_state.dart';
part 'command_state.dart';
part 'arg_command_state.dart';

/// Sealed base class representing an asynchronous operation's state.
sealed class AsynchronousState<T, ArgT extends Record> with EquatableMixin {
  const AsynchronousState();

  @override
  List<Object?> get props => [];
}

/// Convenience getters and pattern-matching helpers for [AsynchronousState].
extension AsynchronousStateExtension<T, ArgT extends Record>
    on AsynchronousState<T, ArgT> {
  /// Whether the current state is a loading variant.
  bool get isLoading => switch (this) {
    DataLoading<T>() => true,
    CommandLoading<T, ArgT>() => true,
    ArgCommandLoading<T, Record>() => true,
    _ => false,
  };

  /// Whether the current state is a success/data variant.
  bool get isData => switch (this) {
    DataSuccess<T>() => true,
    CommandData<T, ArgT>() => true,
    ArgCommandData<T, Record>() => true,
    _ => false,
  };

  /// Whether the current state is an error variant.
  bool get isError => switch (this) {
    DataError<T>() => true,
    CommandError<T, ArgT>() => true,
    ArgCommandError<T, Record>() => true,
    _ => false,
  };

  /// Returns the data value if in a success state, otherwise `null`.
  T? get data => switch (this) {
    DataSuccess<T>(data: final data) => data,
    CommandData<T, ArgT>(data: final data) => data,
    ArgCommandData<T, Record>(data: final data) => data,
    _ => null,
  };

  /// Returns the error object if in an error state, otherwise `null`.
  Object? get error => switch (this) {
    DataError<T>(error: final error) => error,
    CommandError<T, ArgT>(error: final error) => error,
    ArgCommandError<T, Record>(error: final error) => error,
    _ => null,
  };

  /// Exhaustively maps each state variant to a result using the full state object.
  R map<R>({
    required R Function(AsynchronousState<T, ArgT> state) init,
    required R Function(AsynchronousState<T, ArgT> state) loading,
    required R Function(AsynchronousState<T, ArgT> state) data,
    required R Function(AsynchronousState<T, ArgT> state) error,
  }) {
    return switch (this) {
      DataLoading<T>() && final s => loading(s),
      DataSuccess<T>() && final s => data(s),
      DataError<T>() && final s => error(s),
      CommandInit<T, ArgT>() && final s => init(s),
      CommandLoading<T, ArgT>() && final s => loading(s),
      CommandData<T, ArgT>() && final s => data(s),
      CommandError<T, ArgT>() && final s => error(s),
      ArgCommandInit<T, ArgT>() && final s => init(s),
      ArgCommandLoading<T, ArgT>() && final s => loading(s),
      ArgCommandData<T, ArgT>() && final s => data(s),
      ArgCommandError<T, ArgT>() && final s => error(s),
      _ => throw UnimplementedError(),
    };
  }

  /// Maps each state variant with an [orElse] fallback for unhandled cases.
  R maybeMap<R>({
    R Function(AsynchronousState<T, ArgT> state)? init,
    R Function(AsynchronousState<T, ArgT> state)? loading,
    R Function(AsynchronousState<T, ArgT> state)? data,
    R Function(AsynchronousState<T, ArgT> state)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading<T>() && final s => loading != null ? loading(s) : orElse(),
      DataSuccess<T>() && final s => data != null ? data(s) : orElse(),
      DataError<T>() && final s => error != null ? error(s) : orElse(),
      CommandInit<T, ArgT>() && final s => init != null ? init(s) : orElse(),
      CommandLoading<T, ArgT>() && final s =>
        loading != null ? loading(s) : orElse(),
      CommandData<T, ArgT>() && final s => data != null ? data(s) : orElse(),
      CommandError<T, ArgT>() && final s => error != null ? error(s) : orElse(),
      ArgCommandInit<T, ArgT>() && final s => init != null ? init(s) : orElse(),
      ArgCommandLoading<T, ArgT>() && final s =>
        loading != null ? loading(s) : orElse(),
      ArgCommandData<T, ArgT>() && final s => data != null ? data(s) : orElse(),
      ArgCommandError<T, ArgT>() && final s =>
        error != null ? error(s) : orElse(),
      _ => orElse(),
    };
  }

  /// Maps each state variant, returning `null` for unhandled cases.
  R? mapOrNull<R>({
    R Function(AsynchronousState<T, ArgT> state)? init,
    R Function(AsynchronousState<T, ArgT> state)? loading,
    R Function(AsynchronousState<T, ArgT> state)? data,
    R Function(AsynchronousState<T, ArgT> state)? error,
  }) {
    return switch (this) {
      DataLoading<T>() && final s => loading?.call(s),
      DataSuccess<T>() && final s => data?.call(s),
      DataError<T>() && final s => error?.call(s),
      CommandInit<T, ArgT>() && final s => init?.call(s),
      CommandLoading<T, ArgT>() && final s => loading?.call(s),
      CommandData<T, ArgT>() && final s => data?.call(s),
      CommandError<T, ArgT>() && final s => error?.call(s),
      ArgCommandInit<T, ArgT>() && final s => init?.call(s),
      ArgCommandLoading<T, ArgT>() && final s => loading?.call(s),
      ArgCommandData<T, ArgT>() && final s => data?.call(s),
      ArgCommandError<T, ArgT>() && final s => error?.call(s),
      _ => null,
    };
  }

  /// Exhaustively matches each state variant using destructured values.
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

  /// Matches each state variant with an [orElse] fallback, using destructured values.
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

  /// Matches each state variant, returning `null` for unhandled cases, using destructured values.
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
