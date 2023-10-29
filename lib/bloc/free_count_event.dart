part of 'free_count_bloc.dart';

@immutable
sealed class FreeCountEvent {}

class FreeCountReloadEvent extends FreeCountEvent {
  final String model;
  FreeCountReloadEvent({required this.model});
}

class FreeCountReloadAllEvent extends FreeCountEvent {
  final bool checkSigninStatus;

  FreeCountReloadAllEvent({this.checkSigninStatus = false});
}
