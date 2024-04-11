part of 'admin_room_bloc.dart';

@immutable
sealed class AdminRoomEvent {}

class AdminRoomsLoadEvent extends AdminRoomEvent {
  final int userId;

  AdminRoomsLoadEvent({required this.userId});
}

class AdminRoomLoadEvent extends AdminRoomEvent {
  final int userId;
  final int roomId;

  AdminRoomLoadEvent({required this.roomId, required this.userId});
}

class AdminRoomRecentlyMessagesLoadEvent extends AdminRoomEvent {
  final int userId;
  final int roomId;
  final int roomType;

  AdminRoomRecentlyMessagesLoadEvent({
    required this.roomId,
    required this.userId,
    required this.roomType,
  });
}

class AdminRecentlyMessagesLoadEvent extends AdminRoomEvent {
  final int page;
  final int perPage;
  final String? keyword;

  AdminRecentlyMessagesLoadEvent({
    required this.page,
    required this.perPage,
    this.keyword,
  });
}
