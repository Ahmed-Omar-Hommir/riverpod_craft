---
sidebar_position: 2
---

# Side Effect (Command)

Performing side effects — login, submit, delete — usually means managing loading state, error handling, and concurrency yourself. With riverpod_craft, you just write your async function and annotate it with `@command`. The rest is generated for you.

## Top-level command

For standalone operations like login or logout.

### Write

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

### Use in widget

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final loginState = ref.loginCommand.watch();
  final isLoading = loginState.isLoading;

  return FilledButton(
    onPressed: isLoading ? null : () {
      ref.loginCommand.run(
        email: emailController.text,
        password: passwordController.text,
      );
    },
    child: isLoading
        ? const CircularProgressIndicator(strokeWidth: 2)
        : const Text('Login'),
  );
}
```

## Command inside a provider

For operations tied to a data provider — like adding a note to a list.

### Write

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

### Use in widget

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final addNoteState = ref.notesProvider.addNoteCommand.watch();
  final isLoading = addNoteState.isLoading;

  return FilledButton(
    onPressed: isLoading ? null : () {
      ref.notesProvider.addNoteCommand.run(
        title: titleController.text,
        body: bodyController.text,
      );
    },
    child: isLoading
        ? const CircularProgressIndicator(strokeWidth: 2)
        : const Text('Save'),
  );
}
```

## Next

Learn the full Command API — states, listening, concurrency control, and more:

**[Command →](/docs/concepts/command)**
