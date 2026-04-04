/// Example: your API's pagination model (different from PaginatedResponse).
class ApiPagedResponse<T> {
  const ApiPagedResponse({
    required this.items,
    required this.page,
    required this.totalItems,
    required this.totalPages,
    required this.perPage,
  });

  final List<T> items;
  final int page;
  final int totalItems;
  final int totalPages;
  final int perPage;

  factory ApiPagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    return ApiPagedResponse(
      items: (json['items'] as List).map((e) => fromJsonItem(e as Map<String, dynamic>)).toList(),
      page: json['page'] as int,
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      perPage: json['per_page'] as int,
    );
  }
}
