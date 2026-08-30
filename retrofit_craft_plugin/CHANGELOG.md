## 0.10.1

### Fixed

- Allow `craft_runner` 0.11.x, whose CLI rename does not change the builder
  API used by this package.

## 0.10.0

### Breaking

- **Now a craft_runner builder.** `RetrofitCraftBuilder` (a
  `CraftBuilderMultiFile`) replaces `RetrofitApiPlugin`, and the
  `tool/craft.dart` + `runWithPlugins(...)` bootstrap is gone.
- **Configuration moves** from the `retrofit_craft:` block in
  `riverpod_craft.yaml` to nested keys under
  `retrofit_craft_plugin:RetrofitCraftBuilder` in `craft_runner.yaml`. The keys
  themselves (`entry_path`, `version_path`, `output`, `root_class_name`,
  `default_entry`, `default_version`) are unchanged.
- Requires analyzer `>=13.3.0 <15.0.0`.

### Fixed

- The package description said "build_runner generator", which it never was.

## 0.7.1

- Fix: widen the `riverpod_craft_plugin` (and dev `craft_runner`) dependencies
  to `^0.7.0` so this plugin resolves alongside the rest of the 0.7.x ecosystem.
  0.7.0 shipped with `^0.5.0`, which caused version-solving failures.

## 0.7.0

- Synchronized release across the `riverpod_craft` ecosystem. No functional
  changes in this package.

## 0.5.0

- Synchronized release across `riverpod_craft_plugin`, `craft_runner`,
  `retrofit_craft`, and `retrofit_craft_plugin`. No functional changes vs
  0.4.0 — version bumped to keep the four packages in lock-step going
  forward.
- Internal: `riverpod_craft_plugin` and `craft_runner` constraints bumped
  to `^0.5.0`.

## 0.4.0

Initial pub.dev release. Versioned in lock-step with `retrofit_craft`,
`craft_runner`, and `riverpod_craft_plugin`.

- `RetrofitApiPlugin`: a `craft_runner` **project-wide** plugin
  (`ProjectWideCraftPlugin`) that scans every `.dart` file under `lib/`
  for `@Api`-annotated retrofit classes plus the user's `Entry` / `Version`
  enums (or classes with static const fields) and emits one aggregator file
  (`lib/app/app_api.craft.dart` by default).
- Accepts annotation arguments as `Entry.identity`, `Entry.identity`
  (property access), or the Dart 3.6+ dot-shorthand `.identity`.
- Configurable via `riverpod_craft.yaml`:
  `default_entry`, `default_version`, `entry_path`, `version_path`,
  `output`, `root_class_name`.
- Concatenates `Version.<name>.path` onto the entry's baseUrl when the
  Version enum declares a `final String path;` field — lets the URL
  version segment live in one place.
- Handles class-name collisions across files with auto-generated `as`
  aliases on imports.
- Validates: unknown entry/version, mixed versioned+unversioned within a
  group, duplicate versions, missing required entry — each as a clear
  diagnostic that aborts generation.
