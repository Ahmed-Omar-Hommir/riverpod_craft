import 'package:riverpod_craft/riverpod_craft.dart';
import 'models/api_paged_response.dart';

/// Global mapper: converts your API's pagination model into PaginatedResponse.
///
/// Configure in riverpod_craft.yaml:
///   paged_provider_mapper: lib/paged_mapper.dart
///
/// The code generator wraps every paged provider's create() with this mapper,
/// so you never manually convert ApiPagedResponse → PaginatedResponse.
PaginatedResponse<T, int> pagedMapper<T>(ApiPagedResponse<T> data) {
  return PaginatedResponse(
    results: data.items,
    nextPageKey: data.page < data.totalPages ? data.page + 1 : null,
  );
}
