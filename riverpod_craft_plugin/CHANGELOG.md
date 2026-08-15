## 0.10.0

### Breaking

- **Now a craft_runner builder.** `RiverpodCraftBuilder` (a
  `CraftBuilderSingleFile`) replaces the old plugin registration; the
  build_runner `Builder` and its `build.yaml` are removed. Configure it under
  `riverpod_craft_plugin:RiverpodCraftBuilder` in `craft_runner.yaml`, with
  `error_mapper` and `paged_provider_mapper` as nested keys.
- **A missing `part` directive is now an error.** The generator no longer
  rewrites your source to insert it; it throws, naming the exact line to add.
- `ProjectWideCraftPlugin` is removed.
- `RiverpodCraftPlugin.collect` takes the active `RiverpodCraftOptions` as a
  second argument.
- Requires analyzer `>=13.3.0 <15.0.0` for the AST redesign (`namePart`,
  `NamedArgument`, flat `FormalParameter`).

### Added

- Generates the `.future` accessor, the `providerInit` call (respecting
  `@noInit`), and key-based paged notifiers for riverpod_craft 0.10.0.
- `RiverpodCraftOptions` resolves the error mapper and paged mapper from source,
  inlining each under a private name so re-exported provider files never
  collide.

## 0.7.0

- Synchronized release across the `riverpod_craft` ecosystem
  (`riverpod_craft`, `riverpod_craft_plugin`, `craft_runner`, `retrofit_craft`,
  `retrofit_craft_plugin`). No functional changes in this package.

## 0.5.0

- Synchronized release across `riverpod_craft_plugin`, `craft_runner`,
  `retrofit_craft`, and `retrofit_craft_plugin`. No functional changes vs
  0.4.0 — version bumped to keep the four packages in lock-step going
  forward.

## 0.4.0

- Add `ProjectWideCraftPlugin` — a complementary interface for generators that
  must aggregate information across the entire project and emit standalone
  output files (e.g. a single `AppApi` aggregator), as opposed to the per-file
  `RiverpodCraftPlugin<T>` interface which emits a `part` file next to a source.

## 0.3.0

- Version bump to align with riverpod_craft 0.3.0

## 0.2.2

- Version bump to align with riverpod_craft 0.2.2

## 0.2.1

- Version bump to align with riverpod_craft 0.2.1

## 0.2.0

- Version bump to align with riverpod_craft 0.2.0

## 0.1.0

- Initial release
- Plugin interface (`RiverpodCraftPlugin<T>`)
- Clean data models (`DartClassInfo`, `DartFunctionInfo`, `AnnotationInfo`, `MethodInfo`)
- Shared `ParameterInfo`
