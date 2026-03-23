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
