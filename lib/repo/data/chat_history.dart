import 'package:askaide/repo/model/chat_history.dart';
import 'package:sqflite/sqlite_api.dart';

class ChatHistoryProvider {
  Database conn;
  ChatHistoryProvider(this.conn);

  Future<List<ChatHistory>> getChatHistories(
    int roomId,
    int count, {
    int? userId,
    int? offset,
    String? keyword,
  }) async {
    keyword ??= '';
    final userConditon = userId == null ? ' AND user_id IS NULL' : ' AND user_id = $userId';

    var historyIds = [];
    if (keyword != '') {
      final histories = await conn.query(
        'chat_message',
        where: 'chat_history_id IS NOT NULL AND text LIKE ? $userConditon',
        whereArgs: ['%$keyword%'],
        columns: ['chat_history_id'],
        distinct: true,
      );

      historyIds = histories.map((h) => h['chat_history_id']).toList();
      if (historyIds.isEmpty) {
        return [];
      }
    }

    var keywordCondition = keyword != '' ? 'AND id in (${historyIds.join(',')})' : '';
    List<Map<String, Object?>> histories = await conn.query(
      'chat_history',
      where: 'room_id = ? $userConditon $keywordCondition',
      whereArgs: [roomId],
      orderBy: 'updated_at DESC',
      limit: count,
      offset: offset,
    );

    return histories.map((e) => ChatHistory.fromMap(e)).toList();
  }

  Future<ChatHistory> create({
    required String title,
    int? userId,
    int? roomId,
    String? lastMessage,
    String? model,
  }) async {
    final history = ChatHistory(
      title: title,
      userId: userId,
      roomId: roomId,
      lastMessage: lastMessage,
      model: model,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    history.id = await conn.insert('chat_history', history.toMap());
    return history;
  }

  Future<int> update(ChatHistory his) async {
    if (his.id == null) {
      throw Exception('history id is null');
    }

    his.updatedAt = DateTime.now();

    return conn.update(
      'chat_history',
      his.toMap(),
      where: 'id = ?',
      whereArgs: [his.id],
    );
  }

  Future<int> delete(int id) async {
    return conn.delete('chat_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<ChatHistory?> history(int id) async {
    List<Map<String, Object?>> histories = await conn.query('chat_history', where: 'id = ?', whereArgs: [id], limit: 1);
    if (histories.isEmpty) {
      return null;
    }

    return ChatHistory.fromMap(histories.first);
  }
}
