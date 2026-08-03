import 'package:riverpod_craft/riverpod_craft.dart';
import 'models/countries_page.dart';

/// Global paged mapper: converts the raw [CountriesPage] into a
/// [PaginatedResponse] and decides how to fetch the next page.
///
/// Configured via `paged_provider_mapper: lib/paged_mapper.dart`.
PaginatedResponse<T, int> pagedMapper<T>(CountriesPage<T> data) {
  return PaginatedResponse(
    results: data.results,
    nextPageKey: data.page < data.lastPage ? data.page + 1 : null,
  );
}
