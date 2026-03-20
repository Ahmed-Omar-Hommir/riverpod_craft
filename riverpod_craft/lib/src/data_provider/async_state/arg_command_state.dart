part of 'async_state.dart';

sealed class ArgCommandState<T, ArgT extends Record>
    extends CommandState<T, ArgT> {
  const ArgCommandState();

  const factory ArgCommandState.init() = ArgCommandInit<T, ArgT>;
  const factory ArgCommandState.loading(ArgT arg) = ArgCommandLoading<T, ArgT>;
  const factory ArgCommandState.data(ArgT arg, T data) =
      ArgCommandData<T, ArgT>;
  const factory ArgCommandState.error(ArgT arg, Object error) =
      ArgCommandError<T, ArgT>;

  bool get isInit => this is ArgCommandInit<T, ArgT>;
  bool get isLoading => this is ArgCommandLoading<T, ArgT>;
  bool get isData => this is ArgCommandData<T, ArgT>;
  bool get isError => this is ArgCommandError<T, ArgT>;
  bool get isDone => isData || isError;

  ArgCommandState<T, ArgT>? where(
    bool Function(ArgT? arg, T? data, Object? error) match,
  ) {
    return switch (this) {
      ArgCommandData<T, ArgT>(arg: final arg, data: final data) && var state
          when match(arg, data, null) =>
        state,
      ArgCommandInit<T, ArgT>() when match(null, null, null) => this,
      ArgCommandLoading<T, ArgT>() when match(arg, null, null) => this,
      ArgCommandData<T, ArgT>() when match(arg, data, null) => this,
      ArgCommandError<T, ArgT>() when match(arg, null, error) => this,
      _ => null,
    };
  }

  ArgCommandState<T, ArgT>? whereArg(bool Function(ArgT? arg) match) {
    return switch (this) {
      ArgCommandData<T, ArgT>(arg: final arg) when match(arg) => this,
      ArgCommandLoading<T, ArgT>(arg: final arg) when match(arg) => this,
      ArgCommandError<T, ArgT>(arg: final arg) when match(arg) => this,
      _ => null,
    };
  }

  ArgCommandState<T, ArgT>? whereData(bool Function(T data) match) {
    return switch (this) {
      ArgCommandData<T, ArgT>(data: final d) when match(d) => this,
      _ => null,
    };
  }

  ArgCommandState<T, ArgT>? whereError(bool Function(Object error) match) {
    return switch (this) {
      ArgCommandError<T, ArgT>(error: final e) when match(e) => this,
      _ => null,
    };
  }

  ArgT? get arg {
    return switch (this) {
      ArgCommandLoading<T, ArgT>(arg: final a) => a,
      ArgCommandData<T, ArgT>(arg: final a, data: _) => a,
      ArgCommandError<T, ArgT>(arg: final a, error: _) => a,
      _ => null,
    };
  }

  T? get data {
    return switch (this) {
      ArgCommandData<T, ArgT>(arg: _, data: final d) => d,
      _ => null,
    };
  }

  Object? get error {
    return switch (this) {
      ArgCommandError<T, ArgT>(arg: _, error: final e) => e,
      _ => null,
    };
  }

  R when<R>({
    required R Function() init,
    required R Function(ArgT arg) loading,
    required R Function(ArgT arg, T data) data,
    required R Function(ArgT arg, Object error) error,
  }) {
    return switch (this) {
      ArgCommandInit<T, ArgT>() => init(),
      ArgCommandLoading<T, ArgT>(arg: final a) => loading(a),
      ArgCommandData<T, ArgT>(arg: final a, data: final d) => data(a, d),
      ArgCommandError<T, ArgT>(arg: final a, error: final e) => error(a, e),
    };
  }

  R maybeWhen<R>({
    R Function()? init,
    R Function(ArgT arg)? loading,
    R Function(ArgT arg, T data)? data,
    R Function(ArgT arg, Object error)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      ArgCommandInit<T, ArgT>() => init != null ? init() : orElse(),
      ArgCommandLoading<T, ArgT>(arg: final a) =>
        loading != null ? loading(a) : orElse(),
      ArgCommandData<T, ArgT>(arg: final a, data: final d) =>
        data != null ? data(a, d) : orElse(),
      ArgCommandError<T, ArgT>(arg: final a, error: final e) =>
        error != null ? error(a, e) : orElse(),
    };
  }

  R? whenOrNull<R>({
    R Function()? init,
    R Function(ArgT arg)? loading,
    R Function(ArgT arg, T data)? data,
    R Function(ArgT arg, Object error)? error,
  }) {
    return switch (this) {
      ArgCommandInit<T, ArgT>() => init != null ? init() : null,
      ArgCommandLoading<T, ArgT>(arg: final a) =>
        loading != null ? loading(a) : null,
      ArgCommandData<T, ArgT>(arg: final a, data: final d) =>
        data != null ? data(a, d) : null,
      ArgCommandError<T, ArgT>(arg: final a, error: final e) =>
        error != null ? error(a, e) : null,
    };
  }
}

class ArgCommandInit<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT> {
  const ArgCommandInit();
}

class ArgCommandLoading<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT> implements AsynchronousState<DataT, ArgT> {
  const ArgCommandLoading(this.arg);

  @override
  final ArgT arg;
}

class ArgCommandData<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT> {
  const ArgCommandData(this.arg, this.data);
  @override
  final DataT data;
  @override
  final ArgT arg;
}

class ArgCommandError<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT> {
  const ArgCommandError(this.arg, this.error);
  @override
  final Object error;
  @override
  final ArgT arg;
}

extension NullableArgCommandStateExtension<T, ArgT extends Record>
    on ArgCommandState<T, ArgT>? {
  bool get isInit => this is ArgCommandInit<T, ArgT>;
  bool get isLoading => this is ArgCommandLoading<T, ArgT>;
  bool get isData => this is ArgCommandData<T, ArgT>;
  bool get isError => this is ArgCommandError<T, ArgT>;
  bool get isDone => isData || isError;

  ArgCommandState<T, ArgT>? where(
    bool Function(ArgT? arg, T? data, Object? error) match,
  ) {
    final self = this;
    if (self == null) return null;
    return self.where(match);
  }

  ArgCommandState<T, ArgT>? whereArg(bool Function(ArgT? arg) match) {
    final self = this;
    if (self == null) return null;
    return self.whereArg(match);
  }

  ArgCommandState<T, ArgT>? whereData(bool Function(T? data) match) {
    final self = this;
    if (self == null) return null;
    return self.whereData(match);
  }

  ArgT? get arg {
    final self = this;
    if (self == null) return null;
    return self.arg;
  }

  T? get data {
    final self = this;
    if (self == null) return null;
    return self.data;
  }

  Object? get error {
    final self = this;
    if (self == null) return null;
    return self.error;
  }

  R when<R>({
    required R Function() init,
    required R Function(ArgT arg) loading,
    required R Function(ArgT arg, T data) data,
    required R Function(ArgT arg, Object error) error,
    required R Function() orNull,
  }) {
    final self = this;
    if (self == null) return orNull();
    return self.when(init: init, loading: loading, data: data, error: error);
  }

  R maybeWhen<R>({
    R Function()? init,
    R Function(ArgT arg)? loading,
    R Function(ArgT arg, T data)? data,
    R Function(ArgT arg, Object error)? error,
    required R Function() orElse,
  }) {
    final self = this;
    if (self == null) return orElse();
    return self.maybeWhen(
      init: init,
      loading: loading,
      data: data,
      error: error,
      orElse: orElse,
    );
  }

  R? whenOrNull<R>({
    R Function()? init,
    R Function(ArgT arg)? loading,
    R Function(ArgT arg, T data)? data,
    R Function(ArgT arg, Object error)? error,
  }) {
    final self = this;
    if (self == null) return null;
    return self.whenOrNull(
      init: init,
      loading: loading,
      data: data,
      error: error,
    );
  }
}
