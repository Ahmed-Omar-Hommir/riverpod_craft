import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// The state of a paginated provider.
///
/// Wraps [PagingState] from `infinite_scroll_pagination` v5 and exposes
/// convenient getters and mutation methods for working with paginated data.
///
/// [F] is the error type — `Object` by default, or your custom type when a
/// global `error_mapper` is configured.
class PagedDataState<T, F> with EquatableMixin {
  /// Creates a [PagedDataState] wrapping the given [pagingState].
  const PagedDataState(this.pagingState);

  /// The underlying paging state — pass this to `PagedListView`.
  final PagingState<int, T> pagingState;

  /// All items loaded so far (flat list from all pages).
  List<T>? get items => pagingState.items;

  /// Whether the first page is loading (no items yet, no error).
  bool get isLoading =>
      pagingState.isLoading && (items == null || items!.isEmpty);

  /// Whether a subsequent page is currently loading.
  bool get isNextPageLoading =>
      pagingState.isLoading && items != null && items!.isNotEmpty;

  /// Whether more pages are available.
  bool get hasNextPage => pagingState.hasNextPage;

  /// The typed error if any.
  F? get error => pagingState.error as F?;

  /// Whether there is an error.
  bool get hasError => error != null;

  /// Whether the first page failed.
  bool get isFirstPageError => hasError && (items == null || items!.isEmpty);

  /// Whether the list is empty (loaded at least once but no items).
  bool get isEmpty =>
      items != null && items!.isEmpty && !isLoading && !hasError;

  @override
  List<Object?> get props => [pagingState];
}

/// Mutation methods for [PagedDataState].
///
/// These return a new state — assign back to `state`:
/// ```dart
/// state = state.removeWhere((note) => note.id == id);
/// ```
extension PagedDataStateX<T, F> on PagedDataState<T, F> {
  List<List<T>> get _pages => pagingState.pages ?? [];

  /// Add an item to the front of the list.
  PagedDataState<T, F> prependItem(T item) {
    final pages = _pages;
    if (pages.isEmpty) {
      return PagedDataState<T, F>(
        pagingState.copyWith(
          pages: [
            [item],
          ],
        ),
      );
    }
    return PagedDataState<T, F>(
      pagingState.copyWith(
        pages: [
          [item, ...pages.first],
          ...pages.skip(1),
        ],
      ),
    );
  }

  /// Add an item to the end of the list.
  PagedDataState<T, F> appendItem(T item) {
    final pages = _pages;
    if (pages.isEmpty) {
      return PagedDataState<T, F>(
        pagingState.copyWith(
          pages: [
            [item],
          ],
        ),
      );
    }
    return PagedDataState<T, F>(
      pagingState.copyWith(
        pages: [
          ...pages.take(pages.length - 1),
          [...pages.last, item],
        ],
      ),
    );
  }

  /// Remove all items matching [test].
  PagedDataState<T, F> removeWhere(bool Function(T item) test) {
    final pages = _pages;
    if (pages.isEmpty) return this;
    return PagedDataState<T, F>(
      pagingState.copyWith(
        pages: pages
            .map((page) => page.where((item) => !test(item)).toList())
            .toList(),
      ),
    );
  }

  /// Update all items matching [test] using [update].
  PagedDataState<T, F> updateWhere(
    bool Function(T item) test,
    T Function(T item) update,
  ) {
    final pages = _pages;
    if (pages.isEmpty) return this;
    return PagedDataState<T, F>(
      pagingState.copyWith(
        pages: pages
            .map((page) => page.map((i) => test(i) ? update(i) : i).toList())
            .toList(),
      ),
    );
  }

  /// Update the first item matching [test] using [update].
  PagedDataState<T, F> updateFirstWhere(
    bool Function(T item) test,
    T Function(T item) update,
  ) {
    final pages = _pages;
    if (pages.isEmpty) return this;
    bool found = false;
    return PagedDataState<T, F>(
      pagingState.copyWith(
        pages: pages
            .map(
              (page) => page.map((item) {
                if (!found && test(item)) {
                  found = true;
                  return update(item);
                }
                return item;
              }).toList(),
            )
            .toList(),
      ),
    );
  }

  /// Replace all items with [newItems].
  PagedDataState<T, F> replaceAll(List<T> newItems) {
    return PagedDataState<T, F>(pagingState.copyWith(pages: [newItems]));
  }

  /// Remove the item at [index].
  PagedDataState<T, F> removeAt(int index) {
    final allItems = items;
    if (allItems == null || index < 0 || index >= allItems.length) return this;
    final updated = [...allItems]..removeAt(index);
    return PagedDataState<T, F>(pagingState.copyWith(pages: [updated]));
  }
}
