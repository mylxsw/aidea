part of 'account_bloc.dart';

@immutable
abstract class AccountEvent {}

class AccountLoadEvent extends AccountEvent {
  final bool cache;

  AccountLoadEvent({this.cache = true});
}

class AccountSignOutEvent extends AccountEvent {}

class AccountUpdateEvent extends AccountEvent {
  final String? realname;
  final String? avatarURL;

  AccountUpdateEvent({this.realname, this.avatarURL});
}
