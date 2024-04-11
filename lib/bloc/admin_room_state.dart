part of 'admin_room_bloc.dart';

@immutable
sealed class AdminRoomState {}

final class AdminRoomInitial extends AdminRoomState {}

final class AdminRoomsLoaded extends AdminRoomState {
  final List<RoomInServer> rooms;

  AdminRoomsLoaded({required this.rooms});
}

final class AdminRoomLoaded extends AdminRoomState {
  final RoomInServer room;

  AdminRoomLoaded({required this.room});
}

final class AdminRoomRecentlyMessagesLoaded extends AdminRoomState {
  final List<Message> messages;

  AdminRoomRecentlyMessagesLoaded({required this.messages});
}

class AdminRoomOperationResult extends AdminRoomState {
  final bool success;
  final String message;

  AdminRoomOperationResult(this.success, this.message);
}

class AdminRecentlyMessagesLoaded extends AdminRoomState {
  final PagedData<Message> messages;

  AdminRecentlyMessagesLoaded(this.messages);
}
