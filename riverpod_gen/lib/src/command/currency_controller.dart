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
  }) : _action = action,
       super(ArgCommandState<DataT, Arg>.init()) {
    _setupEventHandler(strategy);
  }

  final Future<DataT> Function(Arg arg) _action;

  void fire(Arg arg) => add(_Fire(arg));

  void _setupEventHandler(ActionStrategy strategy) {
    on<_Fire<Arg>>((event, emit) async {
      try {
        emit(ArgCommandState<DataT, Arg>.loading(event.arg));
        final data = await _action(event.arg);
        emit(ArgCommandState<DataT, Arg>.data(event.arg, data));
      } catch (e) {
        emit(ArgCommandState<DataT, Arg>.error(event.arg, e));
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
