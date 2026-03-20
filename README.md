# riverpod_craft

A code generation toolkit for [Riverpod](https://riverpod.dev) state management in Flutter. Currently in alpha — features and API may change.

Currently available:

- **Better syntax** — access providers via `ref.myProvider.watch()` instead of `ref.watch(myProvider)`
- **Side effect solution** — handle async operations (API calls, mutations) with automatic loading/error/success states and concurrency control

## Documentation

Full documentation available at **[ahmed-omar-hommir.github.io/riverpod_craft](https://ahmed-omar-hommir.github.io/riverpod_craft/)**

## Quick Start

### 1. Install the CLI

```bash
dart pub global activate riverpod_craft_cli
```

### 2. Run the generator

Run this in your project root and keep it running — it watches your files and auto-generates code on save:

```bash
riverpod_craft watch
```

### 3. Add the runtime dependency

```yaml
# pubspec.yaml
dependencies:
  riverpod_craft: ^0.1.0
```

### 4. Write a provider

Create a file ending with `_provider.dart` (e.g. `todos_provider.dart`):

```dart
// lib/providers/todos_provider.dart
import 'package:riverpod_craft/riverpod_craft.dart';
import 'package:http/http.dart' as http;

part 'todos_provider.pg.dart';

@provider
Future<List<Todo>> todos(Ref ref) async {
  final json = await http.get(Uri.parse('https://api.example.com/todos'));
  return [...json.map(Todo.fromJson)];
}
```

> **⚠️ Important:** Provider files must end with `_provider.dart` (e.g. `todos_provider.dart`, `auth_provider.dart`). The generator only watches files matching this pattern.

### 5. Use in widgets

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

## Packages

| Package | Description |
|---------|-------------|
| `riverpod_craft` | Runtime library — annotations, notifiers, state types |
| `riverpod_craft_cli` | CLI tool — parses your code and generates `.pg.dart` files |

## Requirements

- Dart SDK: ^3.8.1
- Flutter: >=3.0.0
- riverpod: ^3.1.0
- flutter_riverpod: ^3.1.0

## License

MIT
