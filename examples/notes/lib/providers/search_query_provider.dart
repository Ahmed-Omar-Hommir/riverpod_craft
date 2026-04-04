import 'package:riverpod_craft/riverpod_craft.dart';

part 'search_query_provider.craft.dart';

@provider
@settable
String searchQuery(Ref ref) => '';
