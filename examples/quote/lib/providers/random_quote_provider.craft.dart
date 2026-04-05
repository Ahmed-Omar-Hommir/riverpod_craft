// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'random_quote_provider.dart';

final _randomQuoteProvider = NotifierProvider<$$RandomQuote, DataState<Quote>>(
  () => $$RandomQuote()..arg = (),
  isAutoDispose: true,
);

class $$RandomQuote extends DataNotifier<Quote, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<Quote> buildDataWithFuture() => randomQuote(ref);
}

class $RandomQuoteFacadeRef {
  $RandomQuoteFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _randomQuoteProvider;

  DataState<Quote> read() => _ref.read(_provider);
  DataState<Quote> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(DataState<Quote> state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(DataState<Quote>? previous, DataState<Quote> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Quote>>(_provider, listener, onError: onError);
  }
}

class $RandomQuoteFacadeWidget
    implements DataProviderFacade<Quote>, DataProviderValue<Quote, ()> {
  $RandomQuoteFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _randomQuoteProvider;

  @override
  DataState<Quote> read() => _ref.read(_provider);
  @override
  DataState<Quote> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Quote> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(DataState<Quote>? previous, DataState<Quote> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Quote>>(_provider, listener, onError: onError);
  }

  @override
  DataProviderFacade<Quote> of(WidgetRef ref) => $RandomQuoteFacadeWidget(ref);
}

extension RandomQuoteFacadeRefEx on Ref {
  $RandomQuoteFacadeRef get randomQuoteProvider => $RandomQuoteFacadeRef(this);
}

extension RandomQuoteFacadeWidgetRefEx on WidgetRef {
  $RandomQuoteFacadeWidget get randomQuoteProvider =>
      $RandomQuoteFacadeWidget(this);
}
