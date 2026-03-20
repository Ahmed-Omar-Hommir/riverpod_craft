import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/note.dart';

part 'category_filter_provider.pg.dart';

@provider
class CategoryFilter extends _$CategoryFilter {
  @override
  NoteCategory create() => NoteCategory.all;
}
