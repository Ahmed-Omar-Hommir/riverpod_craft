// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../error_mapper.dart';
import '../provider_init.dart';
import '../result.dart';
import 'async_state/async_state.dart';

/// Unified data notifier that supports both Future and Stream data sources.
///
/// Override [buildDataWithFuture] for one-time async data fetching,
/// or override [buildDataWithStream] for real-time stream data.
///
/// Set [isFuture] to `true` when using [buildDataWithFuture],
/// or `false` when using [buildDataWithStream].
///
/// [F] is the error type stored in [DataError] — `Object` by default, or your
/// custom type when a global `error_mapper` is configured.
abstract class DataNotifier<T, F, Arg extends Record>
    extends Notifier<DataState<T, F>>
    with ErrorMapper<F> {
  /// The argument passed to this notifier, typically used to configure data fetching.
  late final Arg arg;

  StreamSubscription? _subscription;

  /// Completes when the current in-flight load settles (to data or error).
  Future<void>? _inFlight;

  /// Set to `true` to use [buildDataWithFuture], `false` to use [buildDataWithStream].
  @protected
  bool get isFuture;

  /// Override this method when [isFuture] is `true`.
  /// Returns a Future that resolves to the data.
  @protected
  Future<T> buildDataWithFuture() => throw UnimplementedError(
    'buildDataWithFuture() must be implemented when isFuture is true',
  );

  /// Override this method when [isFuture] is `false`.
  /// Returns a Stream that emits data updates.
  @protected
  Stream<T> buildDataWithStream() => throw UnimplementedError(
    'buildDataWithStream() must be implemented when isFuture is false',
  );

  /// Manually updates the current data if the state is [DataSuccess].
  @protected
  void setData(T data) {
    final currentState = state;
    if (currentState is! DataSuccess<T, F>) return;
    state = DataSuccess<T, F>(data);
  }

  Stream<Result<T>> _buildData(Arg arg) async* {
    if (isFuture) {
      try {
        final response = await buildDataWithFuture();
        yield Result.ok(response);
      } catch (e) {
        if (e is Error<T>) {
          yield e;
        } else {
          yield Result.error(mapError(e));
        }
      }
    } else {
      try {
        yield* buildDataWithStream().map((data) => Result.ok(data));
      } catch (e) {
        if (e is Error<T>) {
          yield e;
        } else {
          yield Result.error(mapError(e));
        }
      }
    }
  }

  Future<void> _getData(Arg arg, {bool silent = false}) async {
    _subscription?.cancel();

    if (!silent) state = DataLoading<T, F>();

    final completer = Completer<void>();
    _inFlight = completer.future;

    try {
      _subscription = _buildData(arg).listen(
        (result) {
          switch (result) {
            case Ok<T>(value: final value):
              state = DataSuccess<T, F>(value);
            case Error<T>(error: final e):
              state = DataError<T, F>(e);
          }

          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (e) {
          if (!silent) state = DataError<T, F>(mapError(e));

          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
      );

      ref.onDispose(() => _subscription?.cancel());
    } catch (e) {
      if (!silent) state = DataError<T, F>(mapError(e));
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  /// Runs once per notifier instance, before the first fetch. Defaults to the
  /// globally-registered [RiverpodCraft.providerInit]; the generator overrides
  /// it to a no-op for providers annotated `@noInit`.
  @protected
  Future<void> init() async {
    final hook = RiverpodCraft.providerInit;
    if (hook != null) await hook(ref, this, arg);
  }

  /// Builds the initial state by triggering data fetching with [arg].
  @override
  DataState<T, F> build() {
    _bootstrap();
    return DataLoading<T, F>();
  }

  Future<void> _bootstrap() async {
    await init();
    await _getData(arg);
  }

  /// Re-fetches the data, showing a loading state.
  Future<void> reload() => _getData(arg);

  /// Re-fetches the data without transitioning to a loading state.
  Future<void> silentReload() => _getData(arg, silent: true);

  /// Awaits the resolved value: returns it if the state is (or becomes)
  /// [DataSuccess], or throws the [DataError] error [F] if it fails. If a load
  /// is in flight, waits for it to settle first.
  Future<T> awaitValue() async {
    final inFlight = _inFlight;
    if (inFlight != null) {
      try {
        await inFlight;
      } catch (_) {
        // The outcome is reflected in [state]; read it below.
      }
    }

    final settled = state;
    if (settled is DataSuccess<T, F>) return settled.data;
    if (settled is DataError<T, F>) throw settled.error as Object;

    // Loading with no in-flight load (e.g. never built): kick one off.
    await reload();
    final resolved = state;
    if (resolved is DataSuccess<T, F>) return resolved.data;
    if (resolved is DataError<T, F>) throw resolved.error as Object;
    throw StateError('DataNotifier.awaitValue: state did not resolve');
  }

  /// Awaits the value with cache/refetch control:
  /// - returns the cached value when already [DataSuccess] and not [forceRefetch];
  /// - reloads first when [forceRefetch] is set or the state is [DataError];
  /// - otherwise awaits the in-flight load.
  ///
  /// Throws the mapped error [F] if the fetch fails.
  Future<T> future({bool forceRefetch = false}) async {
    final current = state;
    if (current is DataSuccess<T, F> && !forceRefetch) return current.data;
    if (forceRefetch || current is DataError<T, F>) {
      await reload();
    }
    return awaitValue();
  }
}
