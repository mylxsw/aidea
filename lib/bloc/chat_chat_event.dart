part of 'chat_chat_bloc.dart';

@immutable
abstract class ChatChatEvent {}

class ChatChatLoadRecentHistories extends ChatChatEvent {
  final int count;
  ChatChatLoadRecentHistories({this.count = 4});
}

class ChatChatNewChat extends ChatChatEvent {
  final String text;
  ChatChatNewChat(this.text);
}

class ChatChatDeleteHistory extends ChatChatEvent {
  final int chatId;

  ChatChatDeleteHistory(this.chatId);
}
