---
sidebar_position: 3
---

# CLI Reference

## Installation

Add `craft_runner` as a dev dependency:

```yaml
dev_dependencies:
  craft_runner: ^0.2.0
```

## Commands

### `watch`

Start watch mode. The recommended way to use the CLI — keep it running while you develop:

```bash
dart run craft_runner watch
```

Watches all `*_provider.dart` files in your project. When you save a file, it automatically generates the corresponding `.craft.dart` file.

### `generate`

Generate code for a single file:

```bash
dart run craft_runner generate lib/providers/todos_provider.dart
```

### `clean`

Remove all generated `.craft.dart` files:

```bash
dart run craft_runner clean
```

### `init`

Initialize a project for riverpod_craft (installs dependencies):

```bash
dart run craft_runner init
```

### `help`

Show available commands:

```bash
dart run craft_runner help
```

## Generated files

| Source file | Generated file |
|-------------|---------------|
| `my_provider.dart` | `my_provider.craft.dart` |

The generated file is connected via Dart's `part`/`part of` directives. The CLI adds `part 'my_provider.craft.dart';` to your source file automatically if it's not already there.

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
