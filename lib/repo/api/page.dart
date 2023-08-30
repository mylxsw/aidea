class PagedData<T> {
  int page;
  int perPage;
  int? total;
  int? lastPage;
  List<T> data;

  PagedData({
    required this.page,
    required this.perPage,
    this.total,
    this.lastPage,
    required this.data,
  });
}
