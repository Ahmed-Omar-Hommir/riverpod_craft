// ignore_for_file: prefer_initializing_formals

import 'async_state/async_state.dart';

/// Backs the reactive `ref.xProvider.future(watch: true)` accessor.
///
/// [future] awaits the provider's resolved value while establishing a
/// *selective* dependency: the watcher rebuilds when the source starts a new
/// load (Done → Loading) or its data changes, but not on the awaited
/// Loading → Data resolution (the future completes with the value instead) and
/// not on Loading → Failure (the future throws instead).
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
    required Future<T> Function() awaitValue,
  }) : _read = read,
       _reload = reload,
       _listen = listen,
       _invalidateSelf = invalidateSelf,
       _awaitValue = awaitValue;

  final DataState<T, F> Function() _read;
  final void Function() _reload;
  final void Function(
    void Function(DataState<T, F>? previous, DataState<T, F> next) listener,
  )
  _listen;
  final void Function() _invalidateSelf;
  final Future<T> Function() _awaitValue;

  /// Awaits the resolved value with the selective rebuild dependency (see the
  /// class doc for the transition rules).
  ///
  /// When [forceRefetch] is set, the source is reloaded first so the awaited
  /// value is fresh. That reload is triggered *before* the selective listener
  /// is registered, so the handle's own Done → Loading transition does not
  /// self-invalidate the watcher.
  Future<T> future({bool forceRefetch = false}) {
    if (forceRefetch) _reload();

    _listen((previous, next) {
      if (_shouldRebuild(previous, next)) _invalidateSelf();
    });

    final current = _read();
    if (current is DataSuccess<T, F> && !forceRefetch) {
      return Future<T>.value(current.data);
    }
    return _awaitValue();
  }

  bool _shouldRebuild(DataState<T, F>? previous, DataState<T, F> next) {
    // A new load started (from data or error) → the watcher should refetch.
    if (next is DataLoading<T, F> && previous is! DataLoading<T, F>) return true;
    // The data changed in place (e.g. setData) without a loading transition.
    if (previous is DataSuccess<T, F> &&
        next is DataSuccess<T, F> &&
        previous != next) {
      return true;
    }
    return false;
  }
}
