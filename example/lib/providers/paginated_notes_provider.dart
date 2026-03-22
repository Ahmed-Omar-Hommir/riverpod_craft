import 'package:riverpod_craft/riverpod_craft.dart';
import '../models/note.dart';
import '../models/api_paged_response.dart';
import '../paged_mapper.dart';

part 'paginated_notes_provider.pg.dart';

@provider
class PaginatedNotes extends _$PaginatedNotes {
  @override
  Paged<Note> create(int page, {required String? category}) async {
    throw Exception();
  }

  @override
  @command
  @droppable
  Future<void> deleteNote({required String id}) async {
    // Delete from API
    state = state.removeWhere((note) => note.id == id);
  }
}
