import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/repo/api/room_gallery.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/group.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/model/room.dart';

import 'package:askaide/bloc/bloc_manager.dart';
import 'package:askaide/repo/chat_message_repo.dart';
import 'package:flutter/material.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends BlocExt<RoomEvent, RoomState> {
  final ChatMessageRepository chatMsgRepo;
  final MessageStateManager stateManager;

  RoomBloc({
    required this.chatMsgRepo,
    required this.stateManager,
  }) : super(RoomInitial()) {
    // 加载指定聊天室信息
    on<RoomLoadEvent>((event, emit) async {
      try {
        if (event.roomId == 1) {
          // 加快首屏加载速度，避免加载中状态
          emit(RoomLoaded(
            Room(
              '',
              'chat',
              id: event.roomId,
            ),
            const <String, MessageState>{},
            cascading: false,
          ));
        }

        if (Ability().isUserLogon()) {
          final room = await APIServer().room(roomId: event.roomId);
          if (event.chatHistoryId != null && event.chatHistoryId! > 0) {
            final chatHistory =
                await chatMsgRepo.getChatHistory(event.chatHistoryId!);
            if (chatHistory != null && chatHistory.model != null) {
              room.model = chatHistory.model!;
            }
          }
          emit(RoomLoaded(
            Room(
              room.name,
              'chat',
              description: room.description,
              id: room.id,
              userId: room.userId,
              createdAt: room.createdAt,
              lastActiveTime: room.lastActiveTime,
              systemPrompt: room.systemPrompt,
              priority: room.priority ?? 0,
              model: room.model.startsWith('v2@')
                  ? room.model
                  : '${room.vendor}:${room.model}',
              initMessage: room.initMessage,
              maxContext: room.maxContext,
              avatarId: room.avatarId,
              avatarUrl: room.avatarUrl,
              roomType: room.roomType,
            ),
            const <String, MessageState>{},
            cascading: false,
          ));

          final states = await stateManager.loadRoomStates(event.roomId);
          emit(RoomLoaded(
            Room(
              room.name,
              'chat',
              description: room.description,
              id: room.id,
              userId: room.userId,
              createdAt: room.createdAt,
              lastActiveTime: room.lastActiveTime,
              systemPrompt: room.systemPrompt,
              priority: room.priority ?? 0,
              model: room.model.startsWith('v2@')
                  ? room.model
                  : '${room.vendor}:${room.model}',
              initMessage: room.initMessage,
              maxContext: room.maxContext,
              avatarId: room.avatarId,
              avatarUrl: room.avatarUrl,
              roomType: room.roomType,
            ),
            states,
            examples: await APIServer().example(
              room.model.startsWith('v2@')
                  ? room.model
                  : '${room.vendor}:${room.model}',
            ),
            cascading: event.cascading,
          ));
          return;
        }

        final room = await chatMsgRepo.room(event.roomId);
        if (room != null) {
          final states = await stateManager.loadRoomStates(event.roomId);
          emit(RoomLoaded(
            room,
            states,
            examples: await APIServer().example(room.model),
            cascading: event.cascading,
          ));
        }
      } catch (e) {
        emit(RoomLoaded(
          Room('-', '-'),
          const {},
          error: e,
          cascading: event.cascading,
        ));
      }
    });

    // 加载聊天室列表
    on<RoomsLoadEvent>((event, emit) async {
      if (!event.forceRefresh) {
        emit(RoomsLoading());
      }
      emit(await createRoomsLoadedState(cache: !event.forceRefresh));
    });

    // 创建聊天室
    on<RoomCreateEvent>((event, emit) async {
      emit(RoomsLoading());

      try {
        int id = 0;
        if (Ability().isUserLogon()) {
          final segs = event.model.split(':');

          id = await APIServer().createRoom(
            name: event.name,
            vendor: event.model.startsWith('v2@')
                ? ''
                : (segs.length > 1 ? segs.first : ''),
            model: event.model.startsWith('v2@')
                ? event.model
                : (segs.length > 1 ? segs.last : event.model),
            systemPrompt: event.prompt,
            avatarId: event.avatarId,
            avatarUrl: event.avatarUrl,
            maxContext: event.maxContext,
            initMessage: event.initMessage,
          );
        } else {
          final room = await chatMsgRepo.createRoom(
            name: event.name,
            category: 'chat',
            model: event.model,
            systemPrompt: event.prompt,
            userId: APIServer().localUserID(),
            maxContext: event.maxContext,
          );

          id = room.id!;
        }

        emit(RoomOperationResult(true, redirect: '/room/$id/chat'));
        emit(await createRoomsLoadedState(cache: false));
      } catch (e) {
        emit(RoomsLoaded(const [], error: e.toString()));
      }
    });

    // 删除聊天室
    on<RoomDeleteEvent>((event, emit) async {
      emit(RoomsLoading());

      try {
        if (Ability().isUserLogon()) {
          await APIServer().deleteRoom(roomId: event.roomId);
        } else {
          var room = await chatMsgRepo.room(event.roomId);
          if (room == null || room.category == 'system') {
            return;
          }

          await chatMsgRepo.deleteRoom(event.roomId);
        }

        emit(await createRoomsLoadedState(cache: false));
      } catch (e) {
        emit(RoomsLoaded(const [], error: e.toString()));
      }
    });

    // 更新聊天室信息
    on<RoomUpdateEvent>((event, emit) async {
      if (Ability().isUserLogon()) {
        final room = await APIServer().updateRoom(
          roomId: event.roomId,
          name: event.name!,
          model: event.model!.startsWith('v2@')
              ? event.model!
              : event.model!.split(':').last,
          vendor: event.model!.startsWith('v2@')
              ? ''
              : event.model!.split(':').first,
          systemPrompt: event.prompt!,
          avatarId: event.avatarId,
          avatarUrl: event.avatarUrl,
          maxContext: event.maxContext,
          initMessage: event.initMessage,
        );

        final states = await stateManager.loadRoomStates(event.roomId);
        emit(
          RoomLoaded(
            Room(
              room.name,
              'chat',
              description: room.description,
              id: room.id,
              userId: room.userId,
              createdAt: room.createdAt,
              lastActiveTime: room.lastActiveTime,
              systemPrompt: room.systemPrompt,
              priority: room.priority ?? 0,
              model: room.model.startsWith('v2@')
                  ? room.model
                  : '${room.vendor}:${room.model}',
              avatarId: room.avatarId,
              avatarUrl: room.avatarUrl,
              initMessage: room.initMessage,
              roomType: room.roomType,
            ),
            states,
            examples: await APIServer().example(room.model),
            cascading: false,
          ),
        );
      } else {
        final room = await chatMsgRepo.room(event.roomId);

        if (room != null) {
          if (event.name != null && event.name != '') {
            room.name = event.name!;
          }

          if (event.model != null && event.model != '') {
            room.model = event.model!;
          }

          if (event.prompt != null && event.prompt != '') {
            room.systemPrompt = event.prompt!;
          }

          if (event.maxContext != null) {
            room.maxContext = event.maxContext!;
          }

          await chatMsgRepo.updateRoom(room);
          final states = await stateManager.loadRoomStates(event.roomId);
          emit(RoomLoaded(
            room,
            states,
            examples: await APIServer().examples(),
            cascading: false,
          ));
        }
      }
    });

    on<GalleryRoomCopyEvent>((event, emit) async {
      if (event.ids.isEmpty) {
        return;
      }

      try {
        await APIServer().copyRoomGallery(ids: event.ids);
        emit(await createRoomsLoadedState(cache: false));
      } catch (e) {
        emit(RoomCreateError(e));
      }
    });

    on<RoomGalleriesLoadEvent>((event, emit) async {
      try {
        final resp = await APIServer().roomGalleries();
        emit(RoomGalleriesLoaded(resp.galleries, tags: resp.tags));
      } catch (e) {
        emit(RoomGalleriesLoaded(const [], error: e));
      }
    });

    // 创建群聊聊天室
    on<GroupRoomCreateEvent>((event, emit) async {
      emit(RoomsLoading());

      try {
        await APIServer().createGroupRoom(
          name: event.name,
          avatarUrl: event.avatarUrl,
          members: event.members,
        );

        emit(GroupRoomUpdateResultState(true));
        emit(await createRoomsLoadedState(cache: false));
      } catch (e) {
        emit(GroupRoomUpdateResultState(false, error: e));
        emit(RoomsLoaded(const [], error: e.toString()));
      }
    });

    // 群聊聊天室更新
    on<GroupRoomUpdateEvent>((event, emit) async {
      emit(RoomsLoading());

      try {
        await APIServer().updateGroupRoom(
          groupId: event.groupId,
          name: event.name,
          avatarUrl: event.avatarUrl,
          members: event.members,
        );

        emit(GroupRoomUpdateResultState(true));
      } catch (e) {
        emit(GroupRoomUpdateResultState(false, error: e));
      }
    });
  }

  Future<RoomsLoaded> createRoomsLoadedState({bool cache = true}) async {
    try {
      if (Ability().isUserLogon()) {
        final resp = await APIServer().rooms(cache: cache);
        return RoomsLoaded(
          resp.rooms
              .map((room) => Room(
                    room.name,
                    'chat',
                    description: room.description,
                    id: room.id,
                    userId: room.userId,
                    createdAt: room.createdAt,
                    lastActiveTime: room.lastActiveTime,
                    systemPrompt: room.systemPrompt,
                    priority: room.priority ?? 0,
                    model: room.model.startsWith('v2@')
                        ? room.model
                        : '${room.vendor}:${room.model}',
                    avatarId: room.avatarId,
                    avatarUrl: room.avatarUrl,
                    roomType: room.roomType,
                    members: room.members,
                  ))
              .toList(),
          suggests: resp.suggests ?? [],
        );
      } else {
        final rooms = await chatMsgRepo.rooms(
          userId: APIServer().localUserID(),
        );
        rooms.removeWhere((element) =>
            element.id == chatAnywhereRoomId && element.category == 'system');
        return RoomsLoaded(rooms);
      }
    } catch (e) {
      return RoomsLoaded(const [], error: e);
    }
  }
}
