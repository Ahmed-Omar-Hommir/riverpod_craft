part of 'async_state.dart';

sealed class CommandState<T, ArgT extends Record>
    with EquatableMixin
    implements AsynchronousState<T, ArgT> {
  const CommandState();

  const factory CommandState.init() = CommandInit<T, ArgT>;
  const factory CommandState.loading() = CommandLoading<T, ArgT>;
  const factory CommandState.data(T data) = CommandData<T, ArgT>;
  const factory CommandState.error(Object error) = CommandError<T, ArgT>;

  @override
  List<Object?> get props => [];
}

class CommandInit<T, ArgT extends Record> extends CommandState<T, ArgT> {
  const CommandInit();

  @override
  List<Object?> get props => [];
}

class CommandLoading<T, ArgT extends Record> extends CommandState<T, ArgT> {
  const CommandLoading();

  @override
  List<Object?> get props => [];
}

class CommandData<T, ArgT extends Record> extends CommandState<T, ArgT> {
  const CommandData(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

class CommandError<T, ArgT extends Record> extends CommandState<T, ArgT> {
  const CommandError(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

extension CommandStateExtension<T, ArgT extends Record>
    on CommandState<T, ArgT> {
  bool get isInit => this is CommandInit<T, ArgT>;
  bool get isLoading => this is CommandLoading<T, ArgT>;
  bool get isData => this is CommandData<T, ArgT>;
  bool get isError => this is CommandError<T, ArgT>;
  bool get isDone => isData || isError;

  T? get data {
    return switch (this) {
      CommandData<T, ArgT>(data: final d) => d,
      _ => null,
    };
  }

  Object? get error {
    return switch (this) {
      CommandError<T, ArgT>(error: final e) => e,
      _ => null,
    };
  }

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

  R maybeMap<R>({
    R Function(CommandInit<T, ArgT> state)? init,
    R Function(CommandLoading<T, ArgT> state)? loading,
    R Function(CommandData<T, ArgT> state)? data,
    R Function(CommandError<T, ArgT> state)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      CommandInit<T, ArgT>() && final s => init != null ? init(s) : orElse(),
      CommandLoading<T, ArgT>() && final s => loading != null ? loading(s) : orElse(),
      CommandData<T, ArgT>() && final s => data != null ? data(s) : orElse(),
      CommandError<T, ArgT>() && final s => error != null ? error(s) : orElse(),
      _ => orElse(),
    };
  }

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

extension NullableCommandStateExtension<T, ArgT extends Record>
    on CommandState<T, ArgT>? {
  bool get isInit => this is CommandInit<T, ArgT>;
  bool get isLoading => this is CommandLoading<T, ArgT>;
  bool get isData => this is CommandData<T, ArgT>;
  bool get isError => this is CommandError<T, ArgT>;
  bool get isDone => isData || isError;

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
