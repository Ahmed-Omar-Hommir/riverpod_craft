---
sidebar_position: 2
---

# Fetch Data

When your provider returns a `Future` or `Stream`, riverpod_craft wraps the result in `DataState<T>` — giving you loading, data, and error states automatically.

## Functional Provider

The simplest way to fetch data:

```dart
@provider
Future<List<Note>> notes(Ref ref) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/notes'),
  );
  return (jsonDecode(response.body) as List)
      .map((e) => Note.fromJson(e))
      .toList();
}
```

Use it in a widget with `.watch()` and `.when()`:

```dart
class NotesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.notesProvider.watch();

    return state.when(
      loading: () => const CircularProgressIndicator(),
      data: (notes) => ListView(
        children: notes.map((n) => ListTile(title: Text(n.title))).toList(),
      ),
      error: (error) => Text('Error: $error'),
    );
  }
}
```

## Class-Based Provider

Use a class when you need more control — custom methods, side effects with `@command`, or complex state management:

```dart
@provider
class Notes extends _$Notes {
  @override
  Future<List<Note>> create() async {
    final response = await http.get(
      Uri.parse('https://api.example.com/notes'),
    );
    return (jsonDecode(response.body) as List)
        .map((e) => Note.fromJson(e))
        .toList();
  }
}
```

The generated API is the same — `ref.notesProvider.watch()` works identically for both styles.

## Family Provider

Add parameters to create separate provider instances for different arguments:

```dart
@provider
Future<Note> noteDetail(Ref ref, {required String id}) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/notes/$id'),
  );
  return Note.fromJson(jsonDecode(response.body));
}
```

Each unique `id` creates its own provider with its own loading/data/error state:

```dart
// Two separate providers, each with their own state
final note1 = ref.noteDetailProvider(id: '123').watch();
final note2 = ref.noteDetailProvider(id: '456').watch();
```

### Class-based family

```dart
@provider
class NoteDetail extends _$NoteDetail {
  @override
  Future<Note> create({required String id}) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/notes/$id'),
    );
    return Note.fromJson(jsonDecode(response.body));
  }
}
```

## Reading State

| Method | Use |
|---|---|
| `.watch()` | In `build()` — rebuilds widget on state change |
| `.read()` | In callbacks — reads once, no rebuild |
| `.select(selector).watch()` | Watch only part of the state |

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Watch full state — rebuilds on any change
  final state = ref.notesProvider.watch();

  // Select — only rebuild when note count changes
  final count = ref.notesProvider
      .select((s) => s.dataOrNull?.length ?? 0)
      .watch();

  // Read in a callback — no rebuild
  return ElevatedButton(
    onPressed: () {
      final current = ref.notesProvider.read();
    },
    child: Text('Notes: $count'),
  );
}
```

## Reload & Invalidate

```dart
// Refetch and show loading state
ref.notesProvider.reload();

// Refetch silently (no loading state shown)
ref.notesProvider.silentReload();

// Mark stale — refetches on next access
ref.notesProvider.invalidate();
```

## `@keepAlive`

By default, providers auto-dispose when no one is watching them. Use `@keepAlive` to prevent this:

```dart
@provider
@keepAlive
Future<User> currentUser(Ref ref) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/me'),
  );
  return User.fromJson(jsonDecode(response.body));
}
```

Use `@keepAlive` for data that should persist — like auth state, app config, or data that's expensive to refetch.

## Listen for Changes

Use `.listen()` for one-time reactions like navigation or showing messages:

```dart
ref.notesProvider.listen((prev, next) {
  next.whenOrNull(
    error: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load: $error')),
      );
    },
  );
});
```

## Next

For paginated data (infinite scroll), see:

→ **[Pagination](./pagination)**

For performing side effects (create, update, delete), see:

→ **[Side Effect (Command)](./side-effects)**
