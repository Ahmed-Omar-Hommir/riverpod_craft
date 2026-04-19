# Custom Dropdown

Demonstrates how to build custom/generic reusable components with **riverpod_craft**.

## What's Inside

- **`ValueDisplay<T>`** — A reusable value widget that works with any `ProviderValue<T>`.
- **`AsyncDropdown<T>`** — A reusable dropdown that works with any `DataProviderValue<List<T>>`. Handles loading, error, and data states automatically.
- **`AsyncPagedDropdown<T>`** — A reusable paged dropdown that works with any `PagedProviderValue<T>`. Supports infinite scrolling, pull-to-refresh, loading/error states, and pagination.

## Running

```bash
flutter pub get
dart run craft_runner watch
flutter run
```
