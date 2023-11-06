import 'dart:convert';

import 'package:askaide/bloc/bloc_manager.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/error.dart';
import 'package:askaide/helper/model_resolver.dart';
import 'package:askaide/helper/queue.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/chat_message_repo.dart';
import 'package:askaide/repo/data/chat_message_data.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:askaide/repo/openai_repo.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatMessageBloc extends BlocExt<ChatMessageEvent, ChatMessageState> {
  final ChatMessageRepository chatMsgRepo;
  final SettingRepository settingRepo;
  final int roomId;
  final int? chatHistoryId;

  ChatMessageBloc(
    this.roomId, {
    required this.chatMsgRepo,
    required this.settingRepo,
    this.chatHistoryId,
  }) : super(ChatMessageInitial()) {
    on<ChatMessageSendEvent>(_messageSendEventHandler);
    on<ChatMessageGetRecentEvent>(_getRecentEventHandler);
    on<ChatMessageClearAllEvent>(_clearAllEventHandler);
    on<ChatMessageBreakContextEvent>(_breakContextEventHandler);
    on<ChatMessageDeleteEvent>(_deleteMessageEventHandler);
  }

  Future<void> _deleteMessageEventHandler(event, emit) async {
    await chatMsgRepo.removeMessage(roomId, event.ids);

    ChatHistory? his;
    if (event.chatHistoryId != null && event.chatHistoryId! > 0) {
      his = await chatMsgRepo.getChatHistory(event.chatHistoryId!);
    }

    emit(ChatMessagesLoaded(
      await chatMsgRepo.getRecentMessages(
        roomId,
        userId: APIServer().localUserID(),
        chatHistoryId: event.chatHistoryId,
      ),
      chatHistory: his,
    ));
  }

  /// 设置上下文清理标识
  Future<void> _breakContextEventHandler(event, emit) async {
    // 查询当前 Room 信息
    final room = await queryRoomById(chatMsgRepo, roomId);
    if (room == null) {
      emit(ChatMessagesLoaded(
        await chatMsgRepo.getRecentMessages(
          roomId,
          userId: APIServer().localUserID(),
        ),
        error: '选择的数字人不存在',
      ));
      return;
    }

    final lastMessage = await chatMsgRepo.getLastMessage(
      roomId,
      userId: APIServer().localUserID(),
    );

    if (lastMessage != null &&
        (lastMessage.type == MessageType.contextBreak ||
            lastMessage.isInitMessage())) {
      return;
    }

    await chatMsgRepo.sendMessage(
      roomId,
      Message(
        Role.receiver,
        AppLocale.contextBreakMessage,
        ts: DateTime.now(),
        type: MessageType.contextBreak,
        roomId: roomId,
        userId: APIServer().localUserID(),
      ),
    );

    if (room.initMessage != null && room.initMessage != '') {
      await chatMsgRepo.sendMessage(
        roomId,
        Message(
          Role.receiver,
          room.initMessage!,
          ts: DateTime.now(),
          type: MessageType.initMessage,
          roomId: roomId,
          userId: APIServer().localUserID(),
        ),
      );
    }

    final messages = await chatMsgRepo.getRecentMessages(
      roomId,
      userId: APIServer().localUserID(),
    );
    emit(ChatMessagesLoaded(messages));
    emit(ChatMessageUpdated(messages.last));
  }

  /// 清空消息事件处理
  Future<void> _clearAllEventHandler(event, emit) async {
    // 查询当前 Room 信息
    final room = await queryRoomById(chatMsgRepo, roomId);
    if (room == null) {
      emit(ChatMessagesLoaded(
        await chatMsgRepo.getRecentMessages(
          roomId,
          userId: APIServer().localUserID(),
        ),
        error: '选择的数字人不存在',
      ));
      return;
    }

    await chatMsgRepo.clearMessages(
      roomId,
      userId: APIServer().localUserID(),
    );

    if (room.initMessage != null && room.initMessage != '') {
      await chatMsgRepo.sendMessage(
        roomId,
        Message(
          Role.receiver,
          room.initMessage!,
          ts: DateTime.now(),
          type: MessageType.initMessage,
          roomId: roomId,
          userId: APIServer().localUserID(),
        ),
      );
    }

    emit(ChatMessagesLoaded(await chatMsgRepo.getRecentMessages(
      roomId,
      userId: APIServer().localUserID(),
    )));
  }

  /// 页面加载事件处理
  Future<void> _getRecentEventHandler(event, emit) async {
    ChatHistory? his;
    if (event.chatHistoryId != null && event.chatHistoryId! > 0) {
      his = await chatMsgRepo.getChatHistory(event.chatHistoryId!);
    }

    emit(ChatMessagesLoaded(
      await chatMsgRepo.getRecentMessages(
        roomId,
        userId: APIServer().localUserID(),
        chatHistoryId: event.chatHistoryId,
      ),
      chatHistory: his,
    ));
  }

  /// 消息发送事件处理
  Future<void> _messageSendEventHandler(event, emit) async {
    if (event.message is! Message) {
      return;
    }

    Message message = event.message as Message;
    ChatHistory? localChatHistory;

    // 如果是聊一聊，自动创建聊天记录历史
    if (roomId == chatAnywhereRoomId) {
      if (message.chatHistoryId == null || message.chatHistoryId! <= 0) {
        final chatHistory = await chatMsgRepo.createChatHistory(
          title: event.message.text,
          userId: APIServer().localUserID(),
          roomId: roomId,
          model: event.message.model,
          lastMessage: message.text,
        );

        localChatHistory = chatHistory;
        message.chatHistoryId = chatHistory.id;
        emit(ChatAnywhereInited(chatHistory.id!));
      }
    }

    int? localChatHistoryId = message.chatHistoryId;

    // 查询当前 Room 信息
    final room = await queryRoomById(chatMsgRepo, roomId);
    if (room == null) {
      emit(ChatMessagesLoaded(
        await chatMsgRepo.getRecentMessages(
          roomId,
          userId: APIServer().localUserID(),
          chatHistoryId: localChatHistoryId,
        ),
        error: '选择的数字人不存在',
        chatHistory: localChatHistory,
      ));
      return;
    }

    if (roomId == chatAnywhereRoomId &&
        localChatHistoryId != null &&
        localChatHistoryId > 0) {
      final chatHistory = await chatMsgRepo.getChatHistory(localChatHistoryId);
      if (chatHistory != null && chatHistory.model != null) {
        room.model = chatHistory.model!;
        localChatHistory = chatHistory;
      }
    }

    // 查询最后一条消息
    // 如果最后一条消息符合以下情况，则创建时间线
    //  1. 最后一条消息不存在
    //  2. 最后一条消息的时间距离当前时间超过 3 小时
    var last = await chatMsgRepo.getLastMessage(
      roomId,
      chatHistoryId: localChatHistoryId,
      userId: APIServer().localUserID(),
    );
    if (last == null ||
        last.ts == null ||
        DateTime.now().difference(last.ts!).inMinutes > 60 * 3) {
      // 发送时间线消息
      await chatMsgRepo.sendMessage(
        roomId,
        Message(
          Role.receiver,
          DateFormat('y-MM-dd HH:mm').format(DateTime.now().toLocal()),
          type: MessageType.timeline,
          ts: DateTime.now(),
          roomId: roomId,
          userId: APIServer().localUserID(),
          chatHistoryId: localChatHistoryId,
        ),
      );
    }

    // 发送当前用户消息
    message.model = room.model;
    message.userId = APIServer().localUserID();
    message.status = 0;

    // 聊天历史记录中，所有发送状态为 pending 状态的消息，全部设置为失败
    await chatMsgRepo.fixMessageStatus(roomId);

    // 记录当前消息
    var sentMessageId = 0;
    if (event.isResent &&
        event.index == 0 &&
        last != null &&
        last.type == MessageType.text) {
      // 如果当前是消息重发，同时重发的是最后一条消息，则不会重新生成该消息，直接生成答案即可
      sentMessageId = last.id!;
      if (last.statusIsFailed()) {
        // 如果最后一条消息发送失败，则重新发送
        await chatMsgRepo.updateMessagePart(roomId, last.id!, [
          MessagePart('status', 0),
        ]);
      }
    } else {
      sentMessageId = await chatMsgRepo.sendMessage(roomId, message);
    }

    // 更新 Room 最后活跃时间
    // 这里没有使用 await，因为不需要等待更新完成，让 room 的更新异步的去处理吧
    if (!Ability().enableAPIServer()) {
      chatMsgRepo.updateRoomLastActiveTime(roomId);
    }

    // 重新查询消息列表，此时包含了刚刚发送的消息+机器人思考中消息
    final messages = await chatMsgRepo.getRecentMessages(
      roomId,
      userId: APIServer().localUserID(),
      chatHistoryId: localChatHistoryId,
    );

    // 创建机器人思考中系统消息
    Message waitMessage = Message(
      Role.receiver,
      '',
      ts: DateTime.now(),
      type: MessageType.text,
      model: room.model,
      roomId: roomId,
      userId: APIServer().localUserID(),
      refId: sentMessageId,
      chatHistoryId: localChatHistoryId,
    );

    // 回写消息 ID
    waitMessage.id = await chatMsgRepo.sendMessage(roomId, waitMessage);
    waitMessage.isReady = false;

    messages.add(waitMessage);

    emit(ChatMessagesLoaded(messages,
        processing: true, chatHistory: localChatHistory));
    emit(ChatMessageUpdated(waitMessage, processing: true));

    // 等待监听机器人应答消息
    final queue = GracefulQueue<ChatStreamRespData>();
    try {
      RequestFailedException? error;
      var listener = queue.listen(const Duration(milliseconds: 10), (items) {
        final systemCmds = items.where((e) => e.role == 'system').toList();
        if (systemCmds.isNotEmpty) {
          for (var element in systemCmds) {
            try {
              // SYSTEM 命令
              // - type: 命令类型
              //
              // type=summary （默认值）
              //     - question_id: 问题 ID
              //     - answer_id: 答案 ID
              //     - quota_consumed: 消耗的配额
              //     - token: 消耗的 token
              //     - info: 提示信息
              final cmd = jsonDecode(element.content);

              message.serverId = cmd['question_id'];
              waitMessage.serverId = cmd['answer_id'];

              final quotaConsumed = cmd['quota_consumed'] ?? 0;
              final tokenConsumed = cmd['token'] ?? 0;

              final info = cmd['info'] ?? '';
              if (info != '') {
                waitMessage.setExtra({'info': info});
              }

              if (quotaConsumed == 0 && tokenConsumed == 0) {
                continue;
              }

              waitMessage.quotaConsumed = quotaConsumed;
              waitMessage.tokenConsumed = tokenConsumed;
            } catch (e) {
              // ignore: avoid_print
            }
          }
        }

        waitMessage.text += items
            .where((e) => e.role != 'system')
            .map((e) => e.content)
            .join('');
        emit(ChatMessageUpdated(waitMessage, processing: true));

        // 失败处理
        for (var e in items) {
          if (e.code != null && e.code! > 0) {
            error = RequestFailedException(e.error ?? '请求处理失败', e.code!);
          }
        }
      });

      await ModelResolver.instance
          .request(
            room: room,
            contextMessages: messages.sublist(0, messages.length - 1),
            onMessage: queue.add,
            maxTokens: room.maxTokens,
          )
          .whenComplete(queue.finish);

      await listener;

      waitMessage.text = waitMessage.text.trim();
      if (waitMessage.text.isEmpty) {
        error = RequestFailedException('机器人没有回答任何内容', 500);
      }

      if (error != null) {
        throw error!;
      }

      // 机器人应答完成，将最后一条机器人应答消息更新到数据库，替换掉思考中消息
      waitMessage.isReady = true;
      await chatMsgRepo.updateMessage(roomId, waitMessage.id!, waitMessage);

      // 更新聊天问题的服务端 ID 和消息状态
      var sentMessageParts = <MessagePart>[];
      sentMessageParts.add(MessagePart('status', 1));
      if (message.serverId != null && message.serverId! > 0) {
        sentMessageParts.add(MessagePart('server_id', message.serverId));
      }

      await chatMsgRepo.updateMessagePart(
        roomId,
        sentMessageId,
        sentMessageParts,
      );

      if (room.id == chatAnywhereRoomId &&
          localChatHistoryId != null &&
          localChatHistoryId > 0) {
        // 更新聊天历史纪录最后一条消息
        final chatHistory =
            await chatMsgRepo.getChatHistory(localChatHistoryId);
        if (chatHistory != null) {
          chatHistory.lastMessage = waitMessage.text;
          // 异步处理就好，不需要等待
          chatMsgRepo.updateChatHistory(localChatHistoryId, chatHistory);
        }
      }

      // 重新查询消息列表，此时包含了刚刚发送的消息+机器人应答消息
      emit(ChatMessagesLoaded(
        await chatMsgRepo.getRecentMessages(
          roomId,
          userId: APIServer().localUserID(),
          chatHistoryId: localChatHistoryId,
        ),
        chatHistory: localChatHistory,
      ));
    } catch (e) {
      final error = resolveErrorMessage(e, isChat: true);
      await chatMsgRepo.updateMessagePart(
        roomId,
        sentMessageId,
        [
          MessagePart('status', 2),
          MessagePart('extra', jsonEncode({'error': error.toString()})),
        ],
      );

      if (waitMessage.id != null) {
        if (waitMessage.isReady) {
          await chatMsgRepo.updateMessage(
            roomId,
            waitMessage.id!,
            Message(
              Role.receiver,
              error.toString(),
              id: waitMessage.id,
              ts: DateTime.now(),
              type: MessageType.system,
              roomId: roomId,
              userId: APIServer().localUserID(),
              chatHistoryId: localChatHistoryId,
            ),
          );
        } else {
          await chatMsgRepo.removeMessage(roomId, [waitMessage.id!]);
        }
      }

      emit(ChatMessagesLoaded(
        await chatMsgRepo.getRecentMessages(
          roomId,
          userId: APIServer().localUserID(),
          chatHistoryId: localChatHistoryId,
        ),
        error: error,
        chatHistory: localChatHistory,
      ));

      queue.finish();
    } finally {
      queue.dispose();
    }

    emit(ChatMessageUpdated(waitMessage));
  }
}

Future<Room?> queryRoomById(
    ChatMessageRepository chatMsgRepo, int roomId) async {
  Room? room;
  if (Ability().enableAPIServer()) {
    final roomInServer = await APIServer().room(roomId: roomId);
    room = Room(
      roomInServer.name,
      'chat',
      description: roomInServer.description,
      id: roomInServer.id,
      userId: roomInServer.userId,
      createdAt: roomInServer.createdAt,
      lastActiveTime: roomInServer.lastActiveTime,
      systemPrompt: roomInServer.systemPrompt,
      priority: roomInServer.priority ?? 0,
      model: '${roomInServer.vendor}:${roomInServer.model}',
      initMessage: roomInServer.initMessage,
      maxContext: roomInServer.maxContext,
      maxTokens: roomInServer.maxTokens,
      localRoom: false,
    );
  } else {
    room = await chatMsgRepo.room(roomId);
  }

  return room;
}
