import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StateDataNotifier<T, Arg extends Record> extends Notifier<T> {
  late final Arg arg;

  T buildData(Arg arg);

  @override
  T build() => buildData(arg);

  @protected
  void setState(T value) {
    state = value;
  }

  /// Public method to update state from outside the notifier
  void updateState(T value) {
    state = value;
  }
}
