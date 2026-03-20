---
sidebar_position: 2
---

# State Types

## `DataState<T>`

Represents the state of an async data provider. Used for providers that return `Future<T>` or `Stream<T>`.

```dart
sealed class DataState<T> {
  factory DataState.loading();
  factory DataState.data(T data);
  factory DataState.error(Object error);
}
```

### Pattern matching

```dart
state.when(
  loading: () => CircularProgressIndicator(),
  data: (todos) => TodoList(todos),
  error: (error) => ErrorWidget(error),
);
```

### Partial matching

```dart
// Only handle some cases, provide a fallback for the rest
state.maybeWhen(
  data: (todos) => TodoList(todos),
  orElse: () => CircularProgressIndicator(),
);

// Nullable — returns null for unhandled cases
state.whenOrNull(
  error: (error) => showErrorSnackbar(error),
);
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `.isLoading` | `bool` | True if currently loading |
| `.isData` | `bool` | True if data is available |
| `.isError` | `bool` | True if in error state |
| `.dataOrNull` | `T?` | The data, or null |
| `.errorOrNull` | `Object?` | The error, or null |

---

## `ArgCommandState<T, ArgT>`

Represents the state of a command (side effect) with argument tracking. The `ArgT` is a record type of the command's parameters.

```dart
sealed class ArgCommandState<T, ArgT> {
  factory ArgCommandState.init();
  factory ArgCommandState.loading(ArgT arg);
  factory ArgCommandState.data(ArgT arg, T data);
  factory ArgCommandState.error(ArgT arg, Object error);
}
```

### Pattern matching

```dart
state.when(
  init: () => Text('Ready'),
  loading: (arg) => CircularProgressIndicator(),
  data: (arg, result) => Text('Done: $result'),
  error: (arg, error) => Text('Failed: $error'),
);
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `.isInit` | `bool` | True if no execution has happened |
| `.isLoading` | `bool` | True if currently executing |
| `.isData` | `bool` | True if completed successfully |
| `.isError` | `bool` | True if failed |
| `.isDone` | `bool` | True if data or error |
| `.arg` | `ArgT?` | The arguments passed to the command |
| `.data` | `T?` | The result data |
| `.error` | `Object?` | The error |

### Filtering by argument

When the same command can be invoked with different arguments, filter to a specific invocation:

```dart
final state = ref.notesProvider.deleteNoteCommand.watch();

// Only react to this specific note being deleted
state.whereArg((arg) => arg.id == noteId)?.whenOrNull(
  loading: (_) => CircularProgressIndicator(),
);
```

---

## `CommandState<T>`

A simplified command state without argument tracking. Used when the command has no parameters.

```dart
sealed class CommandState<T> {
  factory CommandState.init();
  factory CommandState.loading();
  factory CommandState.data(T data);
  factory CommandState.error(Object error);
}
```

---

## `Result<T>`

A simple `Ok`/`Error` union for synchronous error handling:

```dart
final result = Result.ok(42);
result.valueOrNull;  // 42
result.isOk;         // true

final err = Result.error('something went wrong');
err.errorOrNull;     // 'something went wrong'
err.isError;         // true
```

### Pattern matching

```dart
result.when(
  ok: (value) => print('Success: $value'),
  error: (error) => print('Failed: $error'),
);
```
