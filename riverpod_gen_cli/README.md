# riverpod_gen_cli

Code generation CLI for [riverpod_gen](../riverpod_gen). Parses Dart source files with `@provider`, `@providerValue`, and `@command` annotations and generates type-safe provider boilerplate.

## Installation

The CLI is included in the `riverpod_gen_cli` package. Add it as a dev dependency or run directly:

```yaml
dev_dependencies:
  riverpod_gen_cli:
    path: ../riverpod_gen_cli
```

## Commands

### `watch` (default)

Monitors the `lib/` directory and regenerates `.pg.dart` files on save.

```bash
dart run riverpod_gen_cli
# or explicitly:
dart run riverpod_gen_cli watch
```

On startup, watch mode:
1. Cleans up orphaned `.pg.dart` files (where the source file no longer has annotations)
2. Processes all existing annotated files
3. Watches for file changes

### `generate <file_path>`

Generates the `.pg.dart` file for a single source file.

```bash
dart run riverpod_gen_cli generate lib/providers/my_provider.dart
```

### `clean`

Removes all generated `.pg.dart` files from the project.

```bash
dart run riverpod_gen_cli clean
```

### `init`

Sets up the project — installs Dart dependencies and VS Code extension.

```bash
dart run riverpod_gen_cli init
```

### `help`

Shows available commands.

```bash
dart run riverpod_gen_cli help
```

## Generated Files

- Source: `my_provider.dart`
- Output: `my_provider.pg.dart`
- Connected via `part 'my_provider.pg.dart';` (added automatically to source)

If you remove all annotations from a source file, the CLI automatically deletes the corresponding `.pg.dart` file and removes the `part` directive.

## What Gets Generated

For each annotated provider, the CLI generates:

| Source | Generated |
|--------|-----------|
| `@provider` class with `Future<T> create()` | `DataNotifier` base class, provider declaration, Ref/WidgetRef facades, extensions |
| `@provider` class with `T create()` | `StateDataNotifier` base class, provider declaration, facades with `setState()` |
| `@provider` function | Notifier class, provider declaration, facades, extensions |
| `@providerValue` function | Simple provider declaration, facades with `setState()` |
| `@command` methods | `CommandNotifier` subclass, command facades with `run()`/`reset()`/`retry()` |
| Family parameters | Callable facade classes, `invalidateFamily()` |

## How It Works

1. **Parse** — Uses the Dart `analyzer` package to parse source files into AST
2. **Collect** — Walks the AST to find annotated classes/functions and extract metadata (types, parameters, annotations)
3. **Generate** — Builds provider code from the collected metadata
4. **Write** — Outputs the `.pg.dart` file and ensures the `part` directive exists in the source

## Requirements

- Dart SDK: ^3.8.1
