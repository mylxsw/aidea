part of 'chat_chat_bloc.dart';

@immutable
abstract class ChatChatState {}

class ChatChatInitial extends ChatChatState {}

class ChatChatRecentHistoriesLoaded extends ChatChatState {
  final List<ChatHistory> histories;
  final List<ChatExample>? examples;

  ChatChatRecentHistoriesLoaded({this.histories = const [], this.examples});
}
