// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'commands_provider.dart';

final _$concurrentTaskCommand =
    NotifierProvider<CommandNotifier<String, ()>, ArgCommandState<String, ()>>(
      () => _$ConcurrentTaskCommand(),
      isAutoDispose: true,
    );

class _$ConcurrentTaskCommand extends CommandNotifier<String, ()> {
  @override
  Future<String> action(Ref ref, () arg) => concurrentTask(ref);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.concurrent;
}

class $ConcurrentTaskCommandFacadeRef {
  $ConcurrentTaskCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$concurrentTaskCommand;

  ArgCommandState<String, ()> read() => _ref.read(_command);
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $ConcurrentTaskCommandFacadeWidget
    implements
        CommandProviderFacade<String, ()>,
        CommandProviderValue<String, ()> {
  $ConcurrentTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$concurrentTaskCommand;

  @override
  ArgCommandState<String, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, ()> of(WidgetRef ref) =>
      $ConcurrentTaskCommandFacadeWidget(ref);
}

extension $ConcurrentTaskCommandRefEx on Ref {
  $ConcurrentTaskCommandFacadeRef get concurrentTaskCommand =>
      $ConcurrentTaskCommandFacadeRef(this);
}

extension $ConcurrentTaskCommandWidgetRefEx on WidgetRef {
  $ConcurrentTaskCommandFacadeWidget get concurrentTaskCommand =>
      $ConcurrentTaskCommandFacadeWidget(this);
}

final _$sequentialTaskCommand =
    NotifierProvider<CommandNotifier<String, ()>, ArgCommandState<String, ()>>(
      () => _$SequentialTaskCommand(),
      isAutoDispose: true,
    );

class _$SequentialTaskCommand extends CommandNotifier<String, ()> {
  @override
  Future<String> action(Ref ref, () arg) => sequentialTask(ref);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.sequential;
}

class $SequentialTaskCommandFacadeRef {
  $SequentialTaskCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$sequentialTaskCommand;

  ArgCommandState<String, ()> read() => _ref.read(_command);
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $SequentialTaskCommandFacadeWidget
    implements
        CommandProviderFacade<String, ()>,
        CommandProviderValue<String, ()> {
  $SequentialTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$sequentialTaskCommand;

  @override
  ArgCommandState<String, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, ()> of(WidgetRef ref) =>
      $SequentialTaskCommandFacadeWidget(ref);
}

extension $SequentialTaskCommandRefEx on Ref {
  $SequentialTaskCommandFacadeRef get sequentialTaskCommand =>
      $SequentialTaskCommandFacadeRef(this);
}

extension $SequentialTaskCommandWidgetRefEx on WidgetRef {
  $SequentialTaskCommandFacadeWidget get sequentialTaskCommand =>
      $SequentialTaskCommandFacadeWidget(this);
}

final _$droppableTaskCommand =
    NotifierProvider<CommandNotifier<String, ()>, ArgCommandState<String, ()>>(
      () => _$DroppableTaskCommand(),
      isAutoDispose: true,
    );

class _$DroppableTaskCommand extends CommandNotifier<String, ()> {
  @override
  Future<String> action(Ref ref, () arg) => droppableTask(ref);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class $DroppableTaskCommandFacadeRef {
  $DroppableTaskCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$droppableTaskCommand;

  ArgCommandState<String, ()> read() => _ref.read(_command);
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $DroppableTaskCommandFacadeWidget
    implements
        CommandProviderFacade<String, ()>,
        CommandProviderValue<String, ()> {
  $DroppableTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$droppableTaskCommand;

  @override
  ArgCommandState<String, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, ()> of(WidgetRef ref) =>
      $DroppableTaskCommandFacadeWidget(ref);
}

extension $DroppableTaskCommandRefEx on Ref {
  $DroppableTaskCommandFacadeRef get droppableTaskCommand =>
      $DroppableTaskCommandFacadeRef(this);
}

extension $DroppableTaskCommandWidgetRefEx on WidgetRef {
  $DroppableTaskCommandFacadeWidget get droppableTaskCommand =>
      $DroppableTaskCommandFacadeWidget(this);
}

final _$restartableTaskCommand =
    NotifierProvider<CommandNotifier<String, ()>, ArgCommandState<String, ()>>(
      () => _$RestartableTaskCommand(),
      isAutoDispose: true,
    );

class _$RestartableTaskCommand extends CommandNotifier<String, ()> {
  @override
  Future<String> action(Ref ref, () arg) => restartableTask(ref);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.restartable;
}

class $RestartableTaskCommandFacadeRef {
  $RestartableTaskCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$restartableTaskCommand;

  ArgCommandState<String, ()> read() => _ref.read(_command);
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $RestartableTaskCommandFacadeWidget
    implements
        CommandProviderFacade<String, ()>,
        CommandProviderValue<String, ()> {
  $RestartableTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$restartableTaskCommand;

  @override
  ArgCommandState<String, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ()> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<String, ()>? previous,
      ArgCommandState<String, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, ()> of(WidgetRef ref) =>
      $RestartableTaskCommandFacadeWidget(ref);
}

extension $RestartableTaskCommandRefEx on Ref {
  $RestartableTaskCommandFacadeRef get restartableTaskCommand =>
      $RestartableTaskCommandFacadeRef(this);
}

extension $RestartableTaskCommandWidgetRefEx on WidgetRef {
  $RestartableTaskCommandFacadeWidget get restartableTaskCommand =>
      $RestartableTaskCommandFacadeWidget(this);
}
