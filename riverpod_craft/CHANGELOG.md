## 0.1.0

- Initial alpha release
- Better syntax for accessing providers via generated accessor classes
- Side effect solution using `@command` annotation
- Annotations: `@provider`, `@providerValue`, `@command`, `@keepAlive`, `@family`
- Concurrency control: `@droppable`, `@restartable`, `@sequential`, `@concurrent`
- Async state types: `DataState`, `CommandState`, `ArgCommandState`
- `DataNotifier` and `StateDataNotifier` base classes
- `Result<T>` type for error handling
