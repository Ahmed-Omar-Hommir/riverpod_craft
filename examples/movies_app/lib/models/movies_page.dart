/// Raw paged response from the TMDB API, before it's mapped into a
/// `PaginatedResponse` by the global `pagedMapper`.
class MoviesPage<T> {
  const MoviesPage({
    required this.results,
    required this.page,
    required this.totalPages,
  });

  final List<T> results;
  final int page;
  final int totalPages;
}
