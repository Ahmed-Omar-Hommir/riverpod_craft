## 0.3.0

- Add `ProviderValue<T>` interface for synchronous providers
- Add advanced documentation section with reusable component examples
- Add `custom_dropdown` example showcasing `SyncDropdown`, `AsyncDropdown`, and `AsyncPagedDropdown`

## 0.2.2

- Add `map`, `maybeMap`, `mapOrNull` pattern matching to all state types
- Supported on: `DataState`, `CommandState`, `ArgCommandState`, `AsynchronousState`
- Nullable extensions also support `map` family for `CommandState?` and `ArgCommandState?`

## 0.2.1

- `@settable` facades now use `state = value` directly instead of `updateState()` bridge
- Generated files include `// GENERATED CODE - DO NOT MODIFY BY HAND` header
- Added `ignore_for_file` directives to suppress protected member warnings

## 0.2.0

- Removed `setState()` and `updateState()` from `StateDataNotifier` base class
- `@settable` providers now generate `updateState()` in the notifier class directly
- Added examples documentation: counter, quote, notes, movies_app, command_strategies
- Renamed arcade example to command_strategies

## 0.1.1

- Generated files now use `.craft.dart` extension instead of `.pg.dart`
- Added `PagedProviderValue` interface for `CraftPagedListView`
- Added `PagedDataProviderFacade` with `listen()` support
- Explicit type parameters on all `NotifierProvider` declarations

## 0.1.0

- Initial alpha release
- Better syntax for accessing providers via generated accessor classes
- Side effect solution using `@command` annotation
- Annotations: `@provider`, `@command`, `@settable`, `@keepAlive`, `@family`
- Concurrency control: `@droppable`, `@restartable`, `@sequential`, `@concurrent`
- Async state types: `DataState`, `CommandState`, `ArgCommandState`
- `DataNotifier` and `StateDataNotifier` base classes
- `Result<T>` type for error handling
