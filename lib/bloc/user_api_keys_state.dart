part of 'user_api_keys_bloc.dart';

@immutable
sealed class UserApiKeysState {}

final class UserApiKeysInitial extends UserApiKeysState {}

class UserApiKeysLoaded extends UserApiKeysState {
  final List<UserAPIKey> keys;

  UserApiKeysLoaded({required this.keys});
}

class UserApiKeyLoaded extends UserApiKeysState {
  final UserAPIKey key;

  UserApiKeyLoaded({required this.key});
}

class UserApiKeyCreated extends UserApiKeysState {
  final String key;

  UserApiKeyCreated({required this.key});
}
