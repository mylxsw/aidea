import 'package:askaide/helper/logger.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:loading_more_list/loading_more_list.dart';

class GalleryDatasource extends LoadingMoreBase<CreativeGallery> {
  int pageindex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;

  @override
  bool get hasMore => (_hasMore && length < 300) || forceRefresh;

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    try {
      final resp = await APIServer().creativeGallery(
        page: pageindex,
        perPage: 20,
        // cache: !forceRefresh,
      );
      if (pageindex == 1) {
        clear();
      }

      for (var element in resp.data) {
        add(element);
      }

      if (resp.page == resp.lastPage) {
        _hasMore = false;
      }

      pageindex = resp.page + 1;
      return true;
    } catch (e) {
      Logger.instance.e(e);
      return false;
    }
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    pageindex = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !notifyStateChanged;
    var result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }
}
