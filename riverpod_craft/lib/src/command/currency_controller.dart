import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../data_provider/async_state/async_state.dart';
import 'command.dart';

class ConcurrentController<DataT, Arg extends Record>
    extends Bloc<_Fire<Arg>, ArgCommandState<DataT, Arg>> {
  ConcurrentController({
    required Future<DataT> Function(Arg arg) action,
    required ActionStrategy strategy,
    Object Function(Object error)? mapError,
  }) : _action = action,
       _mapError = mapError ?? _identity,
       super(ArgCommandState<DataT, Arg>.init()) {
    _setupEventHandler(strategy);
  }

  final Future<DataT> Function(Arg arg) _action;

  /// Maps a raw caught error before it is emitted as an error state.
  final Object Function(Object error) _mapError;

  static Object _identity(Object error) => error;

  void fire(Arg arg) => add(_Fire(arg));

  void _setupEventHandler(ActionStrategy strategy) {
    on<_Fire<Arg>>((event, emit) async {
      try {
        emit(ArgCommandState<DataT, Arg>.loading(event.arg));
        final data = await _action(event.arg);
        emit(ArgCommandState<DataT, Arg>.data(event.arg, data));
      } catch (e) {
        emit(ArgCommandState<DataT, Arg>.error(event.arg, _mapError(e)));
      }
    }, transformer: _getTransformer<_Fire<Arg>>(strategy));
  }

  Stream<E> Function(Stream<E>, Stream<E> Function(E))
  _getTransformer<E extends _Fire<Arg>>(ActionStrategy strategy) {
    switch (strategy) {
      case ActionStrategy.droppable:
        return droppable();
      case ActionStrategy.restartable:
        return restartable();
      case ActionStrategy.sequential:
        return sequential();
      case ActionStrategy.concurrent:
        return concurrent();
    }
  }
}

class _Fire<Arg> extends Equatable {
  const _Fire(this.arg);
  final Arg arg;

  @override
  List<Object?> get props => [arg];
}
