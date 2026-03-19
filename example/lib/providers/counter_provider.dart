import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_gen/riverpod_gen.dart';

part 'counter_provider.pg.dart';

/// A simple provider that manages a counter state.
///
/// Uses @provider annotation on a class with @command methods
/// to demonstrate state management with commands.
@provider
class Counter extends _$Counter {
  @override
  int create() => 0;

  @override
  @command
  @droppable
  Future<int> increment() async {
    // Simulate async work
    await Future.delayed(const Duration(milliseconds: 300));
    final next = ref.read(_counterProvider) + 1;
    setState(next);
    return next;
  }

  @override
  @command
  @droppable
  Future<int> decrement() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final next = ref.read(_counterProvider) - 1;
    setState(next);
    return next;
  }
}
