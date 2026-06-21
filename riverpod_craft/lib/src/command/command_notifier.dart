part of 'command.dart';

/// A notifier that executes an asynchronous [action] and exposes its state.
///
/// Subclass this to define a command with a specific [ActionStrategy].
abstract class CommandNotifier<DataT, F extends Object, Arg extends Record>
    extends Notifier<ArgCommandState<DataT, F, Arg>>
    with ErrorMapper<F> {
  late final KeepAliveManager _refManager;

  /// The concurrency strategy used when multiple actions are triggered.
  @protected
  abstract final ActionStrategy strategy;

  /// The asynchronous work performed when the command is triggered.
  @protected
  Future<DataT> action(Ref ref, Arg arg);

  /// Additional [Ref]s whose providers should be kept alive during execution.
  @protected
  abstract final List<Ref> refs;

  /// Initializes the controller, subscriptions, and keep-alive manager.
  @override
  ArgCommandState<DataT, F, Arg> build() {
    _refManager = KeepAliveManager(refs: [ref, ...refs]);
    _controller = ConcurrentController<DataT, F, Arg>(
      action: (arg) async => action(ref, arg),
      strategy: strategy,
      mapError: mapError,
    );
    _initializeController();
    ref.onDispose(() => _dispose());
    return ArgCommandState.init();
  }

  void _initializeController() {
    final stream = _controller.stream;
    _subscription = stream.listen((newState) async {
      state = newState;

      newState.whenOrNull(
        loading: (_) {
          _refManager.keepAlive();
        },
        data: (_, _) {
          _refManager.close();
        },
        error: (arg, error) {
          _refManager.close();
        },
      );
    });
  }

  late final ConcurrentController<DataT, F, Arg> _controller;
  StreamSubscription? _subscription;

  /// Resets the command state to its initial value if the current action is done.
  void reset() {
    if (!state.isDone) return;
    state = ArgCommandState.init();
  }

  /// Retries the last failed action using the same arguments.
  void retry() {
    if (!state.isError) return;
    add(state.arg ?? () as Arg);
  }

  /// Triggers the command action with the given [arg].
  void add(Arg arg) {
    _controller.fire(arg);
  }

  void _dispose() async {
    await _controller.close();
    await _subscription?.cancel();
    _refManager.close();
  }
}
