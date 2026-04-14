import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

import 'data_provider/async_state/async_state.dart';
import 'pagination/paged_data_state.dart';

// ─── Selected facades ────────────────────────────────────────────────

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

// ─── Async base facade ───────────────────────────────────────────────

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

// ─── Data facade ─────────────────────────────────────────────────────

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

// ─── Command facade ──────────────────────────────────────────────────

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

// ─── Paged data facade ──────────────────────────────────────────────

/// Interface for interacting with a paginated provider's state.
///
/// Generated Widget facades implement this.
abstract class PagedProviderFacade<T> {
  PagedDataState<T> read();
  PagedDataState<T> watch();
  void fetchNextPage();
  void invalidate();

  void listen(
    void Function(PagedDataState<T>? previous, PagedDataState<T> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}

abstract class ProviderFacade<T> {
  T read();
  T watch();
  void invalidate();

  void listen(
    void Function(T? previous, T next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}
