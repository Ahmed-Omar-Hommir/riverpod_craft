part of 'todo_provider.dart';

final _$addTodoCommand = NotifierProvider(
  () => _$AddTodoCommand(),
  isAutoDispose: true,
);

class _$AddTodoCommand extends CommandNotifier<Todo, ({String title})> {
  @override
  Future<Todo> action(Ref ref, ({String title}) arg) =>
      addTodo(ref, title: arg.title);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class $AddTodoCommandFacadeRef {
  $AddTodoCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$addTodoCommand;

  ArgCommandState<Todo, ({String title})> read() => _ref.read(_command);
  ArgCommandState<Todo, ({String title})> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<Todo, ({String title})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required String title}) =>
      _ref.read(_command.notifier).add((title: title));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<Todo, ({String title})>? previous,
      ArgCommandState<Todo, ({String title})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $AddTodoCommandFacadeWidget
    implements
        CommandProviderFacade<Todo, ({String title})>,
        CommandProviderValue<Todo, ({String title})> {
  $AddTodoCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$addTodoCommand;

  @override
  ArgCommandState<Todo, ({String title})> read() => _ref.read(_command);
  @override
  ArgCommandState<Todo, ({String title})> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<Todo, ({String title})> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({required String title}) =>
      _ref.read(_command.notifier).add((title: title));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<Todo, ({String title})>? previous,
      ArgCommandState<Todo, ({String title})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<Todo, ({String title})> of(WidgetRef ref) =>
      $AddTodoCommandFacadeWidget(ref);
}

extension $AddTodoCommandRefEx on Ref {
  $AddTodoCommandFacadeRef get addTodoCommand => $AddTodoCommandFacadeRef(this);
}

extension $AddTodoCommandWidgetRefEx on WidgetRef {
  $AddTodoCommandFacadeWidget get addTodoCommand =>
      $AddTodoCommandFacadeWidget(this);
}

final _$toggleTodoCommand = NotifierProvider(
  () => _$ToggleTodoCommand(),
  isAutoDispose: true,
);

class _$ToggleTodoCommand extends CommandNotifier<Todo, ({Todo todo})> {
  @override
  Future<Todo> action(Ref ref, ({Todo todo}) arg) =>
      toggleTodo(ref, todo: arg.todo);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class $ToggleTodoCommandFacadeRef {
  $ToggleTodoCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$toggleTodoCommand;

  ArgCommandState<Todo, ({Todo todo})> read() => _ref.read(_command);
  ArgCommandState<Todo, ({Todo todo})> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<Todo, ({Todo todo})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required Todo todo}) =>
      _ref.read(_command.notifier).add((todo: todo));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<Todo, ({Todo todo})>? previous,
      ArgCommandState<Todo, ({Todo todo})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $ToggleTodoCommandFacadeWidget
    implements
        CommandProviderFacade<Todo, ({Todo todo})>,
        CommandProviderValue<Todo, ({Todo todo})> {
  $ToggleTodoCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$toggleTodoCommand;

  @override
  ArgCommandState<Todo, ({Todo todo})> read() => _ref.read(_command);
  @override
  ArgCommandState<Todo, ({Todo todo})> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<Todo, ({Todo todo})> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({required Todo todo}) =>
      _ref.read(_command.notifier).add((todo: todo));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<Todo, ({Todo todo})>? previous,
      ArgCommandState<Todo, ({Todo todo})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<Todo, ({Todo todo})> of(WidgetRef ref) =>
      $ToggleTodoCommandFacadeWidget(ref);
}

extension $ToggleTodoCommandRefEx on Ref {
  $ToggleTodoCommandFacadeRef get toggleTodoCommand =>
      $ToggleTodoCommandFacadeRef(this);
}

extension $ToggleTodoCommandWidgetRefEx on WidgetRef {
  $ToggleTodoCommandFacadeWidget get toggleTodoCommand =>
      $ToggleTodoCommandFacadeWidget(this);
}
