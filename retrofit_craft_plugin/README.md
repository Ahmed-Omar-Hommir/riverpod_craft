# retrofit_craft_plugin

A **project-wide** [`craft_runner`](../craft_runner) plugin that generates
a grouped, versioned retrofit API client aggregator (`AppApi`) from
[`retrofit_craft`](../retrofit_craft) annotations.

Unlike per-file craft plugins, this one scans every Dart file under `lib/`,
finds the `@Api`-annotated retrofit classes plus `Entry` and `Version`
subclasses, and emits a single standalone file:

```dart
final api = AppApi(dio: Dio());
api.identity.auth.v1.login(phone: '...', password: '...');
api.consumer.order.v2.checkout(cart);
```

## Wiring

`tool/craft.dart` in your project:

```dart
import 'package:craft_runner/craft_runner.dart';
import 'package:retrofit_craft_plugin/retrofit_craft_plugin.dart';

void main(List<String> args) {
  runWithPlugins(
    const [],
    args,
    projectWidePlugins: [RetrofitApiPlugin()],
  );
}
```

Then `dart run tool/craft.dart watch` (or `generate <path>` to do a one-shot,
or `clean` to delete the generated `*.craft.dart`).

The output path and behavior are controlled by `riverpod_craft.yaml`:

```yaml
retrofit_craft:
  default_entry: Identity
  default_version: V1
  entry_path: lib/app/api/entries.dart
  version_path: lib/app/api/versions.dart
  output: lib/app/app_api.craft.dart
  root_class_name: AppApi
```

See [`retrofit_craft`](../retrofit_craft) for the annotation reference and
[`examples/retrofit_aggregator`](../examples/retrofit_aggregator) for a
complete fixture.

## How the generation works

- The plugin discovers Entry/Version subclasses anywhere under `lib/`
  (or in the configured `entry_path` / `version_path`).
- For every `@Api(entry: <X>(), version: <Y>())` retrofit class:
  - The **field name** on the entry wrapper is derived from the class name:
    strip a trailing `V<digits>`, then `Api`, then lowercase the first
    letter (`AuthApiV1` -> `auth`).
  - Multiple classes in the same `(entry, group)` are versioned siblings;
    each becomes `v<n>` on a generated `_<Entry><Group>Versions` wrapper.
  - A single class with no version (and no `default_version`) becomes a
    direct field on the entry wrapper (no version layer).
- baseUrl is emitted as `const <EntryClass>().baseUrl` so the Entry subclass
  remains the single source of truth at runtime (env-driven, lazy, etc.).
- When two source files contain a Dart class with the same name (e.g. two
  `AuthApi`s in different folders), the generator uses `import ... as _aliasN`
  and qualifies the reference.

## Status

Alpha (0.1.0), part of the `riverpod_craft` ecosystem.
