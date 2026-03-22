import 'package:riverpod_craft/riverpod_craft.dart';
import '../models/note.dart';

part 'paginated_notes_provider.pg.dart';

@provider
class PaginatedNotes extends _$PaginatedNotes {
  @override
  Paged<Note> create(int page, {required String? category}) async {
    // Simulated API call
    return PaginatedResponse(
      results: [],
      currentPage: page,
      total: 100,
      lastPage: 5,
    );
  }

  @override
  @command
  @droppable
  Future<void> deleteNote({required String id}) async {
    // Delete from API
    state = state.removeWhere((note) => note.id == id);
  }
}
