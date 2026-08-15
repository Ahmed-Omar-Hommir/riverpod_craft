# craft_runner

A generic, plugin-driven code-generation runner for Dart projects. craft_runner
knows nothing about any specific generator — it parses your source with the
`analyzer`, drives a set of plugins you declare, and writes their output. The
riverpod provider/command generation, the retrofit aggregator, and any other
generator are all just plugins (`riverpod_craft_plugin`, `retrofit_craft_plugin`,
…).

## Installation

Add it as a dev dependency:

```yaml
dev_dependencies:
  craft_runner: ^0.8.0
```

## Configuration — `craft_runner.yaml`

Declare the plugins to run, plus any per-plugin config blocks. Each plugin entry
is `<package_name>:<ClassName>`; the package must be a `(dev_)dependency` and the
class a no-arg-constructable `ProjectWideCraftPlugin`.

```yaml
plugins:
  - riverpod_craft_plugin:RiverpodGeneratorPlugin
  - retrofit_craft_plugin:RetrofitApiPlugin

# Each plugin reads its own namespaced block:
riverpod_craft:
  error_mapper: lib/error_mapper.dart
  paged_provider_mapper: lib/paged_mapper.dart

retrofit_craft:
  entry_path: lib/app/api/entries.dart
  output: lib/app/api/app_api.craft.dart
```

## Commands

```bash
dart run craft_runner            # watch mode (default)
dart run craft_runner watch      # watch lib/ and test/, regenerate on save
dart run craft_runner generate <file>   # run a single pass now
dart run craft_runner clean      # remove all generated .craft.dart files
dart run craft_runner help       # show help
```

Watch startup is incremental: it skips the whole build when nothing that affects
output has changed since the last run (tracked in a manifest keyed on the plugin
graph + source mtimes), and only re-parses files that changed.

## The plugin interface — `ProjectWideCraftPlugin`

A plugin observes parsed source units and returns `{outputPath: content}`:

```dart
abstract class ProjectWideCraftPlugin {
  String get id;
  List<String> get sourceRoots;               // e.g. ['lib'] or ['test']
  void reset();
  void collectFromUnit(ParseStringResult unit, String filePath);
  Map<String, String> generate();             // {path: contents}
}
```

craft_runner walks the union of the plugins' `sourceRoots`, feeds each parsed
unit to the plugins that requested its root, then writes each returned entry
(prepending a `GENERATED CODE` header unless the content already has one, and
running `dart_style`).

## How it works

1. **Load** — read `craft_runner.yaml`'s `plugins:` list.
2. **Hand off** — generate `.dart_tool/craft_runner/entry.dart` that imports and
   instantiates each plugin, compile it to a kernel snapshot, and run the
   snapshot (skips the `dart run` build-hook + JIT overhead).
3. **Parse** — parse every source file with the `analyzer` (cached by mtime).
4. **Collect + generate** — feed units to plugins; collect their outputs.
5. **Write** — format and write each output; delete orphaned `.craft.dart`.

## Requirements

- Dart SDK: ^3.5.0
