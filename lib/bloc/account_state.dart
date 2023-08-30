part of 'account_bloc.dart';

@immutable
abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final UserInfo? user;
  final Object? error;
  AccountLoaded(this.user, {this.error});
}

class AccountNeedSignIn extends AccountState {}
