part of 'group_chat_bloc.dart';

@immutable
sealed class GroupChatEvent {}

class GroupChatLoadEvent extends GroupChatEvent {
  final int groupId;
  final bool forceUpdate;

  GroupChatLoadEvent(this.groupId, {this.forceUpdate = false});
}

class GroupChatMessagesLoadEvent extends GroupChatEvent {
  final int groupId;
  final int page;
  final bool isInitRequest;

  GroupChatMessagesLoadEvent(
    this.groupId, {
    this.page = 1,
    this.isInitRequest = false,
  });
}

class GroupChatSendEvent extends GroupChatEvent {
  final int groupId;
  final String message;
  final List<int> members;

  GroupChatSendEvent(this.groupId, this.message, this.members);
}

class GroupChatUpdateMessageStatusEvent extends GroupChatEvent {
  final int groupId;

  GroupChatUpdateMessageStatusEvent(this.groupId);
}

class GroupChatSendSystemEvent extends GroupChatEvent {
  final int groupId;
  final String? message;
  final MessageType type;

  GroupChatSendSystemEvent(this.groupId, this.type, {this.message});
}

class GroupChatDeleteAllEvent extends GroupChatEvent {
  final int groupId;

  GroupChatDeleteAllEvent(this.groupId);
}

class GroupChatDeleteEvent extends GroupChatEvent {
  final int groupId;
  final int messageId;

  GroupChatDeleteEvent(this.groupId, this.messageId);
}
