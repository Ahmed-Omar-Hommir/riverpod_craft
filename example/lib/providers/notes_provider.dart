import 'package:riverpod_craft/riverpod_craft.dart';

import '../data/notes_repository.dart';
import '../models/note.dart';

part 'notes_provider.pg.dart';

@provider
class Notes extends _$Notes {
  final _repo = NotesRepository.instance;

  @override
  Future<List<Note>> create() => _repo.getNotes();

  @override
  @command
  @droppable
  Future<Note> addNote({
    required String title,
    required String body,
    required NoteCategory category,
  }) async {
    final note = await _repo.addNote(
      title: title,
      body: body,
      category: category,
    );
    // Reload the notes list after adding
    reload();
    return note;
  }

  @override
  @command
  @droppable
  Future<String> deleteNote({required String id}) async {
    await _repo.deleteNote(id);
    // Reload the notes list after deleting
    reload();
    return id;
  }

  @override
  @command
  @droppable
  Future<Note> updateNote({required Note note}) async {
    final updated = await _repo.updateNote(note);
    // Reload the notes list after updating
    reload();
    return updated;
  }
}
