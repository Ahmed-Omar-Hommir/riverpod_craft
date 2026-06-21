import 'package:equatable/equatable.dart';
part 'data_state.dart';
part 'command_state.dart';
part 'arg_command_state.dart';

/// Sealed base class representing an asynchronous operation's state.
///
/// [F] is the error type — `Object` by default, or your custom type when a
/// global `error_mapper` is configured.
sealed class AsynchronousState<T, F extends Object, ArgT extends Record>
    with EquatableMixin {
  const AsynchronousState();

  @override
  List<Object?> get props => [];
}

/// Convenience getters and pattern-matching helpers for [AsynchronousState].
extension AsynchronousStateExtension<T, F extends Object, ArgT extends Record>
    on AsynchronousState<T, F, ArgT> {
  /// Whether the current state is a loading variant.
  bool get isLoading => switch (this) {
    DataLoading<T, F>() => true,
    CommandLoading<T, F, ArgT>() => true,
    ArgCommandLoading<T, F, Record>() => true,
    _ => false,
  };

  /// Whether the current state is a success/data variant.
  bool get isData => switch (this) {
    DataSuccess<T, F>() => true,
    CommandData<T, F, ArgT>() => true,
    ArgCommandData<T, F, Record>() => true,
    _ => false,
  };

  /// Whether the current state is an error variant.
  bool get isError => switch (this) {
    DataError<T, F>() => true,
    CommandError<T, F, ArgT>() => true,
    ArgCommandError<T, F, Record>() => true,
    _ => false,
  };

  /// Returns the data value if in a success state, otherwise `null`.
  T? get data => switch (this) {
    DataSuccess<T, F>(data: final data) => data,
    CommandData<T, F, ArgT>(data: final data) => data,
    ArgCommandData<T, F, Record>(data: final data) => data,
    _ => null,
  };

  /// Returns the error object if in an error state, otherwise `null`.
  F? get error => switch (this) {
    DataError<T, F>(error: final error) => error,
    CommandError<T, F, ArgT>(error: final error) => error,
    ArgCommandError<T, F, Record>(error: final error) => error,
    _ => null,
  };

  /// Exhaustively maps each state variant to a result using the full state object.
  R map<R>({
    required R Function(AsynchronousState<T, F, ArgT> state) init,
    required R Function(AsynchronousState<T, F, ArgT> state) loading,
    required R Function(AsynchronousState<T, F, ArgT> state) data,
    required R Function(AsynchronousState<T, F, ArgT> state) error,
  }) {
    return switch (this) {
      DataLoading<T, F>() && final s => loading(s),
      DataSuccess<T, F>() && final s => data(s),
      DataError<T, F>() && final s => error(s),
      CommandInit<T, F, ArgT>() && final s => init(s),
      CommandLoading<T, F, ArgT>() && final s => loading(s),
      CommandData<T, F, ArgT>() && final s => data(s),
      CommandError<T, F, ArgT>() && final s => error(s),
      ArgCommandInit<T, F, ArgT>() && final s => init(s),
      ArgCommandLoading<T, F, ArgT>() && final s => loading(s),
      ArgCommandData<T, F, ArgT>() && final s => data(s),
      ArgCommandError<T, F, ArgT>() && final s => error(s),
      _ => throw UnimplementedError(),
    };
  }

  /// Maps each state variant with an [orElse] fallback for unhandled cases.
  R maybeMap<R>({
    R Function(AsynchronousState<T, F, ArgT> state)? init,
    R Function(AsynchronousState<T, F, ArgT> state)? loading,
    R Function(AsynchronousState<T, F, ArgT> state)? data,
    R Function(AsynchronousState<T, F, ArgT> state)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading<T, F>() && final s => loading != null ? loading(s) : orElse(),
      DataSuccess<T, F>() && final s => data != null ? data(s) : orElse(),
      DataError<T, F>() && final s => error != null ? error(s) : orElse(),
      CommandInit<T, F, ArgT>() && final s => init != null ? init(s) : orElse(),
      CommandLoading<T, F, ArgT>() && final s =>
        loading != null ? loading(s) : orElse(),
      CommandData<T, F, ArgT>() && final s => data != null ? data(s) : orElse(),
      CommandError<T, F, ArgT>() && final s =>
        error != null ? error(s) : orElse(),
      ArgCommandInit<T, F, ArgT>() && final s =>
        init != null ? init(s) : orElse(),
      ArgCommandLoading<T, F, ArgT>() && final s =>
        loading != null ? loading(s) : orElse(),
      ArgCommandData<T, F, ArgT>() && final s =>
        data != null ? data(s) : orElse(),
      ArgCommandError<T, F, ArgT>() && final s =>
        error != null ? error(s) : orElse(),
      _ => orElse(),
    };
  }

  /// Maps each state variant, returning `null` for unhandled cases.
  R? mapOrNull<R>({
    R Function(AsynchronousState<T, F, ArgT> state)? init,
    R Function(AsynchronousState<T, F, ArgT> state)? loading,
    R Function(AsynchronousState<T, F, ArgT> state)? data,
    R Function(AsynchronousState<T, F, ArgT> state)? error,
  }) {
    return switch (this) {
      DataLoading<T, F>() && final s => loading?.call(s),
      DataSuccess<T, F>() && final s => data?.call(s),
      DataError<T, F>() && final s => error?.call(s),
      CommandInit<T, F, ArgT>() && final s => init?.call(s),
      CommandLoading<T, F, ArgT>() && final s => loading?.call(s),
      CommandData<T, F, ArgT>() && final s => data?.call(s),
      CommandError<T, F, ArgT>() && final s => error?.call(s),
      ArgCommandInit<T, F, ArgT>() && final s => init?.call(s),
      ArgCommandLoading<T, F, ArgT>() && final s => loading?.call(s),
      ArgCommandData<T, F, ArgT>() && final s => data?.call(s),
      ArgCommandError<T, F, ArgT>() && final s => error?.call(s),
      _ => null,
    };
  }

  /// Exhaustively matches each state variant using destructured values.
  R when<R>({
    required R Function() init,
    required R Function(ArgT? arg) loading,
    required R Function(ArgT? arg, T data) data,
    required R Function(ArgT? arg, F error) error,
  }) {
    return switch (this) {
      DataLoading<T, F>() => loading(null),
      DataSuccess<T, F>(data: final dataValue) => data(null, dataValue),
      DataError<T, F>(error: final errorValue) => error(null, errorValue),
      CommandInit<T, F, ArgT>() => init(),
      CommandLoading<T, F, ArgT>() => loading(null),
      CommandData<T, F, ArgT>(data: final dataValue) => data(null, dataValue),
      CommandError<T, F, ArgT>(error: final errorValue) =>
        error(null, errorValue),
      ArgCommandInit<T, F, ArgT>() => init(),
      ArgCommandLoading<T, F, ArgT>(arg: final arg) => loading(arg),
      ArgCommandData<T, F, ArgT>(arg: final arg, data: final dataValue) => data(
        arg,
        dataValue,
      ),
      ArgCommandError<T, F, ArgT>(arg: final arg, error: final errorValue) =>
        error(arg, errorValue),
      _ => throw UnimplementedError(),
    };
  }

  /// Matches each state variant with an [orElse] fallback, using destructured values.
  R maybeWhen<R>({
    R Function()? init,
    R Function(ArgT? arg)? loading,
    R Function(ArgT? arg, T data)? data,
    R Function(ArgT? arg, F error)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading<T, F>() => loading?.call(null) ?? orElse(),
      DataSuccess<T, F>(data: final dataValue) =>
        data?.call(null, dataValue) ?? orElse(),
      DataError<T, F>(error: final errorValue) =>
        error?.call(null, errorValue) ?? orElse(),
      CommandInit<T, F, ArgT>() => init?.call() ?? orElse(),
      CommandLoading<T, F, ArgT>() => loading?.call(null) ?? orElse(),
      CommandData<T, F, ArgT>(data: final dataValue) =>
        data?.call(null, dataValue) ?? orElse(),
      CommandError<T, F, ArgT>(error: final errorValue) =>
        error?.call(null, errorValue) ?? orElse(),
      ArgCommandInit<T, F, ArgT>() => init?.call() ?? orElse(),
      ArgCommandLoading<T, F, ArgT>(arg: final arg) =>
        loading?.call(arg) ?? orElse(),
      ArgCommandData<T, F, ArgT>(arg: final arg, data: final dataValue) =>
        data?.call(arg, dataValue) ?? orElse(),
      ArgCommandError<T, F, ArgT>(arg: final arg, error: final errorValue) =>
        error?.call(arg, errorValue) ?? orElse(),
      _ => orElse(),
    };
  }

  /// Matches each state variant, returning `null` for unhandled cases, using destructured values.
  R? whenOrNull<R>({
    R Function()? init,
    R Function(ArgT? arg)? loading,
    R Function(ArgT? arg, T data)? data,
    R Function(ArgT? arg, F error)? error,
  }) {
    return switch (this) {
      DataLoading<T, F>() => loading?.call(null),
      DataSuccess<T, F>(data: final dataValue) => data?.call(null, dataValue),
      DataError<T, F>(error: final errorValue) => error?.call(null, errorValue),
      CommandInit<T, F, ArgT>() => init?.call(),
      CommandLoading<T, F, ArgT>() => loading?.call(null),
      CommandData<T, F, ArgT>(data: final dataValue) => data?.call(
        null,
        dataValue,
      ),
      CommandError<T, F, ArgT>(error: final errorValue) => error?.call(
        null,
        errorValue,
      ),
      ArgCommandInit<T, F, ArgT>() => init?.call(),
      ArgCommandLoading<T, F, ArgT>(arg: final arg) => loading?.call(arg),
      ArgCommandData<T, F, ArgT>(arg: final arg, data: final dataValue) =>
        data?.call(arg, dataValue),
      ArgCommandError<T, F, ArgT>(arg: final arg, error: final errorValue) =>
        error?.call(arg, errorValue),
      _ => null,
    };
  }
}
