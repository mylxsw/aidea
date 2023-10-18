part of 'group_chat_bloc.dart';

@immutable
sealed class GroupChatEvent {}

class GroupChatLoadEvent extends GroupChatEvent {
  final int groupId;

  GroupChatLoadEvent(this.groupId);
}

class GroupChatMessagesLoadEvent extends GroupChatEvent {
  final int groupId;
  final int page;
  final int perPage;

  GroupChatMessagesLoadEvent(this.groupId, {this.page = 1, this.perPage = 100});
}

class GroupChatSendEvent extends GroupChatEvent {
  final int groupId;
  final String message;
  final List<int> members;

  GroupChatSendEvent(this.groupId, this.message, this.members);
}
