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

class OffsetPageData<T> {
  int startId;
  int lastId;
  int perPage;
  List<T> data;

  OffsetPageData({
    required this.startId,
    required this.lastId,
    required this.perPage,
    required this.data,
  });
}
