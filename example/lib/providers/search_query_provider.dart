import 'package:riverpod_craft/riverpod_craft.dart';

part 'search_query_provider.pg.dart';

@provider
@settable
String searchQuery(Ref ref) => '';
