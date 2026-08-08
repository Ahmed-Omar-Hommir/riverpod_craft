// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'async_state/async_state.dart';

/// Awaits a data provider's resolved value with a *selective* rebuild
/// dependency. Backs the reactive side of the generated `ref.xProvider.future`
/// accessor.
///
/// [future] awaits [selector] applied to the resolved data and rebuilds the
/// watcher only when the source starts a new load (Done → Loading) or the
/// *selected* value changes — not on the awaited Loading → Data resolution (the
/// future completes instead) and not on Loading → Failure (it throws instead).
///
/// The await is driven by the provider-bound [listen] subscription, so it
/// survives the source being invalidated (its notifier disposed and recreated)
/// any number of times mid-load.
class DataWatchHandle<T, F> {
  /// Creates a [DataWatchHandle]. The generated accessor supplies concretely
  /// typed callbacks bound to its own `Ref` and provider.
  DataWatchHandle({
    required DataState<T, F> Function() read,
    required void Function() reload,
    required void Function(
      void Function(DataState<T, F>? previous, DataState<T, F> next) listener,
    )
    listen,
    required void Function() invalidateSelf,
  }) : _read = read,
       _reload = reload,
       _listen = listen,
       _invalidateSelf = invalidateSelf;

  final DataState<T, F> Function() _read;
  final void Function() _reload;
  final void Function(
    void Function(DataState<T, F>? previous, DataState<T, F> next) listener,
  )
  _listen;
  final void Function() _invalidateSelf;

  /// Awaits [selector] applied to the resolved data, rebuilding the watcher
  /// only when the selected value changes (or a new load starts). When
  /// [forceRefetch] is set the source is reloaded first — before the listener
  /// is registered, so the handle's own Done → Loading does not self-invalidate.
  Future<R> future<R>(R Function(T data) selector, {bool forceRefetch = false}) {
    if (forceRefetch) _reload();

    final completer = Completer<R>();
    R? previousSelected;
    var hasSelected = false;

    void resolve(DataState<T, F> state) {
      if (state is DataSuccess<T, F>) {
        final selected = selector(state.data);
        if (hasSelected && selected != previousSelected) {
          _invalidateSelf();
          return;
        }
        previousSelected = selected;
        hasSelected = true;
        if (!completer.isCompleted) completer.complete(selected);
      } else if (state is DataError<T, F>) {
        if (!completer.isCompleted) {
          completer.completeError(state.error as Object);
        }
      }
    }

    _listen((previous, next) {
      // A new load started (from data or error) → the watcher should refetch.
      if (next is DataLoading<T, F> && previous is! DataLoading<T, F>) {
        _invalidateSelf();
        return;
      }
      resolve(next);
    });

    // The listener only fires on *future* changes; resolve the current value
    // synchronously (skipped for forceRefetch, which is mid-reload).
    if (!forceRefetch) resolve(_read());
    return completer.future;
  }
}

/// The `ref.xProvider.future` accessor for a data provider.
///
/// - [read] — one-shot; awaits the current value with no reactive dependency.
/// - [watch] — reactive; awaits the value and rebuilds the watcher when it
///   changes.
/// - [select] — narrows to a derived value (the `selectAsync` equivalent).
class DataFuture<T, F> {
  DataFuture(this._handle, this._readValue);

  final DataWatchHandle<T, F> _handle;
  final Future<T> Function(bool forceRefetch) _readValue;

  /// One-shot: awaits the current value without establishing a dependency.
  Future<T> read({bool forceRefetch = false}) => _readValue(forceRefetch);

  /// Reactive: awaits the value and rebuilds the watcher when it changes.
  Future<T> watch({bool forceRefetch = false}) =>
      _handle.future<T>((data) => data, forceRefetch: forceRefetch);

  /// Narrows to a derived value; `.select(...).watch()` rebuilds only when the
  /// selected value changes.
  SelectedDataFuture<T, F, R> select<R>(R Function(T data) selector) =>
      SelectedDataFuture<T, F, R>(_handle, _readValue, selector);
}

/// The `ref.xProvider.future.select(...)` accessor: awaits a derived value,
/// one-shot via [read] or reactively via [watch] (rebuilds only when the
/// selected value changes).
class SelectedDataFuture<T, F, R> {
  SelectedDataFuture(this._handle, this._readValue, this._selector);

  final DataWatchHandle<T, F> _handle;
  final Future<T> Function(bool forceRefetch) _readValue;
  final R Function(T data) _selector;

  /// One-shot: awaits the current selected value with no dependency.
  Future<R> read({bool forceRefetch = false}) async =>
      _selector(await _readValue(forceRefetch));

  /// Reactive: awaits the selected value, rebuilding only when it changes.
  Future<R> watch({bool forceRefetch = false}) =>
      _handle.future<R>(_selector, forceRefetch: forceRefetch);
}
