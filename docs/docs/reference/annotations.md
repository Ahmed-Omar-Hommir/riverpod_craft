---
sidebar_position: 1
---

# Annotations

## `@provider`

Marks a class or function as a Riverpod provider. The generator creates the notifier, provider declaration, and accessor classes.

### Class-based (async)

```dart
part 'todos_provider.pg.dart';

@provider
class Todos extends _$Todos {
  @override
  Future<List<Todo>> create() => api.fetchTodos();
}
```

### Class-based (sync)

```dart
part 'counter_provider.pg.dart';

@provider
class Counter extends _$Counter {
  @override
  int create() => 0;
}
```

### Functional (async)

```dart
part 'user_provider.pg.dart';

@provider
Future<User> user(Ref ref) => api.getUser();
```

### Stream

```dart
part 'messages_provider.pg.dart';

@provider
Stream<List<Message>> messages(Ref ref) => api.messagesStream();
```

### Return type determines provider type

| Return type | Notifier base class | State type |
|-------------|-------------------|------------|
| `T` | `StateDataNotifier` | `T` (sync) |
| `Future<T>` | `DataNotifier` | `DataState<T>` |
| `Stream<T>` | `DataNotifier` | `DataState<T>` |

---

## `@providerValue`

For simple functional value providers. Creates a read-only provider with no notifier.

```dart
part 'theme_mode_provider.pg.dart';

@providerValue
ThemeMode currentTheme(Ref ref) => ThemeMode.light;
```

---

## `@command`

Marks an async method inside a `@provider` class as a side effect. Each command gets its own independent state.

```dart
@provider
class Notes extends _$Notes {
  @override
  Future<List<Note>> create() => repo.getNotes();

  @override
  @command
  @droppable
  Future<Note> addNote({required String title}) async {
    final note = await repo.addNote(title: title);
    reload();
    return note;
  }
}
```

See [Side Effects](../concepts/side-effects) for the full guide.

---

## `@keepAlive`

Prevents the provider from being auto-disposed when no longer listened to.

```dart
@provider
@keepAlive
class Auth extends _$Auth {
  @override
  Future<AuthState> create() => checkAuth();
}
```

By default, all providers are auto-disposed. Use `@keepAlive` for state that should persist (auth, app settings, etc.).

---

## `@settable`

Enables `setState()` on functional providers. Only works on functional providers — ignored on class-based providers.

```dart
@provider
@settable
NoteCategory categoryFilter(Ref ref) => NoteCategory.all;
```

See [Settable Providers](../concepts/settable-providers) for the full guide.

---

## `@family`

Creates parameterized providers. Use parameters in `create()` (class-based) or function parameters (functional).

### Functional

```dart
part 'note_detail_provider.pg.dart';

@provider
Future<Note> noteDetail(Ref ref, {required String id}) {
  return repo.getNoteById(id);
}
```

Usage:

```dart
ref.noteDetailProvider(id: '123').watch()
```

### Class-based

```dart
part 'user_profile_provider.pg.dart';

@provider
class UserProfile extends _$UserProfile {
  @override
  Future<Profile> create({required String userId}) {
    return api.getProfile(userId);
  }
}
```

Usage:

```dart
ref.userProfileProvider(userId: 'abc').watch()
```

---

## Concurrency annotations

Used with `@command` to control behavior when a command is called while already running.

| Annotation | Behavior |
|------------|----------|
| `@droppable` | Ignores new calls while busy |
| `@restartable` | Cancels the current execution, starts the new one |
| `@sequential` | Queues calls, processes one at a time |
| `@concurrent` | Allows multiple simultaneous executions |

```dart
@override
@command
@restartable
Future<List<Result>> search({required String query}) => api.search(query);
```
