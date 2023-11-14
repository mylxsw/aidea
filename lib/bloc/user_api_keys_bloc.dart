import 'package:askaide/repo/api/keys.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_api_keys_event.dart';
part 'user_api_keys_state.dart';

class UserApiKeysBloc extends Bloc<UserApiKeysEvent, UserApiKeysState> {
  UserApiKeysBloc() : super(UserApiKeysInitial()) {
    // 加载用户 API Key 列表
    on<UserApiKeysLoad>((event, emit) async {
      final keys = await APIServer().userAPIKeys();
      emit(UserApiKeysLoaded(keys: keys));
    });

    // 加载用户 API Key
    on<UserApiKeyLoad>((event, emit) async {
      final key = await APIServer().userAPIKeyDetail(id: event.id);
      emit(UserApiKeyLoaded(key: key));
    });

    // 创建用户 API Key
    on<UserApiKeyCreate>((event, emit) async {
      final key = await APIServer().createAPIKey(name: event.name);
      emit(UserApiKeyCreated(key: key));

      final keys = await APIServer().userAPIKeys();
      emit(UserApiKeysLoaded(keys: keys));
    });

    // 删除用户 API Key
    on<UserApiKeyDelete>((event, emit) async {
      await APIServer().deleteAPIKey(id: event.id);
      final keys = await APIServer().userAPIKeys();
      emit(UserApiKeysLoaded(keys: keys));
    });
  }
}
