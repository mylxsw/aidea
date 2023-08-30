part of 'notify_bloc.dart';

@immutable
abstract class NotifyState {}

class NotifyInitial extends NotifyState {}

class NotifyFired extends NotifyState {
  final String title;
  final String body;
  final String type;

  NotifyFired(this.title, this.body, this.type);
}
