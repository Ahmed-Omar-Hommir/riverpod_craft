import 'paged_data_state.dart';

/// Interface that all generated paginated provider facades implement.
///
/// This lets [CraftPagedListView] accept any paginated provider
/// without knowing its concrete facade type.
abstract class PagedDataProviderFacade<T> {
  /// Read the current state without subscribing.
  PagedDataState<T> read();

  /// Watch the state reactively (rebuilds widget on change).
  PagedDataState<T> watch();

  /// Load the next page.
  Future<void> fetchNextPage();

  /// Invalidate and re-fetch from page 1.
  void invalidate();

  /// Reset to page 1 and re-fetch.
  Future<void> reload();
}
