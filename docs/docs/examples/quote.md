---
sidebar_position: 3
---

# Quote

A quote-of-the-day app that fetches a random quote, lets you save it, and keeps a favorites list.

**What you'll learn:**
- `@provider` with `Future<T>` for async data
- `@command @droppable` for side effects
- `@keepAlive` to persist state across invalidations
- Class-based provider with custom methods
- `.listen()` to react to command completion
- `.invalidate()` to refresh data

[Source code](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/examples/quote)

---

## Providers

### Fetch a random quote

A simple async provider — returns a `Future<Quote>`:

```dart
@provider
Future<Quote> randomQuote(Ref ref) => getRandomQuote();
```

Call `ref.randomQuoteProvider.invalidate()` to fetch a new one.

### Save quote — `@command @droppable`

A standalone command for the save side effect. `@droppable` ignores duplicate taps while a save is in progress:

```dart
@command
@droppable
Future<String> saveQuote(Ref ref, {required String quoteId}) async {
  await saveQuoteToStorage(quoteId);
  return quoteId;
}
```

### Favorites list — `@keepAlive`

A class-based provider with custom methods. `@keepAlive` prevents the list from being disposed when no widget is watching:

```dart
@provider
@keepAlive
class FavoriteQuotes extends _$FavoriteQuotes {
  @override
  List<Quote> create() => [];

  void addQuote(Quote quote) {
    if (!state.contains(quote)) {
      state = [...state, quote];
    }
  }

  void removeQuote(Quote quote) {
    state = state.where((q) => q.id != quote.id).toList();
  }

  bool isFavorite(String quoteId) {
    return state.any((q) => q.id == quoteId);
  }
}
```

---

## Usage

### Watching async state

```dart
final quoteState = ref.randomQuoteProvider.watch();

quoteState.when(
  loading: () => CircularProgressIndicator(),
  data: (quote) => Text('"${quote.text}" — ${quote.author}'),
  error: (_) => Text('Failed to load'),
);
```

### Listening to command results

Use `.listen()` to show feedback (snackbar, toast) when a command completes:

```dart
ref.saveQuoteCommand.listen((_, next) {
  next.whenOrNull(
    data: (_, __) => showSnackBar('Quote saved!'),
    error: (_, err) => showSnackBar('Failed to save: $err'),
  );
});
```

### Combining providers

Add to favorites and trigger the save in one tap:

```dart
FilledButton(
  onPressed: () {
    ref.favoriteQuotesProvider.addQuote(quote);
    ref.saveQuoteCommand.run(quoteId: quote.id);
  },
  child: Text('Save'),
)
```

### Refreshing data

Invalidate the provider to re-fetch:

```dart
FilledButton(
  onPressed: () => ref.randomQuoteProvider.invalidate(),
  child: Text('New Quote'),
)
```
