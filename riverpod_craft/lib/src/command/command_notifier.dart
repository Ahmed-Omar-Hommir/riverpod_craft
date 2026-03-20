part of 'command.dart';

abstract class CommandNotifier<DataT, Arg extends Record>
    extends Notifier<ArgCommandState<DataT, Arg>> {
  late final KeepAliveManager _refManager;

  @protected
  abstract final ActionStrategy strategy;

  @protected
  Future<DataT> action(Ref ref, Arg arg);

  @protected
  abstract final List<Ref> refs;

  @override
  ArgCommandState<DataT, Arg> build() {
    _refManager = KeepAliveManager(refs: [ref, ...refs]);
    _controller = ConcurrentController<DataT, Arg>(
      action: (arg) async => action(ref, arg),
      strategy: strategy,
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

  late final ConcurrentController<DataT, Arg> _controller;
  StreamSubscription? _subscription;

  void reset() {
    if (!state.isDone) return;
    state = ArgCommandState.init();
  }

  void retry() {
    if (!state.isError) return;
    add(state.arg ?? () as Arg);
  }

  void add(Arg arg) {
    _controller.fire(arg);
  }

  void _dispose() async {
    await _controller.close();
    await _subscription?.cancel();
    _refManager.close();
  }
}
