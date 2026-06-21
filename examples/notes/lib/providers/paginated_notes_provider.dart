import 'package:riverpod_craft/riverpod_craft.dart';
import '../models/note.dart';
import '../models/api_paged_response.dart';
import '../models/app_error.dart';

part 'paginated_notes_provider.craft.dart';

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
