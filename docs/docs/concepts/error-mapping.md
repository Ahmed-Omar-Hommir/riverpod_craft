---
sidebar_position: 6
---

# Error Mapping

When a provider's `create()`, a stream, or a `@command` throws, riverpod_craft catches it and exposes it on the state as a plain `Object`:

```dart
ref.noteDetailProvider(id: '1').watch().when(
  loading: () => const CircularProgressIndicator(),
  data: (note) => Text(note.title),
  error: (error) {
    // error is Object — you have to inspect it everywhere
    if (error is SocketException) return const Text('No connection');
    return Text('$error');
  },
);
```

Repeating that `is`-ladder in every widget gets old fast. With a **global error mapper** you write the conversion **once** and every provider exposes your own typed error instead — `state.error` becomes your type, and the `error` callbacks of `when`/`map`/etc. hand you that type directly.

## The Idea

Define a single `errorMapper` function that turns any raw error into your domain error type. The code generator wires it into every generated provider, so a caught error is converted before it ever reaches your UI — the same way the [pagination mapper](./pagination#global-mapper) converts your API's page response.

Every state and notifier is generic over the error type `F`: `DataState<T, F>`, `PagedDataState<T, F>`, `ArgCommandState<T, F, Arg>`. By default (no mapper configured) the generator emits `Object` for `F`, so nothing changes. When you configure a mapper, the generator emits its return type instead — e.g. `DataState<Note, AppError>`.

## Step 1: Define your error type

```dart
sealed class AppError {
  const AppError(this.message);
  final String message;
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}

class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

class UnknownError extends AppError {
  const UnknownError(super.message, this.cause);
  final Object cause;
}
```

## Step 2: Write the mapper function

Create a file (e.g. `lib/error_mapper.dart`) with a top-level function named `errorMapper` that takes the raw `Object` and returns your type:

```dart
import 'models/app_error.dart';

AppError errorMapper(Object error) {
  if (error is SocketException) return const NetworkError('No internet connection');
  if (error is HttpException) return NotFoundError(error.message);
  return UnknownError(error.toString(), error);
}
```

## Step 3: Configure in `riverpod_craft.yaml`

```yaml
error_mapper: lib/error_mapper.dart
```

## What happens

The code generator reads your mapper function and:

1. **Types every provider with your error** — generated state and notifiers use your mapper's return type as `F`, e.g. `class $$NoteDetail extends DataNotifier<Note, AppError, ...>` exposing `DataState<Note, AppError>`.
2. **Inlines the mapper** — your function is copied into every `.craft.dart` file that has a provider which can fail (future, stream, paged, or command). It's inlined under a private name (`_$errorMapper`) so it never collides when provider files are re-exported through a barrel.
3. **Routes every caught error through it** — each generated notifier overrides `mapError`, so the error stored on the state is already your type:

```dart
// generated in each notifier
@override
AppError mapError(Object error) => _$errorMapper(error);
```

Now your widgets get `AppError` directly — no cast, and the compiler enforces exhaustive handling of your sealed variants:

```dart
ref.noteDetailProvider(id: '1').watch().when(
  loading: () => const CircularProgressIndicator(),
  data: (note) => Text(note.title),
  error: (error) => switch (error) {   // error is AppError
    NetworkError(:final message) => Text(message),
    NotFoundError(:final message) => Text(message),
    UnknownError(:final message) => Text(message),
  },
);
```

The mapper applies everywhere errors surface — `DataState.error`, `PagedDataState.error`, and command `ArgCommandState.error` are all typed `AppError`.

:::caution
The mapper is **copied verbatim** into each generated `.craft.dart`, which is a `part of` your provider file. Part files share the library's imports, so both the mapper body and the error type must be importable from your provider files. In practice: import your error type (e.g. `app_error.dart`) in the provider files that use it, and keep the mapper free of imports your providers don't already have. You don't import the mapper file itself — the generator copies the function in for you.
:::

:::note
Adding a mapper changes generated state types from `DataState<T, Object>` to `DataState<T, YourError>`. If you reference these types explicitly in your own code (e.g. a `DataState<Note>` field), update them to include the error type — or let type inference fill it in.
:::

## Next

See **[Pagination → Global Mapper](./pagination#global-mapper)** for the response-mapping counterpart, and the [Annotations Reference](/docs/reference/annotations) for the full annotation list.
