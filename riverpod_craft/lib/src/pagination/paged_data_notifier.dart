import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod/riverpod.dart';

import '../error_mapper.dart';
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
    extends Notifier<PagedDataState<T>>
    with ErrorMapper {
  /// Family argument set by the generated provider constructor.
  late final Arg arg;

  /// Implement this — fetch a single page of data.
  Future<PaginatedResponse<T>> buildPagedData(int page);

  bool _pending = false;

  @override
  /// Initializes the paging state and triggers the first page load.
  PagedDataState<T> build() {
    _pending = false;

    Future.microtask(() => fetchNextPage());
    return PagedDataState(PagingState());
  }

  /// Load the next page of results.
  ///
  /// Safe to call multiple times — concurrent calls are guarded.
  Future<void> fetchNextPage() async {
    if (_pending) return;
    final s = state.pagingState;
    if (s.isLoading) return;
    if (!s.hasNextPage && s.pages != null && s.pages!.isNotEmpty) return;

    _pending = true;
    state = PagedDataState(s.copyWith(isLoading: true, error: null));

    final nextPage = (s.keys?.lastOrNull ?? 0) + 1;

    try {
      final response = await buildPagedData(nextPage);

      state = PagedDataState(
        s.copyWith(
          pages: [...?s.pages, response.results],
          keys: [...?s.keys, nextPage],
          hasNextPage: response.hasMorePages,
          isLoading: false,
        ),
      );
    } catch (error) {
      state = PagedDataState(s.copyWith(error: mapError(error), isLoading: false));
    } finally {
      _pending = false;
    }
  }

  /// Reset to page 1 and re-fetch.
  Future<void> reload() async {
    _pending = false;
    state = PagedDataState(PagingState());
    await fetchNextPage();
  }
}
