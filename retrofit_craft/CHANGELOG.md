## 0.5.0

- Synchronized release across `riverpod_craft_plugin`, `craft_runner`,
  `retrofit_craft`, and `retrofit_craft_plugin`. No functional changes vs
  0.4.0 — version bumped to keep the four packages in lock-step going
  forward.

## 0.4.0

Initial pub.dev release. Versioned in lock-step with `retrofit_craft_plugin`,
`craft_runner`, and `riverpod_craft_plugin`.

### Surface

- `class Api<E extends Object, V extends Object>` — generic annotation
  applied alongside retrofit's `@RestApi()` to mark a class for inclusion in
  the generated `AppApi`. `entry` and `version` are typed `E?` / `V?`, so
  every call site gets full type safety and Dart 3.6+ dot-shorthand:

  ```dart
  @Api(entry: .identity, version: .v1)
  @RestApi()
  abstract class AuthApi { ... }
  ```

- Each project declares one concrete subclass to bind its own enums:

  ```dart
  class Api extends rc.Api<Entry, Version> {
    const Api({super.entry, super.version});
  }
  ```

### Conventions consumed by `retrofit_craft_plugin`

- `Entry` (any enum / class) is expected to expose a `String baseUrl` so the
  generator can emit `Entry.<name>.baseUrl` into every retrofit ctor call.
- `Version` (any enum / class) **optionally** exposes a `final String path;`
  field; when present, the generator appends `Version.<name>.path` to the
  baseUrl so the version segment lives in one place. Method `@POST` /
  `@GET` paths can then drop their version prefix.
- `@Api()` with no args picks up `default_entry` / `default_version` from
  `riverpod_craft.yaml`.
