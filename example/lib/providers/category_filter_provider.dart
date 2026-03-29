import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/note.dart';

part 'category_filter_provider.craft.dart';

typedef XXX = List<NoteCategory>;

@provider
@settable
NoteCategory categoryFilter(Ref ref) {
  return NoteCategory.all;
}
