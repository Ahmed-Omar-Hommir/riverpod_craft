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
