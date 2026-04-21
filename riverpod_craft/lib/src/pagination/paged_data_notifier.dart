import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod/riverpod.dart';

import 'paged_data_state.dart';
import 'paginated_response.dart';

/// Base class for paginated providers.
///
/// Extend this in your generated code — your `create(int page, ...)` method
/// maps to [buildPagedData].
///
/// The notifier manages page tracking, loading state, and error handling.
/// Call [fetchNextPage] to load the next page of results (triggered
/// automatically on build and when the UI reaches the end of the list).
abstract class PagedDataNotifier<T, Arg extends Record>
    extends Notifier<PagedDataState<T>> {
  /// Family argument set by the generated provider constructor.
  late final Arg arg;

  /// Implement this — fetch a single page of data.
  Future<PaginatedResponse<T>> buildPagedData(int page);

  bool _pending = false;
  int _currentPage = 0;

  @override
  /// Initializes the paging state and triggers the first page load.
  PagedDataState<T> build() {
    _pending = false;
    _currentPage = 0;

    Future.microtask(() => fetchNextPage());
    return PagedDataState(const PagingState());
  }

  /// Load the next page of results.
  ///
  /// Safe to call multiple times — concurrent calls are guarded.
  Future<void> fetchNextPage() async {
    if (_pending) return;
    if (!state.hasNextPage && _currentPage > 0) return;

    _pending = true;
    final nextPage = _currentPage + 1;

    try {
      final response = await buildPagedData(nextPage);
      final existingItems = state.items ?? [];
      final allItems = [...existingItems, ...response.results];

      _currentPage = nextPage;

      state = PagedDataState(
        PagingState(
          itemList: allItems,
          nextPageKey: response.hasMorePages ? nextPage + 1 : null,
        ),
      );
    } catch (error) {
      state = PagedDataState(
        PagingState(
          itemList: state.items,
          error: error,
          nextPageKey: state.pagingState.nextPageKey,
        ),
      );
    } finally {
      _pending = false;
    }
  }

  /// Reset to page 1 and re-fetch.
  Future<void> reload() async {
    _currentPage = 0;
    _pending = false;
    state = PagedDataState(const PagingState());
    await fetchNextPage();
  }
}
