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

### Manual control

You can also watch the state directly and build your own UI:

```dart
class NotesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facade = ref.notesProvider(category: 'work');
    final state = facade.watch();

    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        // Trigger next page when reaching the end
        if (index == state.items.length - 1) {
          facade.fetchNextPage();
        }
        return ListTile(title: Text(state.items[index].title));
      },
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
2. **Inlines the mapper** — the mapper function is written directly into every `.pg.dart` file that has paged providers
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
You don't need to import the mapper file in your provider. The code generator copies the mapper function into the generated `.pg.dart` file automatically.
:::

## Commands Inside Paged Providers

You can add `@command` methods to paged providers — for example, deleting an item from the list:

```dart
@provider
class Notes extends _$Notes {
  @override
  Paged<Note> create(int page, {required String? category}) async {
    // fetch notes...
  }

  @override
  @command
  @droppable
  Future<void> deleteNote({required String id}) async {
    await http.delete(Uri.parse('https://api.example.com/notes/$id'));
    // Remove from local state
    state = state.removeWhere((note) => note.id == id);
  }
}
```

## Next

See the [Annotations Reference](/docs/reference/annotations) for all pagination-related annotations.
