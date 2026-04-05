// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'counter_provider.dart';

final _counterProvider = NotifierProvider<$$Counter, int>(
  () => $$Counter()..arg = (),
  isAutoDispose: true,
);

class $$Counter extends StateDataNotifier<int, ()> {
  @override
  int buildData(() arg) => counter(ref);
}

class $CounterFacadeRef {
  $CounterFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _counterProvider;

  int read() => _ref.read(_provider);
  int watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(int state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void setState(int value) => _ref.read(_provider.notifier).state = value;

  void listen(
    void Function(int? previous, int next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int>(_provider, listener, onError: onError);
  }
}

class $CounterFacadeWidget {
  $CounterFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _counterProvider;

  int read() => _ref.read(_provider);
  int watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(R Function(int state) selector) =>
      SelectedWidgetRefFacade(_ref, _provider.select(selector));

  void setState(int value) => _ref.read(_provider.notifier).state = value;

  void listen(
    void Function(int? previous, int next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int>(_provider, listener, onError: onError);
  }
}

extension CounterFacadeRefEx on Ref {
  $CounterFacadeRef get counterProvider => $CounterFacadeRef(this);
}

extension CounterFacadeWidgetRefEx on WidgetRef {
  $CounterFacadeWidget get counterProvider => $CounterFacadeWidget(this);
}

abstract class _$BoundedCounter extends StateDataNotifier<int, ()> {
  int create();
  @override
  int buildData(() arg) => create();
}

final _boundedCounterProvider = NotifierProvider<BoundedCounter, int>(
  () => BoundedCounter()..arg = (),
  isAutoDispose: true,
);

class $BoundedCounterFacadeRef {
  $BoundedCounterFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _boundedCounterProvider;

  int read() => _ref.read(_provider);
  int watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(int state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(int? previous, int next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int>(_provider, listener, onError: onError);
  }

  void decrement() => _ref.read(_provider.notifier).decrement();

  void increment() => _ref.read(_provider.notifier).increment();

  void reset() => _ref.read(_provider.notifier).reset();
}

class $BoundedCounterFacadeWidget {
  $BoundedCounterFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _boundedCounterProvider;

  int read() => _ref.read(_provider);
  int watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(R Function(int state) selector) =>
      SelectedWidgetRefFacade(_ref, _provider.select(selector));

  void listen(
    void Function(int? previous, int next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int>(_provider, listener, onError: onError);
  }

  void decrement() => _ref.read(_provider.notifier).decrement();

  void increment() => _ref.read(_provider.notifier).increment();

  void reset() => _ref.read(_provider.notifier).reset();
}

extension BoundedCounterFacadeRefEx on Ref {
  $BoundedCounterFacadeRef get boundedCounterProvider =>
      $BoundedCounterFacadeRef(this);
}

extension BoundedCounterFacadeWidgetRefEx on WidgetRef {
  $BoundedCounterFacadeWidget get boundedCounterProvider =>
      $BoundedCounterFacadeWidget(this);
}
