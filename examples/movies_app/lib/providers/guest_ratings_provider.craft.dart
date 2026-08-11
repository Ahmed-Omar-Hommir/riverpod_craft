// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'guest_ratings_provider.dart';

final _guestRatingsProvider =
    NotifierProvider<$$GuestRatings, DataState<Map<int, double>, Object>>(
      () => $$GuestRatings()..arg = (),
      isAutoDispose: true,
    );

class $$GuestRatings extends DataNotifier<Map<int, double>, Object, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<Map<int, double>> buildDataWithFuture() => guestRatings(ref);
}

class $GuestRatingsFacadeRef {
  $GuestRatingsFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _guestRatingsProvider;

  DataState<Map<int, double>, Object> read() => _ref.read(_provider);
  DataState<Map<int, double>, Object> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<Map<int, double>, Object> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  DataFuture<Map<int, double>, Object> get future => DataFuture(
    DataWatchHandle<Map<int, double>, Object>(
      read: () => _ref.read(_provider),
      reload: () => _ref.read(_provider.notifier).reload(),
      listen: (listener) => _ref.listen(_provider, listener),
      invalidateSelf: () => _ref.invalidateSelf(),
    ),
    (forceRefetch) =>
        _ref.read(_provider.notifier).future(forceRefetch: forceRefetch),
  );

  void listen(
    void Function(
      DataState<Map<int, double>, Object>? previous,
      DataState<Map<int, double>, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Map<int, double>, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $GuestRatingsFacadeWidget
    implements
        DataProviderFacade<Map<int, double>, Object>,
        DataProviderValue<Map<int, double>, Object> {
  $GuestRatingsFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _guestRatingsProvider;

  @override
  DataState<Map<int, double>, Object> read() => _ref.read(_provider);
  @override
  DataState<Map<int, double>, Object> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Map<int, double>, Object> state) selector,
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
      DataState<Map<int, double>, Object>? previous,
      DataState<Map<int, double>, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Map<int, double>, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<Map<int, double>, Object> of(WidgetRef ref) =>
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
