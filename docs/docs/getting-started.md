---
sidebar_position: 2
---

# Getting Started

## 1. Install the CLI

```bash
dart pub global activate riverpod_craft_cli
```

This gives you the `riverpod_craft` command globally.

## 2. Run the generator

In your project root, start the watcher. Keep it running — it auto-generates code when you save files:

```bash
riverpod_craft watch
```

## 3. Add the runtime dependency

```yaml
# pubspec.yaml
dependencies:
  riverpod_craft: ^0.1.0
  flutter_riverpod: ^3.1.0
```

## 4. Write a provider

Create a file ending with `_provider.dart` (e.g. `todos_provider.dart`):

```dart
// lib/providers/todos_provider.dart
import 'package:riverpod_craft/riverpod_craft.dart';
import 'package:http/http.dart' as http;

part 'todos_provider.pg.dart';

@provider
Future<List<Todo>> todos(Ref ref) async {
  final response = await http.get(Uri.parse('https://api.example.com/todos'));
  return [...jsonDecode(response.body).map(Todo.fromJson)];
}
```

:::warning File naming
Provider files **must** end with `_provider.dart` (e.g. `todos_provider.dart`, `auth_provider.dart`). The generator only watches files matching this pattern.
:::

When you save this file, the CLI automatically generates `todos_provider.pg.dart` with all the boilerplate.

## 5. Use in widgets

```dart
class TodosPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.todosProvider.watch();

    return state.when(
      loading: () => CircularProgressIndicator(),
      data: (todos) => ListView(
        children: todos.map((t) => Text(t.title)).toList(),
      ),
      error: (error) => Text('Error: $error'),
    );
  }
}
```

That's it. The generated code gives you `ref.todosProvider` with `.watch()`, `.read()`, `.reload()`, `.invalidate()`, and more — all with full type safety and IDE autocomplete.

## What's next?

Now that you have the basics, learn about the two main features:

- **[Better Syntax](./concepts/better-syntax)** — all the ways the generated API improves on vanilla Riverpod
- **[Side Effects](./concepts/side-effects)** — how to handle mutations, API calls, and async operations with `@command`
