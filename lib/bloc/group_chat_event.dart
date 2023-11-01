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
  final int startId;
  final bool isInitRequest;

  GroupChatMessagesLoadEvent(
    this.groupId, {
    this.startId = 0,
    this.isInitRequest = false,
  });
}

class GroupChatSendEvent extends GroupChatEvent {
  final int groupId;
  final String message;
  final List<int> members;
  final int? index;
  final bool isResent;

  GroupChatSendEvent(this.groupId, this.message, this.members,
      {this.index, this.isResent = false});
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
