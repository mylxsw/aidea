part of 'notify_bloc.dart';

@immutable
abstract class NotifyEvent {}

class NotifyFiredEvent extends NotifyEvent {
  final String title;
  final String body;
  final String type;

  NotifyFiredEvent(this.title, this.body, this.type);
}

class NotifyResetEvent extends NotifyEvent {}
