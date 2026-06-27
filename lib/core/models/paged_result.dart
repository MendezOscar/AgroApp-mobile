class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasNextPage;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      PagedResult(
        items: (json['items'] as List)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: json['totalCount'],
        page: json['page'],
        pageSize: json['pageSize'],
        hasNextPage: json['hasNextPage'],
      );
}
