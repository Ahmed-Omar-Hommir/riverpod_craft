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
