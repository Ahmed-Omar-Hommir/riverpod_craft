part of 'async_state.dart';

/// Represents the state of a command operation that produces [T] with arguments [ArgT].
sealed class CommandState<T, ArgT extends Record>
    with EquatableMixin
    implements AsynchronousState<T, ArgT> {
  const CommandState();

  /// Creates an initial idle state before any command execution.
  const factory CommandState.init() = CommandInit<T, ArgT>;

  /// Creates a loading state while the command is executing.
  const factory CommandState.loading() = CommandLoading<T, ArgT>;

  /// Creates a data state holding the successful command [data] result.
  const factory CommandState.data(T data) = CommandData<T, ArgT>;

  /// Creates an error state holding the [error] from a failed command.
  const factory CommandState.error(Object error) = CommandError<T, ArgT>;

  @override
  List<Object?> get props => [];
}

/// The initial idle state before a command has been executed.
class CommandInit<T, ArgT extends Record> extends CommandState<T, ArgT> {
  /// Creates a [CommandInit] instance.
  const CommandInit();

  @override
  List<Object?> get props => [];
}

/// The loading state while a command is being executed.
class CommandLoading<T, ArgT extends Record> extends CommandState<T, ArgT> {
  /// Creates a [CommandLoading] instance.
  const CommandLoading();

  @override
  List<Object?> get props => [];
}

/// The success state holding the [data] result of a command.
class CommandData<T, ArgT extends Record> extends CommandState<T, ArgT> {
  /// Creates a [CommandData] instance with the given [data].
  const CommandData(this.data);

  /// The successful result data.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// The error state holding the [error] from a failed command.
class CommandError<T, ArgT extends Record> extends CommandState<T, ArgT> {
  /// Creates a [CommandError] instance with the given [error].
  const CommandError(this.error);

  /// The error object describing the failure.
  final Object error;

  @override
  List<Object?> get props => [error];
}

/// Convenience getters and pattern-matching methods on [CommandState].
extension CommandStateExtension<T, ArgT extends Record>
    on CommandState<T, ArgT> {
  /// Whether this state is [CommandInit].
  bool get isInit => this is CommandInit<T, ArgT>;

  /// Whether this state is [CommandLoading].
  bool get isLoading => this is CommandLoading<T, ArgT>;

  /// Whether this state is [CommandData].
  bool get isData => this is CommandData<T, ArgT>;

  /// Whether this state is [CommandError].
  bool get isError => this is CommandError<T, ArgT>;

  /// Whether the command has completed (either data or error).
  bool get isDone => isData || isError;

  /// Returns the data if this is [CommandData], otherwise null.
  T? get data {
    return switch (this) {
      CommandData<T, ArgT>(data: final d) => d,
      _ => null,
    };
  }

  /// Returns the error if this is [CommandError], otherwise null.
  Object? get error {
    return switch (this) {
      CommandError<T, ArgT>(error: final e) => e,
      _ => null,
    };
  }

  /// Pattern-matches on all states with access to the state object.
  R map<R>({
    required R Function(CommandInit<T, ArgT> state) init,
    required R Function(CommandLoading<T, ArgT> state) loading,
    required R Function(CommandData<T, ArgT> state) data,
    required R Function(CommandError<T, ArgT> state) error,
  }) {
    return switch (this) {
      CommandInit<T, ArgT>() && final s => init(s),
      CommandLoading<T, ArgT>() && final s => loading(s),
      CommandData<T, ArgT>() && final s => data(s),
      CommandError<T, ArgT>() && final s => error(s),
      _ => throw StateError('Unexpected state: $this'),
    };
  }

  /// Pattern-matches with optional handlers, falling back to [orElse].
  R maybeMap<R>({
    R Function(CommandInit<T, ArgT> state)? init,
    R Function(CommandLoading<T, ArgT> state)? loading,
    R Function(CommandData<T, ArgT> state)? data,
    R Function(CommandError<T, ArgT> state)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      CommandInit<T, ArgT>() && final s => init != null ? init(s) : orElse(),
      CommandLoading<T, ArgT>() && final s =>
        loading != null ? loading(s) : orElse(),
      CommandData<T, ArgT>() && final s => data != null ? data(s) : orElse(),
      CommandError<T, ArgT>() && final s => error != null ? error(s) : orElse(),
      _ => orElse(),
    };
  }

  /// Pattern-matches with optional handlers, returning null if unmatched.
  R? mapOrNull<R>({
    R Function(CommandInit<T, ArgT> state)? init,
    R Function(CommandLoading<T, ArgT> state)? loading,
    R Function(CommandData<T, ArgT> state)? data,
    R Function(CommandError<T, ArgT> state)? error,
  }) {
    return switch (this) {
      CommandInit<T, ArgT>() && final s => init?.call(s),
      CommandLoading<T, ArgT>() && final s => loading?.call(s),
      CommandData<T, ArgT>() && final s => data?.call(s),
      CommandError<T, ArgT>() && final s => error?.call(s),
      _ => null,
    };
  }

  /// Pattern-matches on all states with destructured values.
  R when<R>({
    required R Function() init,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
  }) {
    return switch (this) {
      CommandInit<T, ArgT>() => init(),
      CommandLoading<T, ArgT>() => loading(),
      CommandData<T, ArgT>(data: final d) => data(d),
      CommandError<T, ArgT>(error: final e) => error(e),
      _ => throw StateError('Unexpected state: $this'),
    };
  }

  /// Pattern-matches with optional handlers and destructured values, falling back to [orElse].
  R maybeWhen<R>({
    R Function()? init,
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      CommandInit<T, ArgT>() => init != null ? init() : orElse(),
      CommandLoading<T, ArgT>() => loading != null ? loading() : orElse(),
      CommandData<T, ArgT>(data: final d) => data != null ? data(d) : orElse(),
      CommandError<T, ArgT>(error: final e) =>
        error != null ? error(e) : orElse(),
      _ => orElse(),
    };
  }

  /// Pattern-matches with optional handlers and destructured values, returning null if unmatched.
  R? whenOrNull<R>({
    R Function()? init,
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error)? error,
  }) {
    return switch (this) {
      CommandInit<T, ArgT>() => init?.call(),
      CommandLoading<T, ArgT>() => loading?.call(),
      CommandData<T, ArgT>(data: final d) => data?.call(d),
      CommandError<T, ArgT>(error: final e) => error?.call(e),
      _ => null,
    };
  }
}

/// Convenience getters and pattern-matching methods on nullable [CommandState].
extension NullableCommandStateExtension<T, ArgT extends Record>
    on CommandState<T, ArgT>? {
  /// Whether this state is [CommandInit] (false if null).
  bool get isInit => this is CommandInit<T, ArgT>;

  /// Whether this state is [CommandLoading] (false if null).
  bool get isLoading => this is CommandLoading<T, ArgT>;

  /// Whether this state is [CommandData] (false if null).
  bool get isData => this is CommandData<T, ArgT>;

  /// Whether this state is [CommandError] (false if null).
  bool get isError => this is CommandError<T, ArgT>;

  /// Whether the command has completed, false if null.
  bool get isDone => isData || isError;

  /// Returns the data if this is [CommandData], otherwise null.
  T? get data {
    final self = this;
    if (self == null) return null;
    return self.data;
  }

  /// Returns the error if this is [CommandError], otherwise null.
  Object? get error {
    final self = this;
    if (self == null) return null;
    return self.error;
  }

  /// Pattern-matches on all states, calling [orNull] when the state is null.
  R map<R>({
    required R Function(CommandInit<T, ArgT> state) init,
    required R Function(CommandLoading<T, ArgT> state) loading,
    required R Function(CommandData<T, ArgT> state) data,
    required R Function(CommandError<T, ArgT> state) error,
    required R Function() orNull,
  }) {
    final self = this;
    if (self == null) return orNull();
    return self.map(init: init, loading: loading, data: data, error: error);
  }

  /// Pattern-matches with optional handlers, falling back to [orElse] (including null).
  R maybeMap<R>({
    R Function(CommandInit<T, ArgT> state)? init,
    R Function(CommandLoading<T, ArgT> state)? loading,
    R Function(CommandData<T, ArgT> state)? data,
    R Function(CommandError<T, ArgT> state)? error,
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

  /// Pattern-matches with optional handlers, returning null if unmatched or null.
  R? mapOrNull<R>({
    R Function(CommandInit<T, ArgT> state)? init,
    R Function(CommandLoading<T, ArgT> state)? loading,
    R Function(CommandData<T, ArgT> state)? data,
    R Function(CommandError<T, ArgT> state)? error,
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

  /// Pattern-matches with destructured values, calling [orNull] when the state is null.
  R when<R>({
    required R Function() init,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() orNull,
  }) {
    final self = this;
    if (self == null) return orNull();
    return self.when(init: init, loading: loading, data: data, error: error);
  }

  /// Pattern-matches with optional handlers and destructured values, falling back to [orElse].
  R maybeWhen<R>({
    R Function()? init,
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error)? error,
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

  /// Pattern-matches with optional handlers and destructured values, returning null if unmatched or null.
  R? whenOrNull<R>({
    R Function()? init,
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error)? error,
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
