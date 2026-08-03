// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'random_quote_provider.dart';

final _randomQuoteProvider =
    NotifierProvider<$$RandomQuote, DataState<Quote, Object>>(
      () => $$RandomQuote()..arg = (),
      isAutoDispose: true,
    );

class $$RandomQuote extends DataNotifier<Quote, Object, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<Quote> buildDataWithFuture() => randomQuote(ref);
}

class $RandomQuoteFacadeRef {
  $RandomQuoteFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _randomQuoteProvider;

  DataState<Quote, Object> read() => _ref.read(_provider);
  DataState<Quote, Object> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<Quote, Object> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  Future<Quote> future({bool watch = false, bool forceRefetch = false}) {
    if (!watch) {
      return _ref.read(_provider.notifier).future(forceRefetch: forceRefetch);
    }
    return DataWatchHandle<Quote, Object>(
      read: () => _ref.read(_provider),
      reload: () => _ref.read(_provider.notifier).reload(),
      listen: (listener) => _ref.listen(_provider, listener),
      invalidateSelf: () => _ref.invalidateSelf(),
    ).future(forceRefetch: forceRefetch);
  }

  void listen(
    void Function(
      DataState<Quote, Object>? previous,
      DataState<Quote, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Quote, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $RandomQuoteFacadeWidget
    implements
        DataProviderFacade<Quote, Object>,
        DataProviderValue<Quote, Object> {
  $RandomQuoteFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _randomQuoteProvider;

  @override
  DataState<Quote, Object> read() => _ref.read(_provider);
  @override
  DataState<Quote, Object> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Quote, Object> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();
  Future<Quote> future({bool forceRefetch = false}) =>
      _ref.read(_provider.notifier).future(forceRefetch: forceRefetch);

  @override
  void listen(
    void Function(
      DataState<Quote, Object>? previous,
      DataState<Quote, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Quote, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<Quote, Object> of(WidgetRef ref) =>
      $RandomQuoteFacadeWidget(ref);
}

extension RandomQuoteFacadeRefEx on Ref {
  $RandomQuoteFacadeRef get randomQuoteProvider => $RandomQuoteFacadeRef(this);
}

extension RandomQuoteFacadeWidgetRefEx on WidgetRef {
  $RandomQuoteFacadeWidget get randomQuoteProvider =>
      $RandomQuoteFacadeWidget(this);
}
