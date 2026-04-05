import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StateDataNotifier<T, Arg extends Record> extends Notifier<T> {
  late final Arg arg;

  T buildData(Arg arg);

  @override
  T build() => buildData(arg);

}
