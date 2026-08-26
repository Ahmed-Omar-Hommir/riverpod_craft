# craft_runner

A fast, plugin-driven code-generation runner for Dart projects.

craft_runner parses your source once with the `analyzer`, keeps the parse in
memory, and drives a set of builders you declare. It knows nothing about any
particular generator — the riverpod provider/command generation, the retrofit
aggregator and your own builders are all just plugins
(`riverpod_craft_plugin`, `retrofit_craft_plugin`, …).

Parsing is **syntactic only** (`parseString`), never resolved. That is the whole
trick: it makes a full pass over a few hundred files take milliseconds instead of
seconds, at the cost of builders seeing syntax rather than types.

## Install

```bash
dart pub global activate craft_runner
```

Also add it to the project, since the generated builder entry is compiled
against your package config:

```yaml
dev_dependencies:
  craft_runner: ^0.11.0
```

Put it under `dependencies:` instead if your own builders live in `lib/`.

## Configure — `craft_runner.yaml`

Drop this in your project root. Each key under `builders:` is
`<package_name>:<ClassName>`; the package must be a `(dev_)dependency` and the
class must expose a `fromConfig(Map<String, Object?>)` factory. Everything
nested under a builder key is passed to that factory.

```yaml
roots: [lib, test]
exclude: ['.craft.dart', '.g.dart', '.freezed.dart']

builders:
  riverpod_craft_plugin:RiverpodCraftBuilder:
    error_mapper: lib/error_mapper.dart
    paged_provider_mapper: lib/paged_mapper.dart

  retrofit_craft_plugin:RetrofitCraftBuilder:
    entry_path: lib/app/api/entries.dart
    output: lib/app/api/app_api.craft.dart
    root_class_name: AppApi
```

`roots` defaults to `[lib, test]` and `exclude` to
`['.craft.dart', '.g.dart', '.freezed.dart']`. A builder with no options takes
an empty block.

## Commands

```bash
craft_runner build        # build once and exit
craft_runner watch        # build, then rebuild on every save
craft_runner --version
craft_runner --help
```

## Writing a builder

A builder declares which source roots it cares about and gets handed parsed
files. Use `writeIfChanged` to emit output — it skips byte-identical writes, so
your own output never wakes the watcher.

Per file:

```dart
class MyBuilder extends CraftBuilderSingleFile {
  factory MyBuilder.fromConfig(Map<String, Object?> config) => MyBuilder();

  @override
  List<String> get scope => ['lib'];

  @override
  void build(String path, ParseStringResult result) {
    if (!path.endsWith('_thing.dart')) return;
    writeIfChanged(path.replaceFirst('.dart', '.craft.dart'), '...');
  }
}
```

Across the whole project — for generators that aggregate, like a barrel or a
single API client:

```dart
class MyBarrelBuilder extends CraftBuilderMultiFile {
  factory MyBarrelBuilder.fromConfig(Map<String, Object?> config) =>
      MyBarrelBuilder();

  @override
  List<String> get scope => ['lib'];

  @override
  void build(Map<String, ParseStringResult> results) {
    writeIfChanged('lib/barrel.craft.dart', '...');
  }
}
```

`path` is passed alongside the result because `ParseStringResult` does not carry
the path it was parsed from.

In watch mode a single-file builder is re-run only for files that changed; a
multi-file builder is re-run once per batch if any file in its scope changed.

## How it works

1. **Read** `craft_runner.yaml`.
2. **Bootstrap** — generate `.dart_tool/craft_runner/entry.dart` importing each
   builder package, AOT-compile it, and run it. The binary is cached and reused
   until the config or any builder package changes, so this cost is paid once.
3. **Parse** every file under `roots` with the `analyzer`.
4. **Build** — hand each parsed file to the builders whose `scope` covers it.
5. **Write** — `writeIfChanged` for each output.

Watch mode then re-parses only what changed and re-runs only the affected
builders. One watcher per project is enforced with a file lock; a second `watch`
exits rather than double-building every change.

## Limitations

- **No type resolution.** Builders match on syntax. A typedef, an inherited
  member, or a type from another file cannot be resolved.
- **Stale output is not cleaned.** Deleting or renaming a source file leaves its
  previously generated file behind; remove it yourself.
- **Config is read once at startup.** Editing a file that a builder reads
  through its config (an error mapper, say) needs a restart.

## Requirements

- Dart SDK `^3.5.0`
