part of 'xcounter_provider.dart';

abstract class _$Counter extends StateDataNotifier<int, ()> {
  int create();
  @override
  int buildData(() arg) => create();

  Future<int> increment();

  late final _$incrementCommand = NotifierProvider(
    () => _$IncrementCommandCounter(this as Counter),
    isAutoDispose: true,
  );

  $IncrementCommandFacadeCounterRef get incrementCommand =>
      $IncrementCommandFacadeCounterRef(ref, this as Counter);
  Future<int> decrement();

  late final _$decrementCommand = NotifierProvider(
    () => _$DecrementCommandCounter(this as Counter),
    isAutoDispose: true,
  );

  $DecrementCommandFacadeCounterRef get decrementCommand =>
      $DecrementCommandFacadeCounterRef(ref, this as Counter);
}

final _counterProvider = NotifierProvider(
  () => Counter()..arg = (),
  isAutoDispose: true,
);

class $CounterFacadeRef {
  $CounterFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _counterProvider;

  int read() => _ref.read(_provider);
  int watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(int state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void setState(int value) => _ref.read(_provider.notifier).updateState(value);

  void listen(
    void Function(int? previous, int next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int>(_provider, listener, onError: onError);
  }

  $IncrementCommandFacadeCounterRef get incrementCommand =>
      $IncrementCommandFacadeCounterRef(_ref, _ref.read(_provider.notifier));
  $DecrementCommandFacadeCounterRef get decrementCommand =>
      $DecrementCommandFacadeCounterRef(_ref, _ref.read(_provider.notifier));
}

class $CounterFacadeWidget {
  $CounterFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _counterProvider;

  int read() => _ref.read(_provider);
  int watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(R Function(int state) selector) =>
      SelectedWidgetRefFacade(_ref, _provider.select(selector));

  void setState(int value) => _ref.read(_provider.notifier).updateState(value);

  void listen(
    void Function(int? previous, int next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int>(_provider, listener, onError: onError);
  }

  $IncrementCommandFacadeCounterWidget get incrementCommand =>
      $IncrementCommandFacadeCounterWidget(_ref, _ref.read(_provider.notifier));
  $DecrementCommandFacadeCounterWidget get decrementCommand =>
      $DecrementCommandFacadeCounterWidget(_ref, _ref.read(_provider.notifier));
}

class _$IncrementCommandCounter extends CommandNotifier<int, ()> {
  _$IncrementCommandCounter(this._instance);
  final Counter _instance;

  @override
  Future<int> action(Ref ref, () arg) => _instance.increment();

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class _$DecrementCommandCounter extends CommandNotifier<int, ()> {
  _$DecrementCommandCounter(this._instance);
  final Counter _instance;

  @override
  Future<int> action(Ref ref, () arg) => _instance.decrement();

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class $IncrementCommandFacadeCounterRef {
  $IncrementCommandFacadeCounterRef(this._ref, this._instance);
  final Counter _instance;

  final Ref _ref;

  late final _command = _instance._$incrementCommand;

  ArgCommandState<int, ()> read() => _ref.read(_command);
  ArgCommandState<int, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<int, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<int, ()>? previous,
      ArgCommandState<int, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $DecrementCommandFacadeCounterRef {
  $DecrementCommandFacadeCounterRef(this._ref, this._instance);
  final Counter _instance;

  final Ref _ref;

  late final _command = _instance._$decrementCommand;

  ArgCommandState<int, ()> read() => _ref.read(_command);
  ArgCommandState<int, ()> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<int, ()> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run() => _ref.read(_command.notifier).add(());
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<int, ()>? previous,
      ArgCommandState<int, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $IncrementCommandFacadeCounterWidget
    implements CommandProviderFacade<int, ()>, CommandProviderValue<int, ()> {
  $IncrementCommandFacadeCounterWidget(this._ref, this._instance);
  final Counter _instance;

  final WidgetRef _ref;

  late final _command = _instance._$incrementCommand;

  @override
  ArgCommandState<int, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<int, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<int, ()> state) selector,
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
      ArgCommandState<int, ()>? previous,
      ArgCommandState<int, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<int, ()> of(WidgetRef ref) =>
      $IncrementCommandFacadeCounterWidget(ref, _instance);
}

class $DecrementCommandFacadeCounterWidget
    implements CommandProviderFacade<int, ()>, CommandProviderValue<int, ()> {
  $DecrementCommandFacadeCounterWidget(this._ref, this._instance);
  final Counter _instance;

  final WidgetRef _ref;

  late final _command = _instance._$decrementCommand;

  @override
  ArgCommandState<int, ()> read() => _ref.read(_command);
  @override
  ArgCommandState<int, ()> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<int, ()> state) selector,
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
      ArgCommandState<int, ()>? previous,
      ArgCommandState<int, ()> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<int, ()> of(WidgetRef ref) =>
      $DecrementCommandFacadeCounterWidget(ref, _instance);
}

extension CounterFacadeRefEx on Ref {
  $CounterFacadeRef get counterProvider => $CounterFacadeRef(this);
}

extension CounterFacadeWidgetRefEx on WidgetRef {
  $CounterFacadeWidget get counterProvider => $CounterFacadeWidget(this);
}
