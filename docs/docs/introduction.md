---
sidebar_position: 1
slug: /introduction
---

# Introduction

**Riverpod Craft** is an ecosystem built on top of [Riverpod](https://riverpod.dev) that provides solutions and enhancements for state management in Flutter.

:::caution Alpha
This package is in alpha. Features and API may change.
:::

## What does Riverpod Craft provide?

### Better developer experience

Riverpod is powerful, but the daily workflow can feel repetitive. Riverpod Craft gives you a cleaner API — write your logic, and the generated code provides everything else:

```dart
@provider
Future<List<Note>> notes(Ref ref) async {
  final response = await http.get(Uri.parse('https://api.example.com/notes'));
  return (jsonDecode(response.body) as List).map(Note.fromJson).toList();
}
```

```dart
// Clean, type-safe API — starts from ref, IDE autocompletes the rest
ref.notesProvider.watch()
ref.notesProvider.read()
ref.notesProvider.reload()
ref.notesProvider.invalidate()
```

Everything starts from `ref.` — your IDE autocompletes the rest.

### Side effect solution

Riverpod doesn't have a built-in way to handle side effects (API calls, form submissions, delete operations). You end up manually tracking loading, error, and success states for every operation.

Riverpod Craft introduces **Commands** — each `@command` gets its own independent state with built-in concurrency control:

```dart
@command
@droppable
Future<void> saveNote(Ref ref, {required String title}) async {
  await http.post(Uri.parse('https://api.example.com/notes'), body: ...);
}
```

```dart
// Watch loading/error/success state
final state = ref.saveNoteCommand.watch();

// Run the command
ref.saveNoteCommand.run(title: 'My Note');
```

### Pagination

Built-in support for paginated data with `CraftPagedListView` — handles infinite scrolling, loading states, and page management automatically.

### Fast code generation

`craft_runner` is a fast code generation runner that skips the Dart Analyzer entirely — giving you instant code generation. [Learn why →](./concepts/why-craft-runner)

## Packages

| Package | Description |
|---------|-------------|
| [`riverpod_craft`](https://pub.dev/packages/riverpod_craft) | Runtime library — annotations, notifiers, state types |
| [`craft_runner`](https://pub.dev/packages/craft_runner) | Code generation runner — fast alternative to `build_runner`. [Why?](./concepts/why-craft-runner) |

## Next steps

- **[Getting Started](./getting-started)** — install and write your first provider
- **[State & Provider](./concepts/state-provider)** — manage state with providers
- **[Side Effects](./concepts/side-effects)** — handle async operations with `@command`
