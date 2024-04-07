part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

class UserLoadEvent extends UserEvent {
  final int userId;

  UserLoadEvent(this.userId);
}

class UserListLoadEvent extends UserEvent {
  final int page;
  final int perPage;
  final String? keyword;

  UserListLoadEvent({
    this.page = 1,
    this.perPage = 20,
    this.keyword,
  });
}

class UserQuotaLoadEvent extends UserEvent {
  final int userId;

  UserQuotaLoadEvent(this.userId);
}
