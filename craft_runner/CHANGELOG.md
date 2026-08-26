## 0.11.0

### Breaking

- Rename the one-shot `craft_runner craft` command to `craft_runner build`.

### Changed

- Keep the globally activated `craft_runner` executable as a lightweight
  launcher that delegates commands to the project's package version through
  `dart run craft_runner`.

## 0.10.0

Complete rewrite. craft_runner is now a standalone CLI that parses your project
once, keeps the parse in memory, and drives plain-Dart builders. It knows
nothing about any particular generator — riverpod, retrofit and your own
builders are all loaded from `craft_runner.yaml`.

0.8.0 and 0.9.0 were never published; this release covers everything since
0.7.1.

### Breaking

- **New builder API.** `ProjectWideCraftPlugin` and in-process plugin
  registration are gone. A builder extends `CraftBuilderSingleFile` (called per
  file with the path and its `ParseStringResult`) or `CraftBuilderMultiFile`
  (called with every in-scope file at once), declares a `scope` of source roots,
  and exposes a `fromConfig(Map<String, Object?>)` factory.
- **Config lives in `craft_runner.yaml`**, replacing `riverpod_craft.yaml`. The
  `plugins:` list and its per-plugin namespaced blocks become a `builders:` map
  keyed `<package>:<ClassName>`, with each builder's options nested under its
  own key.
- **Commands changed** to `craft_runner craft` (build once) and
  `craft_runner watch`. `generate <file>`, `clean`, `init` and `help` are gone;
  use `--help` and `--version`.
- **Parsing is syntactic only.** Sources go through `parseString(...)` and are
  never resolved, so builders see syntax, not types — a typedef or an inherited
  member cannot be looked up. This is the trade that makes the runner fast.
- `runWithPlugins(...)` is removed along with the `tool/craft.dart` bootstrap it
  required. Delete that file.

### Added

- Installs as an executable: `dart pub global activate craft_runner`. The
  project still needs `craft_runner` as a dependency, since the builder entry
  compiles against its package config.
- Builders are AOT-compiled to a native binary on first run and reused until the
  config or any builder package changes.
- `writeIfChanged(path, content)` skips byte-identical writes, so a builder's own
  output never wakes the watcher.
- One watcher per project, enforced by a file lock — a second `watch` exits
  rather than double-building every change.

## 0.7.1

- Fix: widen the `riverpod_craft_plugin` dependency to `^0.7.0` so craft_runner
  resolves alongside the rest of the 0.7.x ecosystem. 0.7.0 shipped with
  `^0.5.0`, which made version solving fail for any project that also depended
  on `riverpod_craft_plugin: 0.7.0`.

## 0.7.0

- **Global error mapper** (breaking): generated error types are now a generic
  parameter `F`, mapped from provider errors via a top-level `errorMapper`
  function configured by `error_mapper:` in `riverpod_craft.yaml`.
- Faster watch/codegen on large projects: project-wide passes cache parses and
  re-parse only changed files; startup scans and the file watcher are scoped to
  `lib/` + `test/` (instead of the whole project root); generated files are
  written only when their content changes (idempotent, which also prevents
  watch-trigger loops).
- Richer watch logs: per-phase startup timing, the file that triggered each
  pass, and parsed/cached + written/unchanged counts.

## 0.6.0

- **YAML-driven plugin loading**: `riverpod_craft.yaml` can now list
  community plugins as `<package_name>:<ClassName>` entries under a
  `plugins:` block. When `dart run craft_runner watch` (or `generate` /
  `clean`) is invoked and the list is non-empty, craft_runner generates
  `.dart_tool/craft_runner/entry.dart` — a Dart script that imports each
  plugin and dispatches via `runWithPlugins(...)` — then spawns `dart run`
  on it. The generated entry uses runtime `is` checks to route each
  plugin to per-file or project-wide registration.

  ```yaml
  plugins:
    - retrofit_craft_plugin:RetrofitApiPlugin
  ```

  No `tool/craft.dart` boilerplate required for the common case. Projects
  that already use `runWithPlugins(...)` via a custom `tool/craft.dart`
  keep working — the handoff is skipped when plugins are already
  registered in-process.

- Only `craft_runner` is bumped for this release; `riverpod_craft_plugin`,
  `retrofit_craft`, and `retrofit_craft_plugin` stay at 0.5.0.

## 0.5.0

- Synchronized release across `riverpod_craft_plugin`, `craft_runner`,
  `retrofit_craft`, and `retrofit_craft_plugin`. No functional changes vs
  0.4.0 — version bumped to keep the four packages in lock-step going
  forward.
- Internal: `riverpod_craft_plugin` constraint bumped to `^0.5.0`.

## 0.4.0

- Project-wide plugins: new `ProjectWideCraftPlugin` interface support for
  generators that aggregate across the whole project and emit standalone
  (non-part) output files (e.g. retrofit_craft's `AppApi` aggregator).
- `runWithPlugins` gains an optional `projectWidePlugins:` parameter.
- Watch mode triggers a debounced project-wide pass on any `lib/**/*.dart`
  change (skipping `*.craft.dart`, `*.g.dart`, `*.freezed.dart`).
- `riverpod_craft_plugin` dependency switched from the stale hosted pin
  (`^0.1.0`) to a path dep on the local 0.4.0 package — publish bundles must
  republish `riverpod_craft_plugin` first.

## 0.3.0

- Generate `ProviderValue<T>` facade for synchronous providers
- Version bump to align with riverpod_craft 0.3.0

## 0.2.2

- Version bump to align with riverpod_craft 0.2.2

## 0.2.1

- Remove `updateState()` from generated notifier classes
- `setState` in facades now uses `.state = value` directly
- Generated files include `// GENERATED CODE - DO NOT MODIFY BY HAND` header
- Added `ignore_for_file` directives for protected member warnings

## 0.2.0

- Generate `updateState()` inside `@settable` notifier classes instead of base class
- Removed logging plugin from notes example

## 0.1.1

- Fix: add explicit type parameters to `NotifierProvider` declarations
- Plugin system: extensible code generation via `RiverpodCraftPlugin`
- Built-in `ProviderPlugin` and `CommandPlugin` can be extended and replaced
- `runWithPlugins()` API for custom code generation pipelines

## 0.1.0

- Initial alpha release
- Code generation from `@provider`, `@command`, and `@settable` annotations
- Watch mode for real-time code generation
- Single file generation
- Clean command to remove generated files
- Init command for project setup
- Support for family providers and complex parameter types
