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

Repeating that `is`-ladder in every widget gets old fast. With a **global error mapper** you write the conversion **once** and every provider exposes your own typed error instead.

## The Idea

Define a single `errorMapper` function that turns any raw error into your domain error type. The code generator wires it into every generated provider, so a caught error is converted before it ever reaches your UI — the same way the [pagination mapper](./pagination#global-mapper) converts your API's page response.

By default (no mapper configured) errors stay `Object` and nothing changes.

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

1. **Inlines the mapper** — your function is copied into every `.craft.dart` file that has a provider which can fail (future, stream, paged, or command). It's inlined under a private name (`_$errorMapper`) so it never collides when provider files are re-exported through a barrel.
2. **Routes every caught error through it** — each generated notifier overrides `mapError`, so the error stored on the state is already your type:

```dart
// generated in each notifier
@override
Object mapError(Object error) => _$errorMapper(error);
```

Now your widgets work against `AppError` directly:

```dart
ref.noteDetailProvider(id: '1').watch().when(
  loading: () => const CircularProgressIndicator(),
  data: (note) => Text(note.title),
  error: (error) => switch (error as AppError) {
    NetworkError(:final message) => Text(message),
    NotFoundError(:final message) => Text(message),
    UnknownError(:final message) => Text(message),
  },
);
```

The mapper applies everywhere errors surface — `DataState.error`, `PagedDataState.error`, and command `ArgCommandState.error`.

:::info
The state field is still typed `Object` — your mapped instance is stored in it, so cast or pattern-match (`error as AppError`) at the UI. This mirrors pagination, which keeps a fixed `PaginatedResponse` type and converts at the boundary.
:::

:::caution
The mapper is **copied verbatim** into each generated `.craft.dart`, which is a `part of` your provider file. Part files share the library's imports, so the mapper may only reference symbols that are importable from your provider files. In practice: import your error type (e.g. `app_error.dart`) in the provider files that use it, and keep the mapper free of imports your providers don't already have. You don't import the mapper file itself — the generator copies the function in for you.
:::

## Next

See **[Pagination → Global Mapper](./pagination#global-mapper)** for the response-mapping counterpart, and the [Annotations Reference](/docs/reference/annotations) for the full annotation list.
