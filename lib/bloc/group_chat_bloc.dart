import 'dart:convert';

import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/group.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'group_chat_event.dart';
part 'group_chat_state.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  var messages = <GroupMessage>[];
  final MessageStateManager stateManager;

  GroupChatBloc({required this.stateManager}) : super(GroupChatInitial()) {
    // 加载聊天组
    on<GroupChatLoadEvent>((event, emit) async {
      final group = await APIServer().chatGroup(event.groupId);
      final states = await stateManager.loadRoomStates(event.groupId);
      emit(GroupChatLoaded(group: group, states: states));
    });

    // 加载聊天组聊天记录
    on<GroupChatMessagesLoadEvent>((event, emit) async {
      if (event.isInitRequest) {
        try {
          final cached =
              await Cache().stringGet(key: 'group:speed:${event.groupId}');
          if (cached != null) {
            final messages = (jsonDecode(cached) as List<dynamic>)
                .map((e) => GroupMessage.fromJson(e))
                .toList();

            emit(GroupChatMessagesLoaded(messages: messages));
          }
        } catch (e) {
          Logger.instance.e(e);
        }
      }

      await refreshGroupMessages(
        event.groupId,
        page: event.page,
        forceRefresh: true,
      );

      emit(GroupChatMessagesLoaded(messages: messages));
    });

    // 发送聊天组消息
    on<GroupChatSendEvent>((event, emit) async {
      try {
        final resp = await APIServer().chatGroupSendMessage(
          event.groupId,
          GroupChatSendRequest(
            message: event.message,
            memberIds: event.members,
          ),
        );

        Logger.instance.d(resp.toJson());

        await refreshGroupMessages(
          event.groupId,
          page: 1,
          forceRefresh: true,
        );
        emit(GroupChatMessagesLoaded(messages: messages));
      } catch (e) {
        await refreshGroupMessages(
          event.groupId,
          page: 1,
          forceRefresh: true,
        );
        emit(GroupChatMessagesLoaded(messages: messages, error: e));
      }
    });

    // 发送系统消息
    on<GroupChatSendSystemEvent>((event, emit) async {
      try {
        final resp = await APIServer().chatGroupSendSystemMessage(
          event.groupId,
          messageType: event.type.getTypeText(),
          message: event.message,
        );

        Logger.instance.d(resp.toJson());
      } finally {
        await refreshGroupMessages(
          event.groupId,
          page: 1,
          forceRefresh: true,
        );
        emit(GroupChatMessagesLoaded(messages: messages));
      }
    });

    // 更新聊天组消息状态
    on<GroupChatUpdateMessageStatusEvent>((event, emit) async {
      final waitMessageIds = messages
          .where((msg) => msg.status == groupMessageStatusWaiting)
          .map((msg) => msg.id)
          .toList();

      if (waitMessageIds.isEmpty) {
        return;
      }

      final resp = await APIServer()
          .chatGroupMessageStatus(event.groupId, waitMessageIds);
      final newMessageStatusMap = <int, GroupMessage>{};
      for (var msg in resp) {
        newMessageStatusMap[msg.id] = msg;
      }

      for (var i = 0; i < messages.length; i++) {
        final msg = messages[i];
        if (newMessageStatusMap.containsKey(msg.id)) {
          messages[i] = newMessageStatusMap[msg.id]!;
        }
      }

      emit(GroupChatMessagesLoaded(messages: messages));
    });

    // 清空聊天组消息
    on<GroupChatDeleteAllEvent>((event, emit) async {
      await APIServer().chatGroupDeleteAllMessages(event.groupId);
      messages.clear();
      emit(GroupChatMessagesLoaded(messages: messages));
    });

    // 删除聊天组消息
    on<GroupChatDeleteEvent>((event, emit) async {
      await APIServer().chatGroupDeleteMessage(event.groupId, event.messageId);
      messages.removeWhere((msg) => msg.id == event.messageId);
      emit(GroupChatMessagesLoaded(messages: messages));
    });
  }

  refreshGroupMessages(
    int groupId, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final data = await APIServer()
        .chatGroupMessages(groupId, page: page, cache: !forceRefresh);
    messages = data.data.reversed.toList();

    if (page == 1) {
      Cache()
          .setString(key: 'group:speed:$groupId', value: jsonEncode(messages));
    }
  }
}
