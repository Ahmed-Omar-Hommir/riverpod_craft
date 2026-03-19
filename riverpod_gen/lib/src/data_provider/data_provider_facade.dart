import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

import 'async_state/async_state.dart';

/// A facade for selected provider state that supports chained select syntax:
/// `ref.myProvider.select((s) => s.isLoading).watch()`
class SelectedRefFacade<R> {
  SelectedRefFacade(this._ref, this._selectedProvider);
  final Ref _ref;
  final ProviderListenable<R> _selectedProvider;

  R read() => _ref.read(_selectedProvider);
  R watch() => _ref.watch(_selectedProvider);
  void listen(
    void Function(R? previous, R next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_selectedProvider, listener, onError: onError);
  }
}

/// A facade for selected provider state for WidgetRef
class SelectedWidgetRefFacade<R> {
  SelectedWidgetRefFacade(this._ref, this._selectedProvider);
  final WidgetRef _ref;
  final ProviderListenable<R> _selectedProvider;

  R read() => _ref.read(_selectedProvider);
  R watch() => _ref.watch(_selectedProvider);
  void listen(
    void Function(R? previous, R next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_selectedProvider, listener, onError: onError);
  }
}

abstract class DataProviderFacade<T> extends AsyncProviderFacade<T, Record> {
  @override
  DataState<T> read();
  @override
  DataState<T> watch();

  @override
  void invalidate();

  Future<void> reload();
  Future<void> silentReload();

  @override
  void listen(
    void Function(DataState<T>? previous, DataState<T> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}

abstract class CommandProviderFacade<T, ArgT extends Record>
    extends AsyncProviderFacade<T, ArgT> {
  @override
  ArgCommandState<T, ArgT> read();
  @override
  ArgCommandState<T, ArgT> watch();

  void reset();
  void retry();

  @override
  void listen(
    void Function(
      ArgCommandState<T, ArgT>? previous,
      ArgCommandState<T, ArgT> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}

abstract class AsyncProviderFacade<T, ArgT extends Record> {
  AsynchronousState<T, ArgT> read();
  AsynchronousState<T, ArgT> watch();
  void invalidate();

  void listen(
    void Function(
      AsynchronousState<T, ArgT>? previous,
      AsynchronousState<T, ArgT> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });

  AsyncProviderFacade<T, ArgT> of(WidgetRef ref);
}

// Provider Value
abstract class AsyncProviderValue<
  T,
  ArgT extends Record,
  FacadeT extends AsyncProviderFacade<T, ArgT>
> {
  FacadeT of(WidgetRef ref);
}

abstract class CommandProviderValue<T, ArgT extends Record>
    implements AsyncProviderValue<T, ArgT, CommandProviderFacade<T, ArgT>> {
  @override
  CommandProviderFacade<T, ArgT> of(WidgetRef ref);
}

abstract class DataProviderValue<T, ArgT extends Record>
    implements AsyncProviderValue<T, Record, DataProviderFacade<T>> {
  @override
  DataProviderFacade<T> of(WidgetRef ref);
}
