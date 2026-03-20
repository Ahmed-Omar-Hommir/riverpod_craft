---
sidebar_position: 6
---

# Example App

A complete Notes app demonstrating both features — better syntax and side effect handling. The full source is in the [`example/`](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/example) directory.

## Model

```dart
enum NoteCategory { all, work, personal, ideas }

class Note {
  final String id;
  final String title;
  final String body;
  final NoteCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

## Data Provider with Side Effects

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
}
```

## Settable Filter Provider

```dart
@provider
@settable
NoteCategory categoryFilter(Ref ref) => NoteCategory.all;
```

## Family Provider

```dart
@provider
Future<Note> noteDetail(Ref ref, {required String id}) {
  return NotesRepository.instance.getNoteById(id);
}
```

## Widget — List Page

```dart
class NotesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.notesProvider.watch();
    final category = ref.categoryFilterProvider.watch();

    return Scaffold(
      body: notesState.when(
        loading: () => Center(child: CircularProgressIndicator()),
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
        error: (e) => Center(
          child: FilledButton(
            onPressed: () => ref.notesProvider.reload(),
            child: Text('Retry'),
          ),
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

## Widget — Detail Page (Family Provider)

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
        loading: () => Center(child: CircularProgressIndicator()),
        data: (note) => Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.title, style: TextStyle(fontSize: 24)),
              SizedBox(height: 8),
              Text(note.body),
            ],
          ),
        ),
        error: (e) => Center(child: Text('Failed to load note')),
      ),
    );
  }
}
```
