part of 'async_state.dart';

/// A command state that carries a typed argument [ArgT] alongside its async lifecycle.
sealed class ArgCommandState<T, ArgT extends Record>
    extends CommandState<T, ArgT> {
  const ArgCommandState();

  /// Creates an initial state with no argument or data.
  const factory ArgCommandState.init() = ArgCommandInit<T, ArgT>;

  /// Creates a loading state carrying the argument that triggered the command.
  const factory ArgCommandState.loading(ArgT arg) = ArgCommandLoading<T, ArgT>;

  /// Creates a data state carrying the argument and the successful result.
  const factory ArgCommandState.data(ArgT arg, T data) =
      ArgCommandData<T, ArgT>;

  /// Creates an error state carrying the argument and the error that occurred.
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

  /// Returns this state if [match] returns true for the current argument; otherwise null.
  ArgCommandState<T, ArgT>? whereArg(bool Function(ArgT? arg) match) {
    return switch (this) {
      ArgCommandData<T, ArgT>(arg: final arg) when match(arg) => this,
      ArgCommandLoading<T, ArgT>(arg: final arg) when match(arg) => this,
      ArgCommandError<T, ArgT>(arg: final arg) when match(arg) => this,
      _ => null,
    };
  }

  /// Returns this state if it holds data and [match] returns true; otherwise null.
  ArgCommandState<T, ArgT>? whereData(bool Function(T data) match) {
    return switch (this) {
      ArgCommandData<T, ArgT>(data: final d) when match(d) => this,
      _ => null,
    };
  }

  /// Returns this state if it holds an error and [match] returns true; otherwise null.
  ArgCommandState<T, ArgT>? whereError(bool Function(Object error) match) {
    return switch (this) {
      ArgCommandError<T, ArgT>(error: final e) when match(e) => this,
      _ => null,
    };
  }

  /// The argument associated with this state, or null if in init.
  ArgT? get arg {
    return switch (this) {
      ArgCommandLoading<T, ArgT>(arg: final a) => a,
      ArgCommandData<T, ArgT>(arg: final a, data: _) => a,
      ArgCommandError<T, ArgT>(arg: final a, error: _) => a,
      _ => null,
    };
  }

  /// The data payload if the command succeeded, or null otherwise.
  T? get data {
    return switch (this) {
      ArgCommandData<T, ArgT>(arg: _, data: final d) => d,
      _ => null,
    };
  }

  /// The error object if the command failed, or null otherwise.
  Object? get error {
    return switch (this) {
      ArgCommandError<T, ArgT>(arg: _, error: final e) => e,
      _ => null,
    };
  }

  /// Pattern-matches every state variant, requiring a handler for each.
  R map<R>({
    required R Function(ArgCommandInit<T, ArgT> state) init,
    required R Function(ArgCommandLoading<T, ArgT> state) loading,
    required R Function(ArgCommandData<T, ArgT> state) data,
    required R Function(ArgCommandError<T, ArgT> state) error,
  }) {
    return switch (this) {
      ArgCommandInit<T, ArgT>() && final s => init(s),
      ArgCommandLoading<T, ArgT>() && final s => loading(s),
      ArgCommandData<T, ArgT>() && final s => data(s),
      ArgCommandError<T, ArgT>() && final s => error(s),
    };
  }

  /// Pattern-matches state variants with optional handlers, falling back to [orElse].
  R maybeMap<R>({
    R Function(ArgCommandInit<T, ArgT> state)? init,
    R Function(ArgCommandLoading<T, ArgT> state)? loading,
    R Function(ArgCommandData<T, ArgT> state)? data,
    R Function(ArgCommandError<T, ArgT> state)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      ArgCommandInit<T, ArgT>() && final s => init != null ? init(s) : orElse(),
      ArgCommandLoading<T, ArgT>() && final s =>
        loading != null ? loading(s) : orElse(),
      ArgCommandData<T, ArgT>() && final s => data != null ? data(s) : orElse(),
      ArgCommandError<T, ArgT>() && final s =>
        error != null ? error(s) : orElse(),
    };
  }

  /// Pattern-matches state variants with optional handlers, returning null if unhandled.
  R? mapOrNull<R>({
    R Function(ArgCommandInit<T, ArgT> state)? init,
    R Function(ArgCommandLoading<T, ArgT> state)? loading,
    R Function(ArgCommandData<T, ArgT> state)? data,
    R Function(ArgCommandError<T, ArgT> state)? error,
  }) {
    return switch (this) {
      ArgCommandInit<T, ArgT>() && final s => init?.call(s),
      ArgCommandLoading<T, ArgT>() && final s => loading?.call(s),
      ArgCommandData<T, ArgT>() && final s => data?.call(s),
      ArgCommandError<T, ArgT>() && final s => error?.call(s),
    };
  }

  /// Destructures every state variant, requiring a handler for each.
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

  /// Destructures state variants with optional handlers, falling back to [orElse].
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

  /// Destructures state variants with optional handlers, returning null if unhandled.
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

/// The initial state before a command has been invoked.
class ArgCommandInit<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT> {
  /// Creates an [ArgCommandInit] instance.
  const ArgCommandInit();
}

/// The loading state while a command is in progress.
class ArgCommandLoading<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT>
    implements AsynchronousState<DataT, ArgT> {
  /// Creates an [ArgCommandLoading] with the triggering [arg].
  const ArgCommandLoading(this.arg);

  /// The argument that triggered this command.
  @override
  final ArgT arg;
}

/// The success state holding the command result and its argument.
class ArgCommandData<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT> {
  /// Creates an [ArgCommandData] with the triggering [arg] and resulting [data].
  const ArgCommandData(this.arg, this.data);

  /// The successful result of the command.
  @override
  final DataT data;

  /// The argument that triggered this command.
  @override
  final ArgT arg;
}

/// The error state holding the failure and the argument that caused it.
class ArgCommandError<DataT, ArgT extends Record>
    extends ArgCommandState<DataT, ArgT> {
  /// Creates an [ArgCommandError] with the triggering [arg] and the [error].
  const ArgCommandError(this.arg, this.error);

  /// The error that occurred during command execution.
  @override
  final Object error;

  /// The argument that triggered this command.
  @override
  final ArgT arg;
}

/// Convenience accessors for nullable [ArgCommandState] values.
extension NullableArgCommandStateExtension<T, ArgT extends Record>
    on ArgCommandState<T, ArgT>? {
  /// Whether this is [ArgCommandInit] or null.
  bool get isInit => this is ArgCommandInit<T, ArgT>;

  /// Whether this is [ArgCommandLoading] or null.
  bool get isLoading => this is ArgCommandLoading<T, ArgT>;

  /// Whether this is [ArgCommandData] or null.
  bool get isData => this is ArgCommandData<T, ArgT>;

  /// Whether this is [ArgCommandError] or null.
  bool get isError => this is ArgCommandError<T, ArgT>;

  /// Whether the command has completed (data or error), false if null.
  bool get isDone => isData || isError;

  /// Null-safe version of [ArgCommandState.where].
  ArgCommandState<T, ArgT>? where(
    bool Function(ArgT? arg, T? data, Object? error) match,
  ) {
    final self = this;
    if (self == null) return null;
    return self.where(match);
  }

  /// Null-safe version of [ArgCommandState.whereArg].
  ArgCommandState<T, ArgT>? whereArg(bool Function(ArgT? arg) match) {
    final self = this;
    if (self == null) return null;
    return self.whereArg(match);
  }

  /// Null-safe version of [ArgCommandState.whereData].
  ArgCommandState<T, ArgT>? whereData(bool Function(T? data) match) {
    final self = this;
    if (self == null) return null;
    return self.whereData(match);
  }

  /// The argument, or null if this state is null or init.
  ArgT? get arg {
    final self = this;
    if (self == null) return null;
    return self.arg;
  }

  /// The data payload, or null if this state is null or not data.
  T? get data {
    final self = this;
    if (self == null) return null;
    return self.data;
  }

  /// The error object, or null if this state is null or not error.
  Object? get error {
    final self = this;
    if (self == null) return null;
    return self.error;
  }

  /// Null-safe [ArgCommandState.map] with an additional [orNull] fallback.
  R map<R>({
    required R Function(ArgCommandInit<T, ArgT> state) init,
    required R Function(ArgCommandLoading<T, ArgT> state) loading,
    required R Function(ArgCommandData<T, ArgT> state) data,
    required R Function(ArgCommandError<T, ArgT> state) error,
    required R Function() orNull,
  }) {
    final self = this;
    if (self == null) return orNull();
    return self.map(init: init, loading: loading, data: data, error: error);
  }

  /// Null-safe [ArgCommandState.maybeMap] returning [orElse] when null or unhandled.
  R maybeMap<R>({
    R Function(ArgCommandInit<T, ArgT> state)? init,
    R Function(ArgCommandLoading<T, ArgT> state)? loading,
    R Function(ArgCommandData<T, ArgT> state)? data,
    R Function(ArgCommandError<T, ArgT> state)? error,
    required R Function() orElse,
  }) {
    final self = this;
    if (self == null) return orElse();
    return self.maybeMap(
      init: init,
      loading: loading,
      data: data,
      error: error,
      orElse: orElse,
    );
  }

  /// Null-safe [ArgCommandState.mapOrNull] returning null when state is null or unhandled.
  R? mapOrNull<R>({
    R Function(ArgCommandInit<T, ArgT> state)? init,
    R Function(ArgCommandLoading<T, ArgT> state)? loading,
    R Function(ArgCommandData<T, ArgT> state)? data,
    R Function(ArgCommandError<T, ArgT> state)? error,
  }) {
    final self = this;
    if (self == null) return null;
    return self.mapOrNull(
      init: init,
      loading: loading,
      data: data,
      error: error,
    );
  }

  /// Null-safe [ArgCommandState.when] with an additional [orNull] fallback.
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

  /// Null-safe [ArgCommandState.maybeWhen] returning [orElse] when null or unhandled.
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

  /// Null-safe [ArgCommandState.whenOrNull] returning null when state is null or unhandled.
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
