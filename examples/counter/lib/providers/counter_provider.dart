import 'package:riverpod_craft/riverpod_craft.dart';

part 'counter_provider.craft.dart';

@provider
@settable
int counter(Ref ref) => 0;

@provider
class BoundedCounter extends _$BoundedCounter {
  @override
  int create() => 0;

  void decrement() {
    if (state == 0) return;
    state = state - 1;
  }

  void increment() {
    if (state < 0) return;
    state = state + 1;
  }

  void reset() {
    state = 0;
  }
}
