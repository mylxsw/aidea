part of 'channel_bloc.dart';

@immutable
sealed class ChannelEvent {}

class ChannelsLoadEvent extends ChannelEvent {}

class ChannelLoadEvent extends ChannelEvent {
  final int channelId;

  ChannelLoadEvent(this.channelId);
}

class ChannelCreateEvent extends ChannelEvent {
  final AdminChannelAddReq req;

  ChannelCreateEvent(this.req);
}

class ChannelUpdateEvent extends ChannelEvent {
  final int channelId;
  final AdminChannelUpdateReq req;

  ChannelUpdateEvent(this.channelId, this.req);
}

class ChannelDeleteEvent extends ChannelEvent {
  final int channelId;

  ChannelDeleteEvent(this.channelId);
}
