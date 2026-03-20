---
sidebar_position: 3
---

# Settable Providers

By default, functional providers are read-only. The `@settable` annotation enables `setState()` so consumers can update the value.

## When to use `@settable`

Use it for simple state that consumers need to change — like filters, toggles, or selected items:

```dart
@provider
@settable
NoteCategory categoryFilter(Ref ref) => NoteCategory.all;
```

This generates `setState()` on both `Ref` and `WidgetRef`:

```dart
// In a widget
ref.categoryFilterProvider.setState(NoteCategory.work);

// In another provider
ref.categoryFilterProvider.setState(NoteCategory.personal);

// Read the current value
final category = ref.categoryFilterProvider.watch();
```

## Another example: search query

```dart
@provider
@settable
String searchQuery(Ref ref) => '';
```

```dart
// In a search bar widget
onChanged: (value) {
  ref.searchQueryProvider.setState(value);
}

// In a filtered list provider
@provider
Future<List<Note>> filteredNotes(Ref ref) async {
  final query = ref.searchQueryProvider.watch();
  final notes = ref.notesProvider.watch();
  // filter notes by query...
}
```

## Rules

- `@settable` only works on **functional** providers (not class-based)
- Class-based sync providers always have state management through their notifier methods — use those instead
- `@settable` is ignored if placed on a class-based provider

## Functional vs class-based for sync state

**Use functional `@settable`** when you just need a simple value that consumers can set:

```dart
@provider
@settable
ThemeMode appTheme(Ref ref) => ThemeMode.system;
```

**Use class-based** when you need custom logic or computed state:

```dart
@provider
class Counter extends _$Counter {
  @override
  int create() => 0;

  void increment() => setState(state + 1);
  void decrement() => setState(state - 1);
  void reset() => setState(0);
}
```
