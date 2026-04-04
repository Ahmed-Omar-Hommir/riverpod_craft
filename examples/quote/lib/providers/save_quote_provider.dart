import 'package:riverpod_craft/riverpod_craft.dart';

import '../data/quotes_data.dart';

part 'save_quote_provider.craft.dart';

@command
@droppable
Future<String> saveQuote(Ref ref, {required String quoteId}) async {
  await saveQuoteToStorage(quoteId);
  return quoteId;
}
