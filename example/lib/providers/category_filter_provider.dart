import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/note.dart';

part 'category_filter_provider.craft.dart';

@provider
@settable
NoteCategory categoryFilter(Ref ref) => NoteCategory.all;
