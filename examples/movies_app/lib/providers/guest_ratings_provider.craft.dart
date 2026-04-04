part of 'guest_ratings_provider.dart';

final _guestRatingsProvider =
    NotifierProvider<$$GuestRatings, DataState<Map<int, double>>>(
      () => $$GuestRatings()..arg = (),
      isAutoDispose: true,
    );

class $$GuestRatings extends DataNotifier<Map<int, double>, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<Map<int, double>> buildDataWithFuture() => guestRatings(ref);
}

class $GuestRatingsFacadeRef {
  $GuestRatingsFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _guestRatingsProvider;

  DataState<Map<int, double>> read() => _ref.read(_provider);
  DataState<Map<int, double>> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<Map<int, double>> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(
      DataState<Map<int, double>>? previous,
      DataState<Map<int, double>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Map<int, double>>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $GuestRatingsFacadeWidget
    implements
        DataProviderFacade<Map<int, double>>,
        DataProviderValue<Map<int, double>, ()> {
  $GuestRatingsFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _guestRatingsProvider;

  @override
  DataState<Map<int, double>> read() => _ref.read(_provider);
  @override
  DataState<Map<int, double>> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Map<int, double>> state) selector,
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
      DataState<Map<int, double>>? previous,
      DataState<Map<int, double>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Map<int, double>>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<Map<int, double>> of(WidgetRef ref) =>
      $GuestRatingsFacadeWidget(ref);
}

extension GuestRatingsFacadeRefEx on Ref {
  $GuestRatingsFacadeRef get guestRatingsProvider =>
      $GuestRatingsFacadeRef(this);
}

extension GuestRatingsFacadeWidgetRefEx on WidgetRef {
  $GuestRatingsFacadeWidget get guestRatingsProvider =>
      $GuestRatingsFacadeWidget(this);
}
