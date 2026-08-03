import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagedDataState<T, F, PageKey> with EquatableMixin {
  const PagedDataState(this.pagingState);

  final PagingState<PageKey, T> pagingState;

  List<T>? get items => pagingState.items;

  bool get isLoading =>
      pagingState.isLoading && (items == null || items!.isEmpty);

  bool get isNextPageLoading =>
      pagingState.isLoading && items != null && items!.isNotEmpty;

  bool get hasNextPage => pagingState.hasNextPage;

  F? get error => pagingState.error as F?;

  bool get hasError => error != null;

  bool get isFirstPageError => hasError && (items == null || items!.isEmpty);

  bool get isEmpty =>
      items != null && items!.isEmpty && !isLoading && !hasError;

  @override
  List<Object?> get props => [pagingState];
}

extension PagedDataStateX<T, F, PageKey> on PagedDataState<T, F, PageKey> {
  PagingState<PageKey, T> get _state => pagingState;

  PagedDataState<T, F, PageKey> _copy(PagingState<PageKey, T> next) =>
      PagedDataState<T, F, PageKey>(next);

  /// Add [item] to the front of the first page.
  PagedDataState<T, F, PageKey> prependItem(T item) {
    final pages = _state.pages;
    if (pages == null || pages.isEmpty) return this;
    return _copy(
      _state.copyWith(
        pages: [
          [item, ...pages.first],
          ...pages.skip(1),
        ],
      ),
    );
  }

  /// Add [item] to the end of the last page.
  PagedDataState<T, F, PageKey> appendItem(T item) {
    final pages = _state.pages;
    if (pages == null || pages.isEmpty) return this;
    return _copy(
      _state.copyWith(
        pages: [
          ...pages.take(pages.length - 1),
          [...pages.last, item],
        ],
      ),
    );
  }

  /// Remove every item matching [test].
  PagedDataState<T, F, PageKey> removeWhere(bool Function(T item) test) {
    final pages = _state.pages;
    if (pages == null) return this;
    return _copy(
      _state.copyWith(
        pages: pages
            .map((page) => page.where((item) => !test(item)).toList())
            .toList(),
      ),
    );
  }

  /// Update every item matching [test] using [update].
  PagedDataState<T, F, PageKey> updateWhere(
    bool Function(T item) test,
    T Function(T item) update,
  ) {
    final pages = _state.pages;
    if (pages == null) return this;
    return _copy(
      _state.copyWith(
        pages: pages
            .map(
              (page) =>
                  page.map((item) => test(item) ? update(item) : item).toList(),
            )
            .toList(),
      ),
    );
  }

  /// Update the first item matching [test] using [update].
  PagedDataState<T, F, PageKey> updateFirstWhere(
    bool Function(T item) test,
    T Function(T item) update,
  ) {
    final pages = _state.pages;
    if (pages == null) return this;
    var updated = false;
    return _copy(
      _state.copyWith(
        pages: pages
            .map(
              (page) => page.map((item) {
                if (!updated && test(item)) {
                  updated = true;
                  return update(item);
                }
                return item;
              }).toList(),
            )
            .toList(),
      ),
    );
  }

  /// Remove the item at the flattened [index], keeping the page structure.
  PagedDataState<T, F, PageKey> removeAt(int index) {
    final pages = _state.pages;
    if (pages == null || index < 0) return this;

    var offset = index;
    var removed = false;
    final next = <List<T>>[];
    for (final page in pages) {
      if (!removed && offset < page.length) {
        next.add([...page]..removeAt(offset));
        removed = true;
      } else {
        if (!removed) offset -= page.length;
        next.add(page);
      }
    }
    if (!removed) return this; // index out of range
    return _copy(_state.copyWith(pages: next));
  }

  /// Replace all items with [newItems], collapsing them into a single page.
  ///
  /// Reuses the first existing page key so `pages`/`keys` stay aligned; a no-op
  /// on an empty state, which has no key to anchor to.
  PagedDataState<T, F, PageKey> replaceAll(List<T> newItems) {
    final keys = _state.keys;
    if (keys == null || keys.isEmpty) return this;
    return _copy(_state.copyWith(pages: [newItems], keys: [keys.first]));
  }
}
