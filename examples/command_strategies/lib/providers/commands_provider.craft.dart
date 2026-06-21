// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'commands_provider.dart';

final _$concurrentTaskCommand =
    NotifierProvider<
      CommandNotifier<String, Object, ()>,
      ArgCommandState<String, Object, ()>
    >(() => _$ConcurrentTaskCommand(), isAutoDispose: true);

class _$ConcurrentTaskCommand extends CommandNotifier<String, Object, ()> {
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

  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
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
        CommandProviderFacade<String, Object, ()>,
        CommandProviderValue<String, Object, ()> {
  $ConcurrentTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$concurrentTaskCommand;

  @override
  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
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
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, Object, ()> of(WidgetRef ref) =>
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
    NotifierProvider<
      CommandNotifier<String, Object, ()>,
      ArgCommandState<String, Object, ()>
    >(() => _$SequentialTaskCommand(), isAutoDispose: true);

class _$SequentialTaskCommand extends CommandNotifier<String, Object, ()> {
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

  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
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
        CommandProviderFacade<String, Object, ()>,
        CommandProviderValue<String, Object, ()> {
  $SequentialTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$sequentialTaskCommand;

  @override
  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
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
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, Object, ()> of(WidgetRef ref) =>
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
    NotifierProvider<
      CommandNotifier<String, Object, ()>,
      ArgCommandState<String, Object, ()>
    >(() => _$DroppableTaskCommand(), isAutoDispose: true);

class _$DroppableTaskCommand extends CommandNotifier<String, Object, ()> {
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

  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
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
        CommandProviderFacade<String, Object, ()>,
        CommandProviderValue<String, Object, ()> {
  $DroppableTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$droppableTaskCommand;

  @override
  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
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
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, Object, ()> of(WidgetRef ref) =>
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
    NotifierProvider<
      CommandNotifier<String, Object, ()>,
      ArgCommandState<String, Object, ()>
    >(() => _$RestartableTaskCommand(), isAutoDispose: true);

class _$RestartableTaskCommand extends CommandNotifier<String, Object, ()> {
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

  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
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
        CommandProviderFacade<String, Object, ()>,
        CommandProviderValue<String, Object, ()> {
  $RestartableTaskCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$restartableTaskCommand;

  @override
  ArgCommandState<String, Object, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<String, Object, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, Object, ()> state) selector,
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
      ArgCommandState<String, Object, ()>? previous,
      ArgCommandState<String, Object, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, Object, ()> of(WidgetRef ref) =>
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
