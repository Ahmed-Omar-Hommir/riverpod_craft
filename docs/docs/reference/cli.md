---
sidebar_position: 3
---

# CLI Reference

## Installation

```bash
dart pub global activate riverpod_craft_cli
```

This installs the `riverpod_craft` command globally.

## Commands

### `watch`

Start watch mode. The recommended way to use the CLI — keep it running while you develop:

```bash
riverpod_craft watch
```

Watches all `*_provider.dart` files in your project. When you save a file, it automatically generates the corresponding `.pg.dart` file.

### `generate`

Generate code for a single file:

```bash
riverpod_craft generate lib/providers/todos_provider.dart
```

### `clean`

Remove all generated `.pg.dart` files:

```bash
riverpod_craft clean
```

### `init`

Initialize a project for riverpod_craft (installs dependencies):

```bash
riverpod_craft init
```

### `help`

Show available commands:

```bash
riverpod_craft help
```

## Generated files

| Source file | Generated file |
|-------------|---------------|
| `my_provider.dart` | `my_provider.pg.dart` |

The generated file is connected via Dart's `part`/`part of` directives. The CLI adds `part 'my_provider.pg.dart';` to your source file automatically if it's not already there.

## What gets generated

For each `@provider`, the CLI generates:

1. **Provider declaration** — the Riverpod provider instance
2. **Notifier class** — extends `DataNotifier`, `StateDataNotifier`, etc.
3. **Ref accessor class** — for use inside other providers (`Ref`)
4. **WidgetRef accessor class** — for use inside widgets (`WidgetRef`)
5. **Extension methods** — adds `.myProvider` getter on `Ref` and `WidgetRef`
6. **Command classes** — one per `@command` method, with `run()`, `watch()`, `listen()`, `retry()`, `reset()`

## File naming convention

:::warning
Provider files **must** end with `_provider.dart`. The generator only watches files matching this pattern.
:::

Examples:
- `todos_provider.dart` ✅
- `auth_provider.dart` ✅
- `user_profile_provider.dart` ✅
- `todos.dart` ❌ (won't be detected)
- `todo_service.dart` ❌ (won't be detected)
