/// Raw paged response for the countries list, before it's mapped into a
/// `PaginatedResponse` by the global `pagedMapper`.
class CountriesPage<T> {
  const CountriesPage({
    required this.results,
    required this.page,
    required this.lastPage,
  });

  final List<T> results;
  final int page;
  final int lastPage;
}
