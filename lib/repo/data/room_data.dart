import 'package:askaide/helper/constant.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:sqflite/sqlite_api.dart';

class RoomDataProvider {
  Database conn;
  RoomDataProvider(this.conn);

  /// 获取所有 room
  Future<List<Room>> chatRooms({int? userId}) async {
    final userConditon =
        userId == null ? 'user_id IS NULL' : 'user_id = $userId';
    List<Map<String, Object?>> rooms = await conn.query(
      'chat_room',
      where: userConditon,
      orderBy: 'priority DESC, last_active_time DESC',
    );

    return rooms.map((e) => Room.fromMap(e)).toList();
  }

  /// 创建 room
  Future<Room> createRoom({
    required String name,
    required String category,
    String? description,
    String? model,
    String? color,
    String? systemPrompt,
    int? userId,
    int? maxContext,
  }) async {
    final room = Room(
      name,
      category,
      userId: userId,
      color: color,
      model: model ?? defaultChatModel,
      description: description,
      systemPrompt: systemPrompt,
      maxContext: maxContext ?? 10,
      createdAt: DateTime.now(),
      lastActiveTime: DateTime.now(),
    );

    room.id = await conn.insert('chat_room', room.toJson());
    return room;
  }

  /// 删除 room
  Future<int> deleteRoom(int roomId) async {
    return conn.delete('chat_room', where: 'id = ?', whereArgs: [roomId]);
  }

  /// 获取指定 room
  Future<Room?> room(int roomId) async {
    List<Map<String, Object?>> rooms = await conn.query('chat_room',
        where: 'id = ?', whereArgs: [roomId], limit: 1);
    if (rooms.isEmpty) {
      return null;
    }

    return Room.fromMap(rooms.first);
  }

  /// 更新 room
  Future<int> updateRoom(Room room) async {
    if (room.id == null) {
      throw Exception('room id is null');
    }

    return conn.update(
      'chat_room',
      room.toJson(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  /// 更新 Room 最后活跃时间
  Future<void> updateRoomLastActiveTime(int roomId) async {
    await conn.update(
      'chat_room',
      {
        'last_active_time': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }
}
