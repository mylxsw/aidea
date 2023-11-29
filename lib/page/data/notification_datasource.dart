import 'package:askaide/helper/logger.dart';
import 'package:askaide/repo/api/notification.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:loading_more_list/loading_more_list.dart';

class NotificationDatasource extends LoadingMoreBase<NotifyMessage> {
  int startId = 0;
  bool _hasMore = true;
  bool forceRefresh = false;

  NotificationDatasource();

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    try {
      final messages =
          await APIServer().notifications(startId: startId, cache: false);

      if (startId == 0) {
        clear();
      }

      for (var element in messages.data) {
        add(element);
      }

      if (messages.data.isEmpty) {
        _hasMore = false;
      }

      startId = messages.lastId;
      return true;
    } catch (e) {
      Logger.instance.e(e);
      return false;
    }
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    startId = 0;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !notifyStateChanged;
    var result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }
}
