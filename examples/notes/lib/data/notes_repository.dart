import '../models/note.dart';

class NotesRepository {
  NotesRepository._();
  static final instance = NotesRepository._();

  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Welcome to Notes',
      body:
          'This is a sample note to get you started. Try creating, editing, and deleting notes!',
      category: NoteCategory.personal,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Note(
      id: '2',
      title: 'Sprint Planning',
      body:
          'Review backlog items, estimate story points, and assign tasks for the next two-week sprint.',
      category: NoteCategory.work,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Note(
      id: '3',
      title: 'App Idea: Habit Tracker',
      body:
          'Build a minimal habit tracker with streaks, daily reminders, and weekly stats. Use local storage for offline support.',
      category: NoteCategory.ideas,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Note(
      id: '4',
      title: 'Grocery List',
      body: 'Milk, eggs, bread, avocados, coffee beans, dark chocolate.',
      category: NoteCategory.personal,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Note(
      id: '5',
      title: 'Code Review Checklist',
      body:
          '1. Check for null safety\n2. Verify error handling\n3. Review naming conventions\n4. Ensure test coverage\n5. Check performance implications',
      category: NoteCategory.work,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  int _nextId = 6;

  Future<List<Note>> getNotes() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.unmodifiable(_notes.reversed);
  }

  Future<Note> getNoteById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _notes.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('Note not found'),
    );
  }

  Future<Note> addNote({
    required String title,
    required String body,
    required NoteCategory category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    final note = Note(
      id: '${_nextId++}',
      title: title,
      body: body,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(note);
    return note;
  }

  Future<void> deleteNote(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _notes.removeWhere((n) => n.id == id);
  }

  Future<Note> updateNote(Note note) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) throw Exception('Note not found');
    final updated = note.copyWith(updatedAt: DateTime.now());
    _notes[index] = updated;
    return updated;
  }
}
