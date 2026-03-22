---
sidebar_position: 3
---

# Command

A command wraps an async function and manages its execution state — `init`, `loading`, `data`, `error` — so your UI can react to the progress of an operation. The idea is inspired by the [Flutter documentation](https://docs.flutter.dev/app-architecture/design-patterns/command).

### Provider vs Command

- **Provider** — triggered automatically. When you `watch()` a provider, it runs immediately and re-runs when dependencies change.
- **Command** — triggered manually. It sits idle until you call `.run()`. Use it when an operation should only happen in response to a user action — submitting a form, deleting an item, or querying data by user input.

## Defining a Command

Add `@command` to any function that returns a `Future`. Commands can be defined in two ways:

### Top-level function

For standalone operations that aren't tied to a specific provider:

```dart
@command
@droppable
Future<void> login(Ref ref, {
  required String email,
  required String password,
}) async {
  await http.post(
    Uri.parse('https://api.example.com/auth/login'),
    body: {'email': email, 'password': password},
  );
}
```

### Method inside a `@provider` class

For operations tied to a data provider — like adding a note to a list:

```dart
@provider
class Notes extends _$Notes {
  @override
  Future<List<Note>> create() async {
    final response = await http.get(Uri.parse('https://api.example.com/notes'));
    return (jsonDecode(response.body) as List)
        .map((e) => Note.fromJson(e))
        .toList();
  }

  @override
  @command
  @droppable
  Future<void> addNote({required String title, required String body}) async {
    final response = await http.post(
      Uri.parse('https://api.example.com/notes'),
      body: jsonEncode({'title': title, 'body': body}),
    );
    // add the new note to the existing list of notes in the state
    final newNote = Note.fromJson(jsonDecode(response.body));
    if (!state.isData) return;
    state = DataState.data([newNote, ...state.data!]);
  }
}
```

### When to use which?

| | Top-level function | Method inside a provider |
|---|---|---|
| **Use when** | The operation is standalone — login, logout, send feedback | The operation is related to the provider's data — add/delete/update a note |
| **Access to state** | No — it's a plain function | Yes — you can read and update `state` directly |
| **How to use** | `ref.loginCommand` | `ref.notesProvider.addNoteCommand` |

## Listening to a Command

Use `.watch()` to listen to the current state of a command. Listening alone does **not** trigger the command — it only subscribes to state changes.

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // We listen to the current state of the "addNote" command.
  // Listening to this will not trigger the command.
  final addNoteState = ref.notesProvider.addNoteCommand.watch();
  final isLoading = addNoteState.isLoading;

  return FilledButton.icon(
    onPressed: isLoading ? null : _submit,
    icon: isLoading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.check),
    label: Text(isLoading ? 'Saving...' : 'Save'),
  );
}
```


## Triggering a Command

Call `.run()` with the same parameters as the original function — fully type-safe with IDE autocomplete:

```dart
// Class-based command
ref.notesProvider.addNoteCommand.run(
  title: 'Meeting Notes',
  body: 'Discuss project timeline',
);

// Top-level command
ref.loginCommand.run(
  email: 'user@example.com',
  password: 'secret',
);
```

## The Different Command States

Commands can be in one of the following states:

- **`init`** — The command has not been called yet, or has been reset.
- **`loading(arg)`** — The command has started and is currently executing.
- **`data(arg, result)`** — The command has succeeded, and the result is available.
- **`error(arg, error)`** — The command has failed, and an error is available.

You can switch over the different states using `.when()`:

```dart
state.when(
  init: () => const Text('Save'),
  loading: (arg) => const CircularProgressIndicator(),
  data: (arg, note) => Text('Created: ${note.title}'),
  error: (arg, error) => Text('Error: $error'),
);
```

The state stays at `data` or `error` until you call `.reset()` or run the command again.

See the [State Types](/docs/reference/state-types) reference for the full `CommandState` and `ArgCommandState` API.

## Reacting to Results

Use `.listen()` for one-time reactions — showing a snackbar, navigating, or dismissing a dialog:

```dart
ref.notesProvider.addNoteCommand.listen((prev, next) {
  next.whenOrNull(
    data: (arg, result) {
      // show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved!')),
      );
      // navigate back to the previous screen
      Navigator.of(context).pop();
    },
    error: (arg, error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $error')),
      );
    },
  );
});
```



## Filtering by Argument

When the same command runs with different arguments — like deleting different notes in a list — you can filter the state to a specific invocation:

```dart
// In a list item widget
final deleteState = ref.notesProvider.deleteNoteCommand.watch();

// Only show spinner for THIS note being deleted
final isDeleting = deleteState
    .whereArg((arg) => arg.id == note.id)
    ?.isLoading ?? false;

return ListTile(
  title: Text(note.title),
  trailing: isDeleting
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            ref.notesProvider.deleteNoteCommand.run(id: note.id);
          },
        ),
);
```

`.whereArg()` returns `null` if the current state doesn't match the filter, so use `?.` to safely chain calls.

## Concurrency Control

What happens when a user taps "Save" twice, or types fast in a search field? Use concurrency annotations to control this. The idea is inspired by [bloc_concurrency](https://pub.dev/packages/bloc_concurrency).

| Annotation | Behavior |
|------------|----------|
| `@droppable` | Ignores new calls while busy |
| `@restartable` | Cancels the current execution, starts the new one |
| `@sequential` | Queues calls, processes one at a time |
| `@concurrent` | Allows multiple simultaneous executions |

### `@droppable` — Ignore duplicate calls

User taps "Submit" twice — the second tap is ignored while the first is still running.

```dart
@command
@droppable
Future<void> saveNote(Ref ref, {required String title, required String body}) async {
  await http.post(
    Uri.parse('https://api.example.com/notes'),
    body: jsonEncode({'title': title, 'body': body}),
  );
}
```

### `@restartable` — Cancel and restart

User types in a search field — each keystroke cancels the previous search and starts a new one.

```dart
@command
@restartable
Future<List<Note>> search(Ref ref, {required String query}) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/notes/search?q=$query'),
  );
  return (jsonDecode(response.body) as List)
      .map((e) => Note.fromJson(e))
      .toList();
}
```


:::info
Most use cases only need `@droppable` — it prevents duplicate executions when a user taps a button multiple times. It is also the default behavior, so if you don't add any concurrency annotation, your command automatically behaves as `@droppable`. Use `@restartable` when you want the latest call to always win, like search-as-you-type.
:::

## Retry and Reset

```dart
// Retry the last failed execution with the same arguments
ref.notesProvider.addNoteCommand.retry();

// Reset back to init state
ref.notesProvider.addNoteCommand.reset();
```

- **`.retry()`** re-executes the last failed call with the same arguments. Useful for "Try again" buttons.
- **`.reset()`** returns the command to `init` state. Use it after a successful operation when you want the command ready for reuse.

### How does a command reset to idle?

The state stays at `data` or `error` until you explicitly call `.reset()` or trigger a new `.run()`. This is intentional — it prevents accidental state loss. You always know when the state will change.

## Family

Mark a parameter with `@family` to create a scoped command — each unique value gets its own independent state. This is useful when you have a list of items and each item has its own action (like a delete button per row).

### Define

```dart
@command
@droppable
Future<void> deleteNote(Ref ref, {@family required String noteId}) async {
  await http.delete(
    Uri.parse('https://api.example.com/notes/$noteId'),
  );
}
```

### Use in widget

Each item in the list gets its own command state — only the item being deleted shows a spinner:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final deleteState = ref.deleteNoteCommand(noteId: note.id).watch();
  final isDeleting = deleteState.isLoading;

  return ListTile(
    title: Text(note.title),
    trailing: isDeleting
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.deleteNoteCommand(noteId: note.id).run();
            },
          ),
  );
}
```

Without `@family`, all items would share the same command state — tapping delete on one note would show a spinner on every note.
