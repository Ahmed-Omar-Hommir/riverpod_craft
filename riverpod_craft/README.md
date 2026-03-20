# riverpod_craft

A code generation toolkit for [Riverpod](https://riverpod.dev) state management in Flutter. Currently in alpha — features and API may change.

Currently available:

- **Better syntax** — access providers via `ref.myProvider.watch()` instead of `ref.watch(myProvider)`
- **Side effect solution** — handle async operations (API calls, mutations) with automatic loading/error/success states and concurrency control

## Packages

| Package | Description |
|---------|-------------|
| `riverpod_craft` | Runtime library — annotations, notifiers, state types |
| `riverpod_craft_cli` | CLI tool — parses your code and generates `.pg.dart` files |

## Quick Start

### 1. Add dependencies

```yaml
# pubspec.yaml
dependencies:
  riverpod_craft:
    path: ../riverpod_craft  # or published package
  flutter_riverpod: ^3.1.0
```

### 2. Write a provider

```dart
import 'package:riverpod_craft/riverpod_craft.dart';

part 'user_provider.pg.dart';

@provider
class User extends _$User {
  @override
  Future<UserData> create() => fetchUser();
}
```

### 3. Generate code

```bash
# Watch mode (auto-generates on save)
dart run riverpod_craft_cli watch

# Or generate a single file
dart run riverpod_craft_cli generate lib/providers/user_provider.dart
```

### 4. Use in widgets

```dart
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.userProvider.watch();

    return state.when(
      loading: () => CircularProgressIndicator(),
      data: (user) => Text(user.name),
      error: (error) => Text('Error: $error'),
    );
  }
}
```

---

## Better Syntax

### Calling notifier methods without `.notifier`

In vanilla Riverpod, calling a method on a notifier requires `ref.read(provider.notifier).method()`. With `riverpod_craft`, methods are directly accessible:

**Before (vanilla Riverpod):**

```dart
ref.read(todosProvider.notifier).addTodo(newTodo);
ref.read(todosProvider.notifier).removeTodo(id);
```

**After (riverpod_craft):**

```dart
ref.todosProvider.addTodo(todo: newTodo);
ref.todosProvider.removeTodo(id: id);
```

### Watching/reading async state of a side effect

In vanilla Riverpod, there's no built-in way to watch the loading/error/success state of an individual operation like `addTodo`. The `mutation` API exists but is verbose and limited. See the [Side Effect Solution](#side-effect-solution) section for how `riverpod_craft` solves this.

### Updating sync state without `.notifier`

**Before (vanilla Riverpod):**

```dart
ref.read(counterProvider.notifier).state = newValue;
```

**After (riverpod_craft):**

```dart
ref.counterProvider.setState(newValue);
```

### Reloading without `.notifier`

**Before (vanilla Riverpod):**

```dart
ref.read(todosProvider.notifier).reload();
```

**After (riverpod_craft):**

```dart
ref.todosProvider.reload();
ref.todosProvider.silentReload(); // reload without showing loading state
```

Everything starts from `ref.` — your IDE autocompletes all available providers and their methods.

---

## Side Effect Solution

The hardest part of Riverpod is handling side effects — API calls like creating, updating, or deleting data. You need loading states, error handling, and concurrency control. `riverpod_craft` solves this with the `@command` annotation.

### The Problem

In vanilla Riverpod, performing a side effect (like adding a note) requires manually managing a separate loading/error state, or mixing the mutation state into the data provider. There's no built-in pattern for this.

### The Solution

Mark async methods with `@command`. Each command gets its own independent state (init → loading → data/error), separate from the main data provider:

```dart
@provider
class Notes extends _$Notes {
  @override
  Future<List<Note>> create() => repo.getNotes();

  @override
  @command
  @droppable
  Future<Note> addNote({required String title, required String body}) async {
    final note = await repo.addNote(title: title, body: body);
    reload(); // refresh the notes list after adding
    return note;
  }

  @override
  @command
  @droppable
  Future<String> deleteNote({required String id}) async {
    await repo.deleteNote(id);
    reload();
    return id;
  }
}
```

### Running a side effect

```dart
// Execute the side effect
ref.notesProvider.addNoteCommand.run(title: 'Hello', body: 'World');
```

### Watching side effect state

Each command has its own state — independent from the data provider. You can show a spinner on the "Add" button while the command runs, without affecting the notes list:

```dart
final addNoteState = ref.notesProvider.addNoteCommand.watch();

addNoteState.when(
  init: () => Text('Add Note'),
  loading: (arg) => CircularProgressIndicator(),
  // use listen for data/error — the state stays until you call reset()
);
```

### Retry and reset

```dart
// Retry last failed execution
ref.notesProvider.addNoteCommand.retry();

// Reset back to init state
ref.notesProvider.addNoteCommand.reset();
```

### Listen for side effect results (snackbars, navigation)

```dart
ref.notesProvider.addNoteCommand.listen((prev, next) {
  next.whenOrNull(
    data: (_, note) => showSnackbar('Note added!'),
    error: (_, error) => showSnackbar('Error: $error'),
  );
});
```

### Filter by argument

When the same command can be called with different arguments (e.g. deleting different notes), filter by argument:

```dart
final state = ref.notesProvider.deleteNoteCommand.watch();

// Only react to this specific note being deleted
state.whereArg((arg) => arg.id == noteId)?.whenOrNull(
  loading: (_) => showSpinner(),
  error: (_, error) => showError(error),
);
```

### Concurrency Control

Control what happens when a command is called while already running:

| Annotation | Behavior |
|------------|----------|
| `@droppable` | Ignores new calls while busy |
| `@restartable` | Cancels the current execution, starts the new one |
| `@sequential` | Queues calls, processes one at a time |
| `@concurrent` | Allows multiple simultaneous executions |

```dart
@override
@command
@restartable  // Cancel previous search when user types again
Future<List<Result>> search({required String query}) => api.search(query);
```

---

## Annotations

### `@provider`

Marks a class or function as a Riverpod provider. The generator creates the notifier, provider declaration, and accessor classes.

**Class-based (async):**

```dart
part 'todos_provider.pg.dart';

@provider
class Todos extends _$Todos {
  @override
  Future<List<Todo>> create() => api.fetchTodos();
}
```

**Class-based (sync):**

```dart
part 'counter_provider.pg.dart';

@provider
class Counter extends _$Counter {
  @override
  int create() => 0;
}
```

**Function-based (async):**

```dart
part 'user_provider.pg.dart';

@provider
Future<User> user(Ref ref) => api.getUser();
```

**Stream:**

```dart
part 'messages_provider.pg.dart';

@provider
Stream<List<Message>> messages(Ref ref) => api.messagesStream();
```

The `create()` return type determines the provider type:
- `T` → sync provider (uses `StateDataNotifier`)
- `Future<T>` → async provider (uses `DataNotifier`)
- `Stream<T>` → stream provider (uses `DataNotifier`)

### `@providerValue`

For simple functional value providers. Explicitly marks synchronous value providers.

```dart
part 'theme_mode_provider.pg.dart';

@providerValue
ThemeMode currentTheme(Ref ref) => ThemeMode.light;
```

### `@keepAlive`

Prevents the provider from being auto-disposed when no longer listened to.

```dart
@provider
@keepAlive
class Auth extends _$Auth {
  @override
  Future<AuthState> create() => checkAuth();
}
```

### `@family`

Creates parameterized providers. Parameters in `create()` or function parameters become the family key.

**Function-based:**

```dart
part 'note_detail_provider.pg.dart';

@provider
Future<Note> noteDetail(Ref ref, {required String id}) {
  return repo.getNoteById(id);
}

// Usage:
ref.noteDetailProvider(id: '123').watch()
```

**Class-based:**

```dart
part 'user_profile_provider.pg.dart';

@provider
class UserProfile extends _$UserProfile {
  @override
  Future<Profile> create({required String userId}) {
    return api.getProfile(userId);
  }
}

// Usage:
ref.userProfileProvider(userId: 'abc').watch()
```

---

## State Types

### `DataState<T>`

Represents async data provider state:

```dart
sealed class DataState<T> {
  factory DataState.loading();
  factory DataState.data(T data);
  factory DataState.error(Object error);
}
```

**Pattern matching:**

```dart
state.when(
  loading: () => CircularProgressIndicator(),
  data: (todos) => TodoList(todos),
  error: (error) => ErrorWidget(error),
);

// Partial matching
state.maybeWhen(
  data: (todos) => TodoList(todos),
  orElse: () => CircularProgressIndicator(),
);

// Nullable matching
state.whenOrNull(
  error: (error) => showErrorSnackbar(error),
);
```

**Properties:**

```dart
state.isLoading   // bool
state.isData      // bool
state.isError     // bool
state.dataOrNull  // T?
state.errorOrNull // Object?
```

### `ArgCommandState<T, ArgT>`

Represents side effect state with argument tracking:

```dart
sealed class ArgCommandState<T, ArgT> {
  factory ArgCommandState.init();
  factory ArgCommandState.loading(ArgT arg);
  factory ArgCommandState.data(ArgT arg, T data);
  factory ArgCommandState.error(ArgT arg, Object error);
}
```

**Properties:**

```dart
state.isInit    // bool
state.isLoading // bool
state.isData    // bool
state.isError   // bool
state.isDone    // true if data or error
state.arg       // ArgT?
state.data      // T?
state.error     // Object?
```

### `Result<T>`

A simple `Ok`/`Error` union for synchronous error handling:

```dart
final result = Result.ok(42);
result.valueOrNull;  // 42
result.isOk;         // true

final err = Result.error('something went wrong');
err.errorOrNull;     // 'something went wrong'
err.isError;         // true
```

---

## CLI Usage

```bash
# Start watch mode (default) — auto-generates on file save
dart run riverpod_craft_cli

# Generate a single file
dart run riverpod_craft_cli generate lib/providers/my_provider.dart

# Remove all generated .pg.dart files
dart run riverpod_craft_cli clean

# Initialize project (install dependencies)
dart run riverpod_craft_cli init

# Show help
dart run riverpod_craft_cli help
```

### Generated File Convention

- Source: `my_provider.dart`
- Generated: `my_provider.pg.dart`
- Connected via Dart's `part`/`part of` directives (added automatically)

---

## Full Example

A complete Notes app showing both features — better syntax and side effect handling.

### Model

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

### Data Provider with Side Effects

```dart
import 'package:riverpod_craft/riverpod_craft.dart';

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

### Sync State Provider

```dart
import 'package:riverpod_craft/riverpod_craft.dart';

part 'category_filter_provider.pg.dart';

@provider
class CategoryFilter extends _$CategoryFilter {
  @override
  NoteCategory create() => NoteCategory.all;
}
```

### Family Provider

```dart
import 'package:riverpod_craft/riverpod_craft.dart';

part 'note_detail_provider.pg.dart';

@provider
Future<Note> noteDetail(Ref ref, {required String id}) {
  return NotesRepository.instance.getNoteById(id);
}
```

### Widget — List Page

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

### Widget — Detail Page (Family Provider)

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

---

## Requirements

- Dart SDK: ^3.8.1
- Flutter: >=3.0.0
- riverpod: ^3.1.0
- flutter_riverpod: ^3.1.0

## License

MIT
