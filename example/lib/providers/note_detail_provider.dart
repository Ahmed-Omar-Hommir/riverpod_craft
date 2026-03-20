import 'package:riverpod_craft/riverpod_craft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notes_repository.dart';
import '../models/note.dart';

part 'note_detail_provider.pg.dart';

@provider
Future<Note> noteDetail(Ref ref, {required String id}) {
  return NotesRepository.instance.getNoteById(id);
}
