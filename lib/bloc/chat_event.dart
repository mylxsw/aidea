part of 'chat_message_bloc.dart';

@immutable
abstract class ChatMessageEvent {}

class ChatMessageReceivedEvent extends ChatMessageEvent {
  final Message message;

  ChatMessageReceivedEvent(this.message);
}

class ChatMessageSendEvent extends ChatMessageEvent {
  final Message message;
  final int? index;
  final bool isResent;

  ChatMessageSendEvent(this.message, {this.index, this.isResent = false});
}

class ChatMessageGetRecentEvent extends ChatMessageEvent {
  final int? chatHistoryId;

  ChatMessageGetRecentEvent({this.chatHistoryId});
}

class ChatMessageClearAllEvent extends ChatMessageEvent {}

class ChatMessageBreakContextEvent extends ChatMessageEvent {}

class ChatMessageDeleteEvent extends ChatMessageEvent {
  final List<int> ids;
  final int? chatHistoryId;
  ChatMessageDeleteEvent(this.ids, {this.chatHistoryId});
}
