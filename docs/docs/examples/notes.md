---
sidebar_position: 4
---

# Notes

A full CRUD notes app with categories, search, and detail views.

**What you'll learn:**
- Class-based provider with `@command @droppable` methods
- `@settable` for filter and search state
- Parametrized (family) providers
- `reload()` to refresh after mutations

[Source code](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/examples/notes)

---

## Providers

### Notes — CRUD with commands

The main provider fetches the notes list. Each mutation is a `@command @droppable` method that calls the API, then `reload()` to refresh the list:

```dart
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
      title: title, body: body, category: category,
    );
    reload();
    return note;
  }

  @override
  @command
  @droppable
  Future<String> deleteNote({required String id}) async {
    await _repo.deleteNote(id);
    reload();
    return id;
  }

  @override
  @command
  @droppable
  Future<Note> updateNote({required Note note}) async {
    final updated = await _repo.updateNote(note);
    reload();
    return updated;
  }
}
```

`reload()` re-runs `create()` and updates the state — so the list stays in sync after any mutation.

### Category filter — `@settable`

```dart
@provider
@settable
NoteCategory categoryFilter(Ref ref) => NoteCategory.all;
```

### Search query — `@settable`

```dart
@provider
@settable
String searchQuery(Ref ref) => '';
```

### Note detail — family provider

A parametrized provider that fetches a single note by ID:

```dart
@provider
Future<Note> noteDetail(Ref ref, {required String id}) {
  return NotesRepository.instance.getNoteById(id);
}
```

Pass the parameter when accessing:

```dart
ref.noteDetailProvider(id: noteId).watch();
```

### Paginated notes

A paginated provider using `Paged<T>` with commands for inline mutations:

```dart
@provider
class PaginatedNotes extends _$PaginatedNotes {
  @override
  Paged<Note> create(int page, {required String? category}) async {
    // fetch page from API...
  }

  @override
  @command
  @droppable
  Future<void> deleteNote({required String id}) async {
    state = state.removeWhere((note) => note.id == id);
  }
}
```

---

## Usage

### List page

```dart
class NotesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.notesProvider.watch();
    final category = ref.categoryFilterProvider.watch();

    return Scaffold(
      body: notesState.when(
        loading: () => CircularProgressIndicator(),
        data: (notes) {
          final filtered = category == NoteCategory.all
              ? notes
              : notes.where((n) => n.category == category).toList();
          return ListView(
            children: filtered.map((note) => ListTile(
              title: Text(note.title),
              onTap: () => Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => NoteDetailPage(noteId: note.id),
                ),
              ),
            )).toList(),
          );
        },
        error: (e) => FilledButton(
          onPressed: () => ref.notesProvider.reload(),
          child: Text('Retry'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.notesProvider.addNoteCommand.run(
            title: 'New Note',
            body: 'Content here',
            category: NoteCategory.work,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Detail page — family provider

```dart
class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.noteDetailProvider(id: noteId).watch();

    return Scaffold(
      appBar: AppBar(title: Text('Note Detail')),
      body: state.when(
        loading: () => CircularProgressIndicator(),
        data: (note) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.title, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(note.body),
          ],
        ),
        error: (e) => Text('Failed to load note'),
      ),
    );
  }
}
```

### Updating filter

```dart
ref.categoryFilterProvider.setState(NoteCategory.work);
```
