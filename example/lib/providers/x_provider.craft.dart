part of 'x_provider.dart';

final _nameProvider =
    NotifierProvider<$$Name, DataState<String, CraftError<MyNameException>>>(
      () => $$Name()..arg = (),
      isAutoDispose: true,
    );

class $$Name extends DataNotifier<String, (), CraftError<MyNameException>> {
  @override
  bool get isFuture => true;

  @override
  Future<String> buildDataWithFuture() async {
    try {
      return await name(ref);
    } catch (e, st) {
      if (e is MyNameException) throw Expected<MyNameException>(e);
      throw Unexpected<MyNameException>(e, st);
    }
  }
}

class $NameFacadeRef {
  $NameFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _nameProvider;

  DataState<String, CraftError<MyNameException>> read() => _ref.read(_provider);
  DataState<String, CraftError<MyNameException>> watch() =>
      _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<String, CraftError<MyNameException>> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(
      DataState<String, CraftError<MyNameException>>? previous,
      DataState<String, CraftError<MyNameException>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<String, CraftError<MyNameException>>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $NameFacadeWidget
    implements DataProviderFacade<String>, DataProviderValue<String, ()> {
  $NameFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _nameProvider;

  @override
  DataState<String, CraftError<MyNameException>> read() => _ref.read(_provider);
  @override
  DataState<String, CraftError<MyNameException>> watch() =>
      _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<String, CraftError<MyNameException>> state) selector,
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
      DataState<String, CraftError<MyNameException>>? previous,
      DataState<String, CraftError<MyNameException>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<String, CraftError<MyNameException>>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<String> of(WidgetRef ref) => $NameFacadeWidget(ref);
}

extension NameFacadeRefEx on Ref {
  $NameFacadeRef get nameProvider => $NameFacadeRef(this);
}

extension NameFacadeWidgetRefEx on WidgetRef {
  $NameFacadeWidget get nameProvider => $NameFacadeWidget(this);
}
