import 'package:askaide/repo/model/message.dart';
import 'package:sqflite/sqlite_api.dart';

class MessagePart {
  final String key;
  final dynamic value;

  MessagePart(this.key, this.value);
}

class ChatMessageDataProvider {
  Database conn;
  ChatMessageDataProvider(this.conn);

  Future<List<Message>> getRecentMessages(int roomId, int count,
      {int? userId, int? chatHistoryId}) async {
    var userConditon =
        userId == null ? ' AND user_id IS NULL' : ' AND user_id = $userId';

    if (chatHistoryId != null) {
      userConditon += ' AND chat_history_id = $chatHistoryId';
    }

    List<Map<String, Object?>> messages = await conn.query(
      'chat_message',
      where: 'room_id = ? $userConditon',
      whereArgs: [roomId],
      orderBy: 'id DESC',
      limit: count,
    );

    return messages.map((e) => Message.fromMap(e)).toList();
  }

  Future<Message?> getLastMessage(
    int roomId, {
    int? userId,
    int? chatHistoryId,
  }) async {
    var userConditon =
        userId == null ? ' AND user_id IS NULL' : ' AND user_id = $userId';
    if (chatHistoryId != null) {
      userConditon += ' AND chat_history_id = $chatHistoryId';
    }

    List<Map<String, Object?>> messages = await conn.query(
      'chat_message',
      where: 'room_id = ? $userConditon',
      whereArgs: [roomId],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (messages.isEmpty) {
      return null;
    }

    return Message.fromMap(messages.first);
  }

  Future<int> sendMessage(int roomId, Message message) async {
    if (roomId > 0) {
      message.roomId = roomId;
    }

    return conn.insert('chat_message', message.toMap());
  }

  Future<void> fixMessageStatus(int roomId) async {
    return conn.transaction((txn) async {
      await txn.update(
        'chat_message',
        {'status': 2},
        where: 'room_id = ? AND status = 0',
        whereArgs: [roomId],
      );
    });
  }

  Future<void> updateMessage(int roomId, int id, Message message) async {
    return conn.transaction((txn) async {
      await txn.update(
        'chat_message',
        message.toMap(),
        where: 'id = ? AND room_id = ?',
        whereArgs: [id, roomId],
      );
    });
  }

  Future<void> updateMessagePart(
    int roomId,
    int id,
    List<MessagePart> parts,
  ) async {
    var kvs = <String, Object?>{};
    for (var element in parts) {
      kvs[element.key] = element.value;
    }

    return conn.transaction((txn) async {
      await txn.update(
        'chat_message',
        kvs,
        where: 'id = ? AND room_id = ?',
        whereArgs: [id, roomId],
      );
    });
  }

  Future<void> removeMessage(int roomId, List<int> ids) async {
    var placeholders = List.generate(ids.length, (index) => '?').join(',');
    ids.add(roomId);
    return conn.transaction((txn) async {
      await txn.delete(
        'chat_message',
        where: 'id in ($placeholders) AND room_id = ?',
        whereArgs: ids,
      );
    });
  }

  Future<void> clearMessages(int roomId, {int? userId}) async {
    final userConditon =
        userId == null ? ' AND user_id IS NULL' : ' AND user_id = $userId';
    return conn.transaction((txn) async {
      await txn.delete(
        'chat_message',
        where: 'room_id = ? $userConditon',
        whereArgs: [roomId],
      );
    });
  }
}
