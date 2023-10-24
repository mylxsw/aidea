part of 'group_chat_bloc.dart';

@immutable
sealed class GroupChatState {}

final class GroupChatInitial extends GroupChatState {}

class GroupChatLoaded extends GroupChatState {
  final ChatGroup group;
  final Map<String, MessageState> states;
  final List<int>? defaultChatMembers;

  GroupChatLoaded({
    required this.group,
    required this.states,
    this.defaultChatMembers,
  });
}

class GroupDefaultMemberSelected extends GroupChatState {
  final List<int> members;

  GroupDefaultMemberSelected(this.members);
}

class GroupChatMessagesLoaded extends GroupChatState {
  final List<GroupMessage> messages;
  final Object? _error;

  get error => _error;

  bool get hasWaitTasks =>
      messages.any((element) => element.status == groupMessageStatusWaiting);

  GroupChatMessagesLoaded({
    required this.messages,
    Object? error,
  }) : _error = error;
}
