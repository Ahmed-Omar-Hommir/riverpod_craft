---
sidebar_position: 1
slug: /introduction
---

# Introduction

**Riverpod Craft** is a code generation toolkit for [Riverpod](https://riverpod.dev) state management in Flutter.

:::caution Alpha
This package is in alpha. Features and API may change.
:::

## What does it do?

Currently available:

- **Better syntax** — access providers via `ref.myProvider.watch()` instead of `ref.watch(myProvider)`
- **Side effect solution** — handle async operations (API calls, mutations) with automatic loading/error/success states and concurrency control

## Packages

| Package | Description |
|---------|-------------|
| [`riverpod_craft`](https://pub.dev/packages/riverpod_craft) | Runtime library — annotations, notifiers, state types |
| [`riverpod_craft_cli`](https://pub.dev/packages/riverpod_craft_cli) | CLI tool — parses your code and generates `.pg.dart` files |

## How it works

1. You write annotated Dart classes/functions
2. The CLI watches your files and generates `.pg.dart` files
3. The generated code gives you a clean, type-safe API to use in your widgets

```dart
// You write this:
@provider
Future<List<Todo>> todos(Ref ref) async {
  final response = await http.get(Uri.parse('https://api.example.com/todos'));
  return [...json.map(Todo.fromJson)];
}

// You get this API:
ref.todosProvider.watch()    // watch the state
ref.todosProvider.read()     // read once
ref.todosProvider.reload()   // refresh
ref.todosProvider.invalidate()
```

No manual provider declarations. No `.notifier` chains. Everything starts from `ref.` and your IDE autocompletes the rest.

## Next steps

- [Getting Started](./getting-started) — install and set up your first provider
- [Better Syntax](./concepts/better-syntax) — see all the syntax improvements
- [Side Effects](./concepts/side-effects) — learn how `@command` handles async operations
