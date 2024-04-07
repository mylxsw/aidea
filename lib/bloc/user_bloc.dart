import 'package:askaide/repo/api/admin/users.dart';
import 'package:askaide/repo/api/page.dart';
import 'package:askaide/repo/api/quota.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    // 加载指定用户信息
    on<UserLoadEvent>((event, emit) async {
      final user = await APIServer().adminUser(id: event.userId);
      emit(UserLoaded(user));
    });

    // 加载用户列表
    on<UserListLoadEvent>((event, emit) async {
      final users = await APIServer().adminUsers(
        page: event.page,
        perPage: event.perPage,
        keyword: event.keyword,
      );
      emit(UsersLoaded(users));
    });

    // 加载用户配额
    on<UserQuotaLoadEvent>((event, emit) async {
      final quota = await APIServer().adminUserQuota(userId: event.userId);
      emit(UserQuotaLoaded(quota));
    });
  }
}
