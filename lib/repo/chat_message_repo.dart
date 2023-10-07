import 'dart:async';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/repo/data/chat_history.dart';
import 'package:askaide/repo/data/room_data.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/data/chat_message_data.dart';
import 'package:askaide/repo/model/room.dart';

class ChatMessageRepository {
  final ChatMessageDataProvider _chatMsgDataProvider;
  final RoomDataProvider _chatRoomDataProvider;
  final ChatHistoryProvider _chatHistoryProvider;

  ChatMessageRepository(
    this._chatRoomDataProvider,
    this._chatMsgDataProvider,
    this._chatHistoryProvider,
  );

  /// 获取所有 room
  Future<List<Room>> rooms({int? userId}) async {
    return await _chatRoomDataProvider.chatRooms(userId: userId);
  }

  /// 创建 room
  Future<Room> createRoom({
    required String name,
    required category,
    String? description,
    String? model,
    String? color,
    String? systemPrompt,
    int? userId,
    int? maxContext,
  }) async {
    return await _chatRoomDataProvider.createRoom(
      name: name,
      category: category,
      description: description,
      model: model,
      color: color,
      systemPrompt: systemPrompt,
      userId: userId,
      maxContext: maxContext,
    );
  }

  /// 删除 room
  Future<void> deleteRoom(int roomId) async {
    await _chatRoomDataProvider.deleteRoom(roomId);
    await _chatMsgDataProvider.clearMessages(roomId);
  }

  /// 返回 room 中最近的消息
  Future<List<Message>> getRecentMessages(
    int roomId, {
    int? userId,
    int? chatHistoryId,
  }) async {
    return (await _chatMsgDataProvider.getRecentMessages(
      roomId,
      chatMessagePerPage,
      userId: userId,
      chatHistoryId: chatHistoryId,
    ))
        .reversed
        .toList();
  }

  /// 发送消息到 room
  Future<int> sendMessage(int roomId, Message message) async {
    return await _chatMsgDataProvider.sendMessage(roomId, message);
  }

  /// 修复所有消息的状态（pending -> failed）
  Future<void> fixMessageStatus(int roomId) async {
    return await _chatMsgDataProvider.fixMessageStatus(roomId);
  }

  /// 更新消息
  Future<void> updateMessage(int roomId, int id, Message message) async {
    return await _chatMsgDataProvider.updateMessage(roomId, id, message);
  }

  /// 部分更新消息
  Future<void> updateMessagePart(
    int roomId,
    int id,
    List<MessagePart> parts,
  ) async {
    return await _chatMsgDataProvider.updateMessagePart(roomId, id, parts);
  }

  /// 删除消息
  Future<void> removeMessage(int roomId, List<int> ids) async {
    return await _chatMsgDataProvider.removeMessage(roomId, ids);
  }

  /// 清空 room 中的消息
  Future<void> clearMessages(int roomId, {int? userId}) async {
    await _chatMsgDataProvider.clearMessages(roomId, userId: userId);
  }

  /// 获取 room 中最后一条消息
  Future<Message?> getLastMessage(int roomId,
      {int? userId, int? chatHistoryId}) async {
    return await _chatMsgDataProvider.getLastMessage(roomId,
        userId: userId, chatHistoryId: chatHistoryId);
  }

  /// 获取 room
  Future<Room?> room(int roomId) async {
    final room = await _chatRoomDataProvider.room(roomId);
    if (room != null) {
      room.localRoom = true;
    }

    return room;
  }

  /// 更新 room
  Future<int> updateRoom(Room room) async {
    return await _chatRoomDataProvider.updateRoom(room);
  }

  /// 更新 room 最后活跃时间
  Future<void> updateRoomLastActiveTime(int roomId) async {
    return await _chatRoomDataProvider.updateRoomLastActiveTime(roomId);
  }

  Future<ChatHistory> createChatHistory({
    required String title,
    int? userId,
    int? roomId,
    String? lastMessage,
    String? model,
  }) {
    return _chatHistoryProvider.create(
      title: title,
      userId: userId,
      roomId: roomId,
      model: model,
      lastMessage: lastMessage,
    );
  }

  Future<List<ChatHistory>> recentChatHistories(
    int roomId,
    int count, {
    int? userId,
  }) async {
    return await _chatHistoryProvider.getChatHistories(
      roomId,
      count,
      userId: userId,
    );
  }

  Future<ChatHistory?> getChatHistory(int chatId) async {
    return await _chatHistoryProvider.history(chatId);
  }

  Future<int> deleteChatHistory(int chatId) async {
    return await _chatHistoryProvider.delete(chatId);
  }

  Future<int> updateChatHistory(int chatId, ChatHistory chatHistory) async {
    chatHistory.id = chatId;
    return await _chatHistoryProvider.update(chatHistory);
  }
}
