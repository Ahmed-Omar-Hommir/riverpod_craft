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
