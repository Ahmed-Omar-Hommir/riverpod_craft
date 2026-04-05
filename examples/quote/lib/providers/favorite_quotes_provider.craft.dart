// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'favorite_quotes_provider.dart';

abstract class _$FavoriteQuotes extends StateDataNotifier<List<Quote>, ()> {
  List<Quote> create();
  @override
  List<Quote> buildData(() arg) => create();
}

final _favoriteQuotesProvider = NotifierProvider<FavoriteQuotes, List<Quote>>(
  () => FavoriteQuotes()..arg = (),
);

class $FavoriteQuotesFacadeRef {
  $FavoriteQuotesFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _favoriteQuotesProvider;

  List<Quote> read() => _ref.read(_provider);
  List<Quote> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(List<Quote> state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(List<Quote>? previous, List<Quote> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<List<Quote>>(_provider, listener, onError: onError);
  }

  void addQuote(Quote quote) => _ref.read(_provider.notifier).addQuote(quote);

  void removeQuote(Quote quote) =>
      _ref.read(_provider.notifier).removeQuote(quote);

  bool isFavorite(String quoteId) =>
      _ref.read(_provider.notifier).isFavorite(quoteId);
}

class $FavoriteQuotesFacadeWidget {
  $FavoriteQuotesFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _favoriteQuotesProvider;

  List<Quote> read() => _ref.read(_provider);
  List<Quote> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(List<Quote> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));

  void listen(
    void Function(List<Quote>? previous, List<Quote> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<List<Quote>>(_provider, listener, onError: onError);
  }

  void addQuote(Quote quote) => _ref.read(_provider.notifier).addQuote(quote);

  void removeQuote(Quote quote) =>
      _ref.read(_provider.notifier).removeQuote(quote);

  bool isFavorite(String quoteId) =>
      _ref.read(_provider.notifier).isFavorite(quoteId);
}

extension FavoriteQuotesFacadeRefEx on Ref {
  $FavoriteQuotesFacadeRef get favoriteQuotesProvider =>
      $FavoriteQuotesFacadeRef(this);
}

extension FavoriteQuotesFacadeWidgetRefEx on WidgetRef {
  $FavoriteQuotesFacadeWidget get favoriteQuotesProvider =>
      $FavoriteQuotesFacadeWidget(this);
}
