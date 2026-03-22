part of 'user_provider.dart';

abstract class _$User extends DataNotifier<UserModel, ()> {
  @override
  bool get isFuture => true;

  Future<UserModel> create();
  @override
  Future<UserModel> buildDataWithFuture() => create();
}

final _userProvider = NotifierProvider<User, DataState<UserModel>>(
  () => User()..arg = (),
  isAutoDispose: true,
);

class $UserFacadeRef {
  $UserFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _userProvider;

  DataState<UserModel> read() => _ref.read(_provider);
  DataState<UserModel> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<UserModel> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(DataState<UserModel>? previous, DataState<UserModel> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<UserModel>>(_provider, listener, onError: onError);
  }
}

class $UserFacadeWidget
    implements DataProviderFacade<UserModel>, DataProviderValue<UserModel, ()> {
  $UserFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _userProvider;

  @override
  DataState<UserModel> read() => _ref.read(_provider);
  @override
  DataState<UserModel> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<UserModel> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(DataState<UserModel>? previous, DataState<UserModel> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<UserModel>>(_provider, listener, onError: onError);
  }

  @override
  DataProviderFacade<UserModel> of(WidgetRef ref) => $UserFacadeWidget(ref);
}

extension UserFacadeRefEx on Ref {
  $UserFacadeRef get userProvider => $UserFacadeRef(this);
}

extension UserFacadeWidgetRefEx on WidgetRef {
  $UserFacadeWidget get userProvider => $UserFacadeWidget(this);
}
