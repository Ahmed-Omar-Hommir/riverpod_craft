/// A paginated API response containing one page of results.
///
/// Your `create(int page, ...)` method returns `Paged<T>` which is a
/// `Future<PaginatedResponse<T>>`.
///
/// ```dart
/// @provider
/// class Notes extends _$Notes {
///   @override
///   Paged<Note> create(int page) async {
///     final response = await http.get('https://api.example.com/notes?page=$page');
///     final data = jsonDecode(response.body);
///     return PaginatedResponse(
///       results: (data['items'] as List).map((e) => Note.fromJson(e)).toList(),
///       currentPage: page,
///       total: data['total'],
///       lastPage: data['lastPage'],
///     );
///   }
/// }
/// ```
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.results,
    required this.currentPage,
    required this.total,
    required this.lastPage,
    this.pageSize = 20,
  });

  /// Items on this page.
  final List<T> results;

  /// The current page number (1-indexed).
  final int currentPage;

  /// Items per page.
  final int pageSize;

  /// Total number of items across all pages.
  final int total;

  /// The last page number.
  final int lastPage;

  /// Whether more pages are available after this one.
  bool get hasMorePages => currentPage < lastPage;
}
