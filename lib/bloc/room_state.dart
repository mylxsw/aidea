part of 'room_bloc.dart';

@immutable
abstract class RoomState {}

class RoomInitial extends RoomState {}

class RoomsLoading extends RoomState {}

class RoomsLoaded extends RoomState {
  final List<Room> rooms;
  final List<RoomGallery> suggests;
  final Object? error;

  RoomsLoaded(this.rooms, {this.error, this.suggests = const []});
}

class RoomLoaded extends RoomState {
  final Room room;
  final List<ChatExample>? examples;
  final Object? error;
  final Map<String, MessageState> states;
  final bool cascading;

  RoomLoaded(
    this.room,
    this.states, {
    this.error,
    this.examples,
    required this.cascading,
  }) {
    if (examples != null) {
      examples!.shuffle();
    }
  }
}

class RoomCreateError extends RoomState {
  final Object error;

  RoomCreateError(this.error);
}

class RoomGalleriesLoaded extends RoomState {
  final List<RoomGallery> galleries;
  final List<String> tags;
  final Object? error;

  RoomGalleriesLoaded(this.galleries, {this.error, this.tags = const []});
}

class GroupRoomUpdateResultState extends RoomState {
  final bool success;
  final Object? error;

  GroupRoomUpdateResultState(this.success, {this.error});
}

class RoomOperationResult extends RoomState {
  final bool success;
  final Object? error;
  final String? redirect;

  RoomOperationResult(this.success, {this.error, this.redirect});
}
