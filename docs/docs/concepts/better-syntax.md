---
sidebar_position: 1
---

# Better Syntax

Riverpod Craft generates accessor classes that give you a cleaner API for working with providers. Everything starts from `ref.` and your IDE autocompletes all available providers and their methods.

## Calling notifier methods without `.notifier`

In vanilla Riverpod, calling a method on a notifier requires `ref.read(provider.notifier).method()`. With Riverpod Craft, methods are directly accessible:

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

No `.notifier` chain. No `ref.read(...)` wrapping. Just call the method.

## Watching/reading async state of a side effect

In vanilla Riverpod, there's no built-in way to watch the loading/error/success state of an individual operation like `addTodo`. You can't know if `addTodo` is currently running, or if it failed, without managing that state yourself.

Riverpod Craft solves this with the `@command` annotation. See the [Side Effect Solution](./side-effects) section for the full explanation.

## Updating sync state without `.notifier`

**Before (vanilla Riverpod):**

```dart
ref.read(counterProvider.notifier).state = newValue;
```

**After (riverpod_craft):**

```dart
ref.counterProvider.setState(newValue);
```

:::info
`setState` is only available on functional providers marked with `@settable`. See [Settable Providers](./settable-providers) for details.
:::

## Reloading without `.notifier`

**Before (vanilla Riverpod):**

```dart
ref.read(todosProvider.notifier).reload();
```

**After (riverpod_craft):**

```dart
ref.todosProvider.reload();

// Reload without showing loading state to the UI
ref.todosProvider.silentReload();
```

## Full API overview

Every generated provider gives you these methods on `ref.myProvider`:

| Method | Description |
|--------|-------------|
| `.watch()` | Watch the state (rebuilds on change) |
| `.read()` | Read the current state once |
| `.listen(callback)` | Listen for state changes |
| `.select(selector).watch()` | Watch a selected part of the state |
| `.invalidate()` | Invalidate and refetch |
| `.reload()` | Reload the data |
| `.silentReload()` | Reload without showing loading state |
| `.setState(value)` | Update sync state (requires `@settable`) |

All methods work on both `Ref` (inside providers) and `WidgetRef` (inside widgets).
