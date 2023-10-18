import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/group.dart';
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
      await refreshGroupMessages(
        event.groupId,
        page: event.page,
        perPage: event.perPage,
      );

      emit(GroupChatMessagesLoaded(messages: messages));
    });

    // 发送聊天组消息
    on<GroupChatSendEvent>((event, emit) async {
      final List<GroupChatSendRequestMessage> requestMessages = [
        GroupChatSendRequestMessage(role: "user", content: event.message)
      ];
      final resp = await APIServer().chatGroupSendMessage(
        event.groupId,
        GroupChatSendRequest(
            messages: requestMessages, memberIds: event.members),
      );

      await refreshGroupMessages(event.groupId, page: 1, perPage: 100);
      emit(GroupChatMessagesLoaded(messages: messages));
    });
  }

  refreshGroupMessages(int groupId, {int page = 1, int perPage = 100}) async {
    final data = await APIServer().chatGroupMessages(
      groupId,
      page: page,
      perPage: perPage,
    );

    messages = data.data.reversed.toList();
  }
}
