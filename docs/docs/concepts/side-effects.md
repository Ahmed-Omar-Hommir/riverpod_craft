---
sidebar_position: 2
---

# Side Effect Solution

The hardest part of Riverpod is handling side effects — API calls like creating, updating, or deleting data. You need loading states, error handling, and concurrency control. Riverpod Craft solves this with the `@command` annotation.

## The Problem

In vanilla Riverpod, performing a side effect (like adding a note) requires manually managing a separate loading/error state, or mixing the mutation state into the data provider. There's no built-in pattern that gives you:

- Independent loading state per operation
- Error handling per operation
- Retry capability
- Concurrency control
- Argument tracking (which item is being deleted?)

## The Solution

Mark async methods with `@command`. Each command gets its own independent state (`init` → `loading` → `data`/`error`), completely separate from the main data provider:

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
    reload(); // refresh the notes list
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

Now `addNote` and `deleteNote` each have their own state. Adding a note shows a spinner on the "Add" button, without affecting the notes list display.

## Running a command

```dart
ref.notesProvider.addNoteCommand.run(title: 'Hello', body: 'World');
```

## Watching command state

Each command has its own state — independent from the data provider:

```dart
final addNoteState = ref.notesProvider.addNoteCommand.watch();

addNoteState.when(
  init: () => Text('Add Note'),
  loading: (arg) => CircularProgressIndicator(),
  // use listen() for data/error — the state doesn't auto-reset
);
```

:::tip
The command state does **not** reset automatically after success or error. Use `listen()` for one-time reactions (snackbars, navigation), and `watch()` for UI state (spinners, disabled buttons).
:::

## Listening for results

Use `listen` for one-time reactions like showing a snackbar or navigating:

```dart
ref.notesProvider.addNoteCommand.listen((prev, next) {
  next.whenOrNull(
    data: (_, note) => showSnackbar('Note added!'),
    error: (_, error) => showSnackbar('Error: $error'),
  );
});
```

## Retry and reset

```dart
// Retry the last failed execution with the same arguments
ref.notesProvider.addNoteCommand.retry();

// Reset back to init state
ref.notesProvider.addNoteCommand.reset();
```

## Filtering by argument

When the same command can be called with different arguments (e.g. deleting different notes), you can filter by argument:

```dart
final state = ref.notesProvider.deleteNoteCommand.watch();

// Only react to this specific note being deleted
state.whereArg((arg) => arg.id == noteId)?.whenOrNull(
  loading: (_) => showSpinner(),
  error: (_, error) => showError(error),
);
```

This is useful for showing a spinner on the specific list item being deleted, not on all items.

## Concurrency Control

Control what happens when a command is called while it's already running:

| Annotation | Behavior |
|------------|----------|
| `@droppable` | Ignores new calls while busy |
| `@restartable` | Cancels the current execution, starts the new one |
| `@sequential` | Queues calls, processes one at a time |
| `@concurrent` | Allows multiple simultaneous executions |

### Example: Search with `@restartable`

```dart
@override
@command
@restartable  // Cancel previous search when user types again
Future<List<Result>> search({required String query}) => api.search(query);
```

### Example: Form submit with `@droppable`

```dart
@override
@command
@droppable  // Ignore duplicate taps on the submit button
Future<void> submit({required FormData data}) => api.submit(data);
```

## Command state lifecycle

```
init  →  loading(arg)  →  data(arg, result)
                       →  error(arg, error)
```

- **init**: No execution has happened yet
- **loading(arg)**: Currently executing with these arguments
- **data(arg, result)**: Completed successfully
- **error(arg, error)**: Failed with an error

The state stays at `data` or `error` until you call `.reset()` or run the command again.
