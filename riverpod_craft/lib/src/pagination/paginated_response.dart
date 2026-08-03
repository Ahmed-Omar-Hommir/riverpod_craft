/// A single page of results for key/cursor-based pagination.
///
/// [nextPageKey] is the key used to fetch the *following* page; return `null`
/// to signal this is the last page. [hasMorePages] is derived from it, so the
/// contract is: **`null` next key ⟺ no more pages.**
class PaginatedResponse<T, PageKey> {
  const PaginatedResponse({
    required this.nextPageKey,
    required this.results,
    this.meta,
  });

  /// Key for the next page, or `null` when this is the last page.
  final PageKey? nextPageKey;

  /// Items on this page.
  final List<T> results;

  final MetaInfo? meta;
}

class MetaInfo<PageKey> {
  const MetaInfo({
    this.pageSize,
    this.totalPages,
    this.totalItems,
    this.lastPage,
    this.extra,
    this.pageKey,
  });
  final int? pageSize;
  final int? totalPages;
  final int? totalItems;
  final int? lastPage;
  final PageKey? pageKey;
  final Map<dynamic, dynamic>? extra;
}
