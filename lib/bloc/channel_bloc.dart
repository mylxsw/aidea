import 'package:askaide/repo/api/admin/channels.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'channel_event.dart';
part 'channel_state.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  ChannelBloc() : super(ChannelInitial()) {
    /// 加载所有渠道
    on<ChannelsLoadEvent>((event, emit) async {
      final channels = await APIServer().adminChannels();
      emit(ChannelsLoaded(channels));
    });

    /// 加载单个渠道
    on<ChannelLoadEvent>((event, emit) async {
      final channel = await APIServer().adminChannel(id: event.channelId);
      emit(ChannelLoaded(channel));
    });

    /// 创建渠道
    on<ChannelCreateEvent>((event, emit) async {
      try {
        await APIServer().adminCreateChannel(event.req);
        emit(ChannelOperationResult(true, '创建成功'));
      } catch (e) {
        emit(ChannelOperationResult(false, e.toString()));
      }
    });

    /// 更新渠道
    on<ChannelUpdateEvent>((event, emit) async {
      try {
        await APIServer().adminUpdateChannel(
          id: event.channelId,
          req: event.req,
        );
        emit(ChannelOperationResult(true, '更新成功'));
      } catch (e) {
        emit(ChannelOperationResult(false, e.toString()));
      }
    });

    /// 删除渠道
    on<ChannelDeleteEvent>((event, emit) async {
      try {
        await APIServer().adminDeleteChannel(id: event.channelId);
        emit(ChannelOperationResult(true, '删除成功'));
      } catch (e) {
        emit(ChannelOperationResult(false, e.toString()));
      }
    });
  }
}
