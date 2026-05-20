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
