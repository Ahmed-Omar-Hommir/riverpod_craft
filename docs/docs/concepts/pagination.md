---
sidebar_position: 5
---

# Pagination

Fetching paginated data — infinite scroll lists, load-more buttons — usually means managing page numbers, loading states, and appending results manually. With riverpod_craft, you write one `create(int page)` method and the rest is generated.

## Writing a Paged Provider

A paged provider is a `@provider` class where the `create()` method takes `int page` as its first parameter. This tells the code generator it's paginated.

```dart
@provider
class Notes extends _$Notes {
  @override
  Paged<Note> create(int page, {required String? category}) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/notes?page=$page&category=$category'),
    );
    return ApiPagedResponse.fromJson(
      jsonDecode(response.body),
      (json) => Note.fromJson(json),
    );
  }
}
```

The `int page` parameter is special — it won't appear in the provider's family args. Only the other parameters (like `category`) become family args:

```dart
// ✅ page is handled internally
ref.notesProvider(category: 'work');

// ❌ you don't pass page — the generated code manages it
ref.notesProvider(1, category: 'work'); // wrong!
```

## Using in a Widget

### With `CraftPagedListView`

The simplest way — pass the provider facade and the widget handles pagination automatically:

```dart
class NotesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CraftPagedListView<Note>(
      provider: ref.notesProvider(category: 'work'),
      itemBuilder: (context, note, index) => ListTile(
        title: Text(note.title),
        subtitle: Text(note.body),
      ),
    );
  }
}
```

## Global Mapper

Most APIs return their own pagination format — not `PaginatedResponse`. Instead of converting in every provider, you write **one mapper function** and the code generator applies it everywhere.

### Step 1: Define your API model

```dart
class ApiPagedResponse<T> {
  final List<T> items;
  final int page;
  final int totalItems;
  final int totalPages;
  final int perPage;
  // ...
}
```

### Step 2: Write the mapper function

Create a file (e.g., `lib/paged_mapper.dart`) with a function named `pagedMapper`:

```dart
import 'package:riverpod_craft/riverpod_craft.dart';
import 'models/api_paged_response.dart';

PaginatedResponse<T> pagedMapper<T>(ApiPagedResponse<T> data) {
  return PaginatedResponse(
    results: data.items,
    currentPage: data.page,
    total: data.totalItems,
    lastPage: data.totalPages,
    pageSize: data.perPage,
  );
}
```

### Step 3: Configure in `riverpod_craft.yaml`

```yaml
paged_provider_mapper: lib/paged_mapper.dart
```

### What happens

The code generator reads your mapper function and:

1. **Changes `Paged<T>`** — instead of `Future<PaginatedResponse<T>>`, it becomes `Future<ApiPagedResponse<T>>` (your API type)
2. **Inlines the mapper** — the mapper function is written directly into every `.craft.dart` file that has paged providers
3. **Wraps `create()` automatically** — the generated `buildPagedData()` calls `pagedMapper(await create(page, ...))`

Your provider just returns the raw API response:

```dart
@provider
class Notes extends _$Notes {
  @override
  Paged<Note> create(int page, {required String? category}) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/notes?page=$page&category=$category'),
    );
    // Return your raw API type — the mapper handles conversion
    return ApiPagedResponse.fromJson(
      jsonDecode(response.body),
      (json) => Note.fromJson(json),
    );
  }
}
```

:::info
You don't need to import the mapper file in your provider. The code generator copies the mapper function into the generated `.craft.dart` file automatically.
:::

## Next

To add side effects (delete, update) to your paged providers, see **[Command](./command)**.

See the [Annotations Reference](/docs/reference/annotations) for all pagination-related annotations.
