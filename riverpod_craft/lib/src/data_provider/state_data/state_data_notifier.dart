import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [Notifier] subclass that receives a typed argument record for building state.
///
/// [T] is the state type and [Arg] is a [Record] carrying the arguments
/// passed when the provider is first read.
abstract class StateDataNotifier<T, Arg extends Record> extends Notifier<T> {
  /// The argument record supplied to this notifier.
  late final Arg arg;

  /// Creates the initial state from the given [arg].
  T buildData(Arg arg);

  @override
  T build() => buildData(arg);
}
