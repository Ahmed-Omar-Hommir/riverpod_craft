// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../error_mapper.dart';
import '../result.dart';
import 'async_state/async_state.dart';

/// Unified data notifier that supports both Future and Stream data sources.
///
/// Override [buildDataWithFuture] for one-time async data fetching,
/// or override [buildDataWithStream] for real-time stream data.
///
/// Set [isFuture] to `true` when using [buildDataWithFuture],
/// or `false` when using [buildDataWithStream].
abstract class DataNotifier<T, Arg extends Record>
    extends Notifier<DataState<T>>
    with ErrorMapper {
  /// The argument passed to this notifier, typically used to configure data fetching.
  late final Arg arg;

  StreamSubscription? _subscription;

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
    if (currentState is! DataSuccess<T>) return;
    state = DataSuccess<T>(data);
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

    if (!silent) state = DataLoading<T>();

    final completer = Completer<void>();

    try {
      _subscription = _buildData(arg).listen(
        (result) {
          switch (result) {
            case Ok<T>(value: final value):
              state = DataSuccess<T>(value);
            case Error<T>(error: final e):
              state = DataError(e);
          }

          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (e) {
          if (!silent) state = DataError(mapError(e));

          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
      );

      ref.onDispose(() => _subscription?.cancel());
    } catch (e) {
      if (!silent) state = DataError(mapError(e));
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  /// Builds the initial state by triggering data fetching with [arg].
  @override
  DataState<T> build() {
    _getData(arg);
    return DataLoading<T>();
  }

  /// Re-fetches the data, showing a loading state.
  Future<void> reload() => _getData(arg);

  /// Re-fetches the data without transitioning to a loading state.
  Future<void> silentReload() => _getData(arg, silent: true);
}
