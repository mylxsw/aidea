part of 'room_bloc.dart';

@immutable
abstract class RoomEvent {}

class RoomsLoadEvent extends RoomEvent {
  final bool forceRefresh;

  RoomsLoadEvent({this.forceRefresh = false});
}

class RoomCreateEvent extends RoomEvent {
  final String name;
  final String model;
  final String? prompt;
  final int? avatarId;
  final String? avatarUrl;
  final int? maxContext;
  final String? initMessage;

  RoomCreateEvent(
    this.name,
    this.model,
    this.prompt, {
    this.avatarId,
    this.avatarUrl,
    this.maxContext,
    this.initMessage,
  });
}

class RoomDeleteEvent extends RoomEvent {
  final int roomId;

  RoomDeleteEvent(this.roomId);
}

class RoomLoadEvent extends RoomEvent {
  final int roomId;
  final int? chatHistoryId;
  final bool cascading;
  RoomLoadEvent(this.roomId, {this.chatHistoryId, required this.cascading});
}

class RoomUpdateEvent extends RoomEvent {
  final int roomId;

  final String? name;
  final String? model;
  final String? prompt;
  final int? avatarId;
  final String? avatarUrl;
  final int? maxContext;
  final String? initMessage;

  RoomUpdateEvent(
    this.roomId, {
    this.name,
    this.model,
    this.prompt,
    this.avatarId,
    this.avatarUrl,
    this.maxContext,
    this.initMessage,
  });
}

class GalleryRoomCopyEvent extends RoomEvent {
  final List<int> ids;

  GalleryRoomCopyEvent(this.ids);
}

class RoomGalleriesLoadEvent extends RoomEvent {
  RoomGalleriesLoadEvent();
}
