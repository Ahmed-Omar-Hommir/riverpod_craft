part of 'typed_error_provider.dart';

final _userNameProvider =
    NotifierProvider<$$UserName, DataState<String, CraftError<NameError>>>(
      () => $$UserName()..arg = (),
      isAutoDispose: true,
    );

class $$UserName extends DataNotifier<String, (), CraftError<NameError>> {
  @override
  bool get isFuture => true;

  @override
  Future<String> buildDataWithFuture() async {
    try {
      return await userName(ref);
    } catch (e, st) {
      if (e is NameError) throw Expected<NameError>(e);
      throw Unexpected<NameError>(e, st);
    }
  }
}

class $UserNameFacadeRef {
  $UserNameFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _userNameProvider;

  DataState<String, CraftError<NameError>> read() => _ref.read(_provider);
  DataState<String, CraftError<NameError>> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<String, CraftError<NameError>> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(
      DataState<String, CraftError<NameError>>? previous,
      DataState<String, CraftError<NameError>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<String, CraftError<NameError>>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $UserNameFacadeWidget
    implements DataProviderFacade<String>, DataProviderValue<String, ()> {
  $UserNameFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _userNameProvider;

  @override
  DataState<String, CraftError<NameError>> read() => _ref.read(_provider);
  @override
  DataState<String, CraftError<NameError>> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<String, CraftError<NameError>> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(
      DataState<String, CraftError<NameError>>? previous,
      DataState<String, CraftError<NameError>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<String, CraftError<NameError>>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<String> of(WidgetRef ref) => $UserNameFacadeWidget(ref);
}

extension UserNameFacadeRefEx on Ref {
  $UserNameFacadeRef get userNameProvider => $UserNameFacadeRef(this);
}

extension UserNameFacadeWidgetRefEx on WidgetRef {
  $UserNameFacadeWidget get userNameProvider => $UserNameFacadeWidget(this);
}
