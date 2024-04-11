import 'package:askaide/repo/api/page.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'admin_room_event.dart';
part 'admin_room_state.dart';

class AdminRoomBloc extends Bloc<AdminRoomEvent, AdminRoomState> {
  AdminRoomBloc() : super(AdminRoomInitial()) {
    on<AdminRoomsLoadEvent>((event, emit) async {
      final rooms = await APIServer().adminUserRooms(userId: event.userId);
      emit(AdminRoomsLoaded(rooms: rooms));
    });

    on<AdminRoomLoadEvent>((event, emit) async {
      final room = await APIServer().adminUserRoom(
        userId: event.userId,
        roomId: event.roomId,
      );
      emit(AdminRoomLoaded(room: room));
    });

    on<AdminRoomRecentlyMessagesLoadEvent>((event, emit) async {
      if (event.roomType == 4) {
        final messages = await APIServer().adminUserRoomGroupMessages(
            userId: event.userId, roomId: event.roomId);
        emit(AdminRoomRecentlyMessagesLoaded(
            messages: messages
                .map((e) => Message(
                      e.role == 'user' ? Role.sender : Role.receiver,
                      e.message,
                      type: MessageType.text,
                      ts: e.createdAt,
                      model: e.model,
                      quotaConsumed: e.quotaConsumed,
                      tokenConsumed: e.tokenConsumed,
                      refId: e.pid,
                      id: e.id,
                      serverId: e.id,
                    ))
                .toList()));
      } else {
        final messages = await APIServer().adminUserRoomMessages(
          userId: event.userId,
          roomId: event.roomId,
        );
        emit(AdminRoomRecentlyMessagesLoaded(
            messages: messages
                .map((e) => Message(
                      e.role == 1 ? Role.sender : Role.receiver,
                      e.message,
                      type: MessageType.text,
                      ts: e.createdAt,
                      model: e.model,
                      quotaConsumed: e.quotaConsumed,
                      tokenConsumed: e.tokenConsumed,
                      refId: e.pid,
                      id: e.id,
                      serverId: e.id,
                      userId: e.userId,
                      roomId: e.roomId,
                    ))
                .toList()));
      }
    });

    on<AdminRecentlyMessagesLoadEvent>((event, emit) async {
      final messages = await APIServer().adminRecentlyMessages(
        page: event.page,
        perPage: event.perPage,
        keyword: event.keyword,
      );
      emit(AdminRecentlyMessagesLoaded(PagedData(
        data: messages.data
            .map((e) => Message(
                  e.role == 1 ? Role.sender : Role.receiver,
                  e.message,
                  type: MessageType.text,
                  ts: e.createdAt,
                  model: e.model,
                  quotaConsumed: e.quotaConsumed,
                  tokenConsumed: e.tokenConsumed,
                  refId: e.pid,
                  id: e.id,
                  serverId: e.id,
                  userId: e.userId,
                  roomId: e.roomId,
                ))
            .toList(),
        page: messages.page,
        perPage: messages.perPage,
        total: messages.total,
        lastPage: messages.lastPage,
      )));
    });
  }
}
