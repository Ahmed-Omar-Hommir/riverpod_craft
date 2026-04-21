part of 'command.dart';

/// Defines how concurrent invocations of a command action are handled.
enum ActionStrategy {
  /// Cancels the in-flight action and restarts with the new arguments.
  restartable,

  /// Drops new invocations while an action is already in-flight.
  droppable,

  /// Queues invocations and executes them one at a time in order.
  sequential,

  /// Runs all invocations concurrently without cancellation or queuing.
  concurrent,
}
