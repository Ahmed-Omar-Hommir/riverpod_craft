import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

import 'data_provider/async_state/async_state.dart';
import 'pagination/paged_data_state.dart';

// ─── Selected facades ────────────────────────────────────────────────

/// A facade for selected provider state that supports chained select syntax:
/// `ref.myProvider.select((s) => s.isLoading).watch()`
class SelectedRefFacade<R> {
  /// Creates a [SelectedRefFacade] wrapping a [Ref] and a selected provider.
  SelectedRefFacade(this._ref, this._selectedProvider);
  final Ref _ref;
  final ProviderListenable<R> _selectedProvider;

  /// Reads the current selected value without subscribing.
  R read() => _ref.read(_selectedProvider);

  /// Watches the selected value, rebuilding when it changes.
  R watch() => _ref.watch(_selectedProvider);

  /// Listens to changes in the selected value.
  void listen(
    void Function(R? previous, R next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_selectedProvider, listener, onError: onError);
  }
}

/// A facade for selected provider state for WidgetRef.
class SelectedWidgetRefFacade<R> {
  /// Creates a [SelectedWidgetRefFacade] wrapping a [WidgetRef] and a selected provider.
  SelectedWidgetRefFacade(this._ref, this._selectedProvider);
  final WidgetRef _ref;
  final ProviderListenable<R> _selectedProvider;

  /// Reads the current selected value without subscribing.
  R read() => _ref.read(_selectedProvider);

  /// Watches the selected value, rebuilding the widget when it changes.
  R watch() => _ref.watch(_selectedProvider);

  /// Listens to changes in the selected value.
  void listen(
    void Function(R? previous, R next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_selectedProvider, listener, onError: onError);
  }
}

// ─── Async base facade ───────────────────────────────────────────────

/// Base facade interface for providers backed by asynchronous state.
abstract class AsyncProviderFacade<T, ArgT extends Record> {
  /// Reads the current async state without subscribing.
  AsynchronousState<T, ArgT> read();

  /// Watches the async state, rebuilding when it changes.
  AsynchronousState<T, ArgT> watch();

  /// Invalidates the provider, causing it to be recomputed.
  void invalidate();

  /// Listens to changes in the async state.
  void listen(
    void Function(
      AsynchronousState<T, ArgT>? previous,
      AsynchronousState<T, ArgT> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });

  /// Returns a new facade scoped to the given [WidgetRef].
  AsyncProviderFacade<T, ArgT> of(WidgetRef ref);
}

// ─── Data facade ─────────────────────────────────────────────────────

/// Facade for data providers that fetch and cache a single value.
abstract class DataProviderFacade<T> extends AsyncProviderFacade<T, Record> {
  /// Reads the current data state without subscribing.
  @override
  DataState<T> read();

  /// Watches the data state, rebuilding when it changes.
  @override
  DataState<T> watch();

  /// Invalidates the data provider, causing a refetch.
  @override
  void invalidate();

  /// Triggers a full reload of the data.
  Future<void> reload();

  /// Reloads data silently without showing a loading indicator.
  Future<void> silentReload();

  /// Listens to changes in the data state.
  @override
  void listen(
    void Function(DataState<T>? previous, DataState<T> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}

// ─── Command facade ──────────────────────────────────────────────────

/// Facade for command providers that execute actions with arguments.
abstract class CommandProviderFacade<T, ArgT extends Record>
    extends AsyncProviderFacade<T, ArgT> {
  /// Reads the current command state without subscribing.
  @override
  ArgCommandState<T, ArgT> read();

  /// Watches the command state, rebuilding when it changes.
  @override
  ArgCommandState<T, ArgT> watch();

  /// Resets the command state back to idle.
  void reset();

  /// Retries the last failed command execution.
  void retry();

  /// Listens to changes in the command state.
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
  /// Reads the current paged data state without subscribing.
  PagedDataState<T> read();

  /// Watches the paged data state, rebuilding when it changes.
  PagedDataState<T> watch();

  /// Fetches the next page of results.
  void fetchNextPage();

  /// Invalidates the paged provider, resetting pagination.
  void invalidate();

  /// Listens to changes in the paged data state.
  void listen(
    void Function(PagedDataState<T>? previous, PagedDataState<T> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}

/// Facade for simple synchronous providers.
abstract class ProviderFacade<T> {
  /// Reads the current value without subscribing.
  T read();

  /// Watches the value, rebuilding when it changes.
  T watch();

  /// Invalidates the provider, causing it to be recomputed.
  void invalidate();

  /// Listens to changes in the provider value.
  void listen(
    void Function(T? previous, T next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}
