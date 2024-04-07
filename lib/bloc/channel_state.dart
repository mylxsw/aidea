part of 'channel_bloc.dart';

@immutable
sealed class ChannelState {}

final class ChannelInitial extends ChannelState {}

class ChannelsLoaded extends ChannelState {
  final List<AdminChannel> channels;

  ChannelsLoaded(this.channels);
}

class ChannelLoaded extends ChannelState {
  final AdminChannel channel;

  ChannelLoaded(this.channel);
}

class ChannelOperationResult extends ChannelState {
  final bool success;
  final String message;

  ChannelOperationResult(this.success, this.message);
}
