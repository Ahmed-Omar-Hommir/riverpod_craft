import 'package:riverpod_craft/riverpod_craft.dart';

import '../data/quotes_data.dart';
import '../models/quote.dart';

part 'random_quote_provider.craft.dart';

@provider
Future<Quote> randomQuote(Ref ref) => getRandomQuote();
