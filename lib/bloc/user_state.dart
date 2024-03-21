part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final AdminUser user;

  UserLoaded(this.user);
}

class UserOperationResult extends UserState {
  final bool success;
  final String? message;

  UserOperationResult(this.success, {this.message});
}

class UsersLoaded extends UserState {
  final PagedData<AdminUser> users;

  UsersLoaded(this.users);
}

class UserQuotaLoaded extends UserState {
  final QuotaResp quota;

  UserQuotaLoaded(this.quota);
}
