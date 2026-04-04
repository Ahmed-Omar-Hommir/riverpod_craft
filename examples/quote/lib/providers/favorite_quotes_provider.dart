import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/quote.dart';

part 'favorite_quotes_provider.craft.dart';

@provider
@keepAlive
class FavoriteQuotes extends _$FavoriteQuotes {
  @override
  List<Quote> create() => [];

  void addQuote(Quote quote) {
    if (!state.contains(quote)) {
      state = [...state, quote];
    }
  }

  void removeQuote(Quote quote) {
    state = state.where((q) => q.id != quote.id).toList();
  }

  bool isFavorite(String quoteId) {
    return state.any((q) => q.id == quoteId);
  }
}
