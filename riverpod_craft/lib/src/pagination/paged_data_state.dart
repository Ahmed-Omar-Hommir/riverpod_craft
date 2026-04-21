import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// The state of a paginated provider.
///
/// Wraps [PagingState] from `infinite_scroll_pagination` and exposes
/// convenient getters and mutation methods for working with paginated data.
class PagedDataState<T> with EquatableMixin {
  /// Creates a [PagedDataState] wrapping the given [pagingState].
  const PagedDataState(this.pagingState);

  /// The underlying paging state — pass this to `PagedListView`.
  final PagingState<int, T> pagingState;

  /// All items loaded so far (flat list from all pages).
  List<T>? get items => pagingState.itemList;

  /// Whether the first page is loading (no items yet, no error).
  bool get isLoading => items == null && !hasError;

  /// Whether a subsequent page is currently loading.
  bool get isNextPageLoading =>
      items != null &&
      items!.isNotEmpty &&
      pagingState.nextPageKey != null &&
      !hasError;

  /// Whether more pages are available.
  bool get hasNextPage => pagingState.nextPageKey != null;

  /// The error if any.
  Object? get error => pagingState.error;

  /// Whether there is an error.
  bool get hasError => error != null;

  /// Whether the first page failed.
  bool get isFirstPageError => hasError && (items == null || items!.isEmpty);

  /// Whether the list is empty (loaded at least once but no items).
  bool get isEmpty => items != null && items!.isEmpty && !isLoading;

  @override
  List<Object?> get props => [pagingState];
}

/// Mutation methods for [PagedDataState].
///
/// These return a new state — assign back to `state`:
/// ```dart
/// state = state.removeWhere((note) => note.id == id);
/// ```
extension PagedDataStateX<T> on PagedDataState<T> {
  /// Add an item to the front of the list.
  PagedDataState<T> prependItem(T item) {
    final current = items ?? [];
    return PagedDataState(
      PagingState(
        itemList: [item, ...current],
        nextPageKey: pagingState.nextPageKey,
        error: pagingState.error,
      ),
    );
  }

  /// Add an item to the end of the list.
  PagedDataState<T> appendItem(T item) {
    final current = items ?? [];
    return PagedDataState(
      PagingState(
        itemList: [...current, item],
        nextPageKey: pagingState.nextPageKey,
        error: pagingState.error,
      ),
    );
  }

  /// Remove all items matching [test].
  PagedDataState<T> removeWhere(bool Function(T item) test) {
    final current = items;
    if (current == null) return this;
    return PagedDataState(
      PagingState(
        itemList: current.where((item) => !test(item)).toList(),
        nextPageKey: pagingState.nextPageKey,
        error: pagingState.error,
      ),
    );
  }

  /// Update all items matching [test] using [update].
  PagedDataState<T> updateWhere(
    bool Function(T item) test,
    T Function(T item) update,
  ) {
    final current = items;
    if (current == null) return this;
    return PagedDataState(
      PagingState(
        itemList: current
            .map((item) => test(item) ? update(item) : item)
            .toList(),
        nextPageKey: pagingState.nextPageKey,
        error: pagingState.error,
      ),
    );
  }

  /// Update the first item matching [test] using [update].
  PagedDataState<T> updateFirstWhere(
    bool Function(T item) test,
    T Function(T item) update,
  ) {
    final current = items;
    if (current == null) return this;
    bool found = false;
    return PagedDataState(
      PagingState(
        itemList: current.map((item) {
          if (!found && test(item)) {
            found = true;
            return update(item);
          }
          return item;
        }).toList(),
        nextPageKey: pagingState.nextPageKey,
        error: pagingState.error,
      ),
    );
  }

  /// Replace all items with [newItems].
  PagedDataState<T> replaceAll(List<T> newItems) {
    return PagedDataState(
      PagingState(
        itemList: newItems,
        nextPageKey: pagingState.nextPageKey,
        error: pagingState.error,
      ),
    );
  }

  /// Remove the item at [index].
  PagedDataState<T> removeAt(int index) {
    final current = items;
    if (current == null || index < 0 || index >= current.length) return this;
    final updated = [...current]..removeAt(index);
    return PagedDataState(
      PagingState(
        itemList: updated,
        nextPageKey: pagingState.nextPageKey,
        error: pagingState.error,
      ),
    );
  }
}
