---
sidebar_position: 1
---

# State & Provider

A **provider** in riverpod_craft provides data. You annotate a function or class with `@provider`, and the code generator creates everything you need — a Riverpod provider, notifier, and a clean API to access it.

## What is a Provider?

A provider is **auto-triggered** — it runs automatically when something uses it. You just write the logic:

```dart
@provider
String myName(Ref ref) => 'John';
```

Now you can use it anywhere:

```dart
final name = ref.myNameProvider.watch(); // 'John'
```

## Functional Provider

A single function annotated with `@provider`. Use this for simple values:

```dart
@provider
String appTitle(Ref ref) => 'My Notes App';
```

```dart
@provider
int maxItemsPerPage(Ref ref) => 20;
```

These are read-only — they provide a value, and that's it.

## Class Provider

A class annotated with `@provider` with a `create()` method. Use this when you need custom methods or business logic:

```dart
@provider
class Cart extends _$Cart {
  @override
  List<CartItem> create() => [];

  void addItem(CartItem item) {
    setState([...state, item]);
  }

  void removeItem(String itemId) {
    setState(state.where((item) => item.id != itemId).toList());
  }

  void clear() => setState([]);
}
```

The generated code exposes your methods directly:

```dart
ref.cartProvider.addItem(item);
ref.cartProvider.removeItem(id: '123');
ref.cartProvider.clear();

final items = ref.cartProvider.watch();
```

### Use in widgets

```dart
class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.cartProvider.watch();

    return Column(
      children: [
        ...items.map((item) => ListTile(
          title: Text(item.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => ref.cartProvider.removeItem(item.id),
          ),
        )),
        FilledButton(
          onPressed: () => ref.cartProvider.clear(),
          child: const Text('Clear Cart'),
        ),
      ],
    );
  }
}
```

## Simple State `@settable`

Add `@settable` to a functional provider to make the state updatable. Use this for simple state like filters, toggles, and search queries:

```dart
@provider
@settable
NoteCategory categoryFilter(Ref ref) => NoteCategory.all;
```

```dart
@provider
@settable
String searchQuery(Ref ref) => '';
```

```dart
@provider
@settable
bool isDarkMode(Ref ref) => false;
```

Now you can update the value with `setState()`:

```dart
// Update
ref.categoryFilterProvider.setState(NoteCategory.work);
ref.searchQueryProvider.setState('meeting notes');
ref.isDarkModeProvider.setState(true);

// Watch — reacts automatically to changes
final category = ref.categoryFilterProvider.watch();
```

:::info
`@settable` only works on **functional** providers. Class-based providers use their own methods to update state.
:::

## When to Use Each Style

| | Functional | Functional + `@settable` | Class Provider |
|---|---|---|---|
| **What** | Read-only value | Simple updatable state | State + custom logic |
| **Examples** | App title, config values, computed data | Filters, toggles, search query, theme mode | Cart, form state, counters with logic |
| **Update with** | Cannot update | `setState(newValue)` | Custom methods like `addItem()`, `clear()` |

## Next

Now that you know how to manage local state, learn how to **fetch data from APIs**:

→ **[Fetch Data](./fetch-data)**

To **perform side effects** (submit forms, delete items, API mutations), see:

→ **[Side Effect (Command)](./side-effects)**

:::tip Commands for data fetching too
Commands aren't just for mutations. You can use `@command` to fetch data that requires user input — like submitting a phone number to look up user info, or filling a form to query search results. See **[Command](./command)** for details.
:::
