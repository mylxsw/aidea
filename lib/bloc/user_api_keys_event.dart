part of 'user_api_keys_bloc.dart';

@immutable
sealed class UserApiKeysEvent {}

class UserApiKeysLoad extends UserApiKeysEvent {}

class UserApiKeyLoad extends UserApiKeysEvent {
  final int id;

  UserApiKeyLoad(this.id);
}

class UserApiKeyCreate extends UserApiKeysEvent {
  final String name;

  UserApiKeyCreate(this.name);
}

class UserApiKeyDelete extends UserApiKeysEvent {
  final int id;

  UserApiKeyDelete(this.id);
}
