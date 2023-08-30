import 'package:askaide/repo/data/creative_island_data.dart';
import 'package:askaide/repo/model/creative_island_history.dart';

class CreativeIslandRepository {
  final CreativeIslandDataProvider _dataProvider;

  CreativeIslandRepository(this._dataProvider);

  Future<List<CreativeIslandHistory>> getRecentHistories(
      String itemId, int count,
      {int? userId}) async {
    return await _dataProvider.getRecentHistories(
      itemId,
      count,
      userId: userId,
    );
  }

  Future<CreativeIslandHistory> create(
    String itemId, {
    String? arguments,
    String? prompt,
    String? answer,
    String? taskId,
    String? status,
    int? userId,
  }) async {
    return await _dataProvider.create(
      itemId,
      arguments: arguments,
      prompt: prompt,
      answer: answer,
      taskId: taskId,
      status: status,
      userId: userId,
    );
  }

  /// 更新
  Future<void> update(int id, CreativeIslandHistory his) async {
    await _dataProvider.update(id, his);
  }

  Future<int> delete(int hisId) async {
    return await _dataProvider.delete(hisId);
  }

  Future<CreativeIslandHistory?> history(int id) async {
    return await _dataProvider.history(id);
  }
}
