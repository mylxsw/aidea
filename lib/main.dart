import 'package:askaide/bloc/admin_payment_bloc.dart';
import 'package:askaide/bloc/admin_room_bloc.dart';
import 'package:askaide/bloc/channel_bloc.dart';
import 'package:askaide/bloc/model_bloc.dart';
import 'package:askaide/bloc/user_bloc.dart';
import 'package:askaide/helper/path.dart';
import 'package:askaide/page/admin/channels.dart';
import 'package:askaide/page/admin/channels_add.dart';
import 'package:askaide/page/admin/channels_edit.dart';
import 'package:askaide/page/admin/dashboard.dart';
import 'package:askaide/page/admin/messages.dart';
import 'package:askaide/page/admin/models.dart';
import 'package:askaide/page/admin/models_add.dart';
import 'package:askaide/page/admin/models_edit.dart';
import 'package:askaide/page/admin/payments.dart';
import 'package:askaide/page/admin/recently_messages.dart';
import 'package:askaide/page/admin/rooms.dart';
import 'package:askaide/page/admin/user.dart';
import 'package:askaide/page/admin/users.dart';
import 'package:askaide/page/balance/web_payment_proxy.dart';
import 'package:askaide/page/balance/web_payment_result.dart';
import 'package:askaide/page/creative_island/draw/artistic_wordart.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:path/path.dart';

import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/bloc/background_image_bloc.dart';
import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/bloc/gallery_bloc.dart';
import 'package:askaide/bloc/group_chat_bloc.dart';
import 'package:askaide/bloc/payment_bloc.dart';
import 'package:askaide/bloc/user_api_keys_bloc.dart';
import 'package:askaide/bloc/version_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/helper/model_resolver.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/data/migrate.dart';
import 'package:askaide/page/balance/quota_usage_details.dart';
import 'package:askaide/page/creative_island/draw/artistic_qr.dart';
import 'package:askaide/page/setting/account_security.dart';
import 'package:askaide/page/app_scaffold.dart';
import 'package:askaide/page/lab/avatar_selector.dart';
import 'package:askaide/page/setting/article.dart';
import 'package:askaide/page/setting/background_selector.dart';
import 'package:askaide/page/setting/bind_phone_page.dart';
import 'package:askaide/page/setting/change_password.dart';
import 'package:askaide/page/chat/home_chat.dart';
import 'package:askaide/page/chat/home.dart';
import 'package:askaide/page/chat/home_chat_history.dart';
import 'package:askaide/page/chat/room_create.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/transition_resolver.dart';
import 'package:askaide/page/creative_island/my_creation.dart';
import 'package:askaide/page/creative_island/my_creation_item.dart';
import 'package:askaide/page/setting/custom_home_models.dart';
import 'package:askaide/page/balance/free_statistics.dart';
import 'package:askaide/page/chat/group/chat.dart';
import 'package:askaide/page/chat/group/create.dart';
import 'package:askaide/page/chat/group/edit.dart';
import 'package:askaide/page/lab/creative_models.dart';
import 'package:askaide/page/setting/destroy_account.dart';
import 'package:askaide/page/setting/diagnosis.dart';
import 'package:askaide/page/creative_island/draw/draw_list.dart';
import 'package:askaide/page/creative_island/draw/draw_create.dart';
import 'package:askaide/page/creative_island/draw/image_edit_direct.dart';
import 'package:askaide/page/lab/draw_board.dart';
import 'package:askaide/page/creative_island/gallery/gallery.dart';
import 'package:askaide/page/creative_island/gallery/gallery_item.dart';
import 'package:askaide/page/setting/notification.dart';
import 'package:askaide/page/setting/openai_setting.dart';
import 'package:askaide/page/balance/payment.dart';
import 'package:askaide/page/lab/prompt.dart';
import 'package:askaide/page/balance/quota_usage_statistics.dart';
import 'package:askaide/page/auth/signin_or_signup.dart';
import 'package:askaide/page/auth/signin_screen.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/balance/payment_history.dart';
import 'package:askaide/page/setting/retrieve_password_screen.dart';
import 'package:askaide/page/auth/signup_screen.dart';
import 'package:askaide/page/lab/user_center.dart';
import 'package:askaide/page/setting/user_api_keys.dart';
import 'package:askaide/repo/api/info.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/cache_repo.dart';
import 'package:askaide/repo/creative_island_repo.dart';
import 'package:askaide/repo/data/cache_data.dart';
import 'package:askaide/repo/data/chat_history.dart';
import 'package:askaide/repo/data/creative_island_data.dart';
import 'package:askaide/repo/deepai_repo.dart';
import 'package:askaide/repo/stabilityai_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluwx/fluwx.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:askaide/bloc/bloc_manager.dart';
import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/bloc/notify_bloc.dart';
import 'package:askaide/page/chat/room_edit.dart';
import 'package:askaide/page/chat/room_chat.dart';
import 'package:askaide/page/chat/rooms.dart';
import 'package:askaide/page/setting/setting_screen.dart';
import 'package:askaide/repo/data/chat_message_data.dart';
import 'package:askaide/repo/chat_message_repo.dart';
import 'package:askaide/repo/data/room_data.dart';
import 'package:askaide/repo/openai_repo.dart';
import 'package:askaide/repo/data/settings_data.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'page/component/theme/theme.dart';
import 'package:sizer/sizer.dart';
import 'package:askaide/helper/http.dart' as httpx;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:media_kit/media_kit.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  httpx.HttpClient.init();

  // 初始化路径，获取到系统相关的文档、缓存目录
  await PathHelper().init();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.library == 'rendering library' ||
        details.library == 'image resource service') {
      return;
    }

    Logger.instance.e(
      details.summary,
      error: details.exception,
      stackTrace: details.stack,
    );
    print(details.stack);
  };

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    if (PlatformTool.isWindows() ||
        PlatformTool.isLinux() ||
        PlatformTool.isMacOS()) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      var path = absolute(join(PathHelper().getHomePath, 'databases'));
      databaseFactory.setDatabasesPath(path);
    }
  }

  // 数据库连接
  final db = await databaseFactory.openDatabase(
    'system.db',
    options: OpenDatabaseOptions(
      version: databaseVersion,
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          await migrate(db, oldVersion, newVersion);
        } catch (e) {
          Logger.instance.e('数据库升级失败', error: e);
        }
      },
      onCreate: initDatabase,
      onOpen: (db) {
        Logger.instance.i('数据库存储路径：${db.path}');
      },
    ),
  );

  // 加载配置
  final settingProvider = SettingDataProvider(db);
  await settingProvider.loadSettings();

  // 创建数据仓库
  final settingRepo = SettingRepository(settingProvider);
  final openAIRepo = OpenAIRepository(settingProvider);
  final deepAIRepo = DeepAIRepository(settingProvider);
  final stabilityAIRepo = StabilityAIRepository(settingProvider);
  final cacheRepo = CacheRepository(CacheDataProvider(db));

  final chatMsgRepo = ChatMessageRepository(
    RoomDataProvider(db),
    ChatMessageDataProvider(db),
    ChatHistoryProvider(db),
  );

  final creativeIslandRepo =
      CreativeIslandRepository(CreativeIslandDataProvider(db));

  // 聊天状态加载器
  final stateManager = MessageStateManager(cacheRepo);

  // 初始化聊天实现解析器
  ModelResolver.instance.init(
    openAIRepo: openAIRepo,
    deepAIRepo: deepAIRepo,
    stabilityAIRepo: stabilityAIRepo,
  );

  APIServer().init(settingRepo);
  ModelAggregate.init(settingRepo);
  Cache().init(settingRepo, cacheRepo);

  // 从服务器获取客户端支持的能力清单
  try {
    final capabilities = await APIServer().capabilities(cache: false);
    Ability().init(settingRepo, capabilities);
  } catch (e) {
    Logger.instance.e('获取客户端能力清单失败', error: e);
    Ability().init(
      settingRepo,
      Capabilities(
        applePayEnabled: true,
        otherPayEnabled: true,
        translateEnabled: true,
        mailEnabled: true,
        openaiEnabled: true,
        homeModels: [],
        homeRoute: '/chat-chat',
        showHomeModelDescription: true,
        supportWebsocket: false,
      ),
    );
  }

  // 初始化聊天室 Bloc 管理器
  final m = ChatBlocManager();
  m.init((roomId, {chatHistoryId}) {
    return ChatMessageBloc(
      roomId,
      chatHistoryId: chatHistoryId,
      chatMsgRepo: chatMsgRepo,
      settingRepo: settingRepo,
    );
  });

  runApp(MyApp(
    settingRepo: settingRepo,
    chatMsgRepo: chatMsgRepo,
    openAIRepo: openAIRepo,
    cacheRepo: cacheRepo,
    creativeIslandRepo: creativeIslandRepo,
    messageStateManager: stateManager,
  ));
}

class MyApp extends StatefulWidget {
  // 页面路由
  late final GoRouter _router;

  // Bloc
  late final RoomBloc chatRoomBloc;
  late final GalleryBloc galleryBloc;
  late final AccountBloc accountBloc;
  late final VersionBloc versionBloc;
  late final FreeCountBloc freeCountBloc;

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalization localization = FlutterLocalization.instance;
  final MessageStateManager messageStateManager;

  MyApp({
    super.key,
    required this.settingRepo,
    required this.chatMsgRepo,
    required this.openAIRepo,
    required this.cacheRepo,
    required this.creativeIslandRepo,
    required this.messageStateManager,
  }) {
    chatRoomBloc =
        RoomBloc(chatMsgRepo: chatMsgRepo, stateManager: messageStateManager);
    accountBloc = AccountBloc(settingRepo);
    versionBloc = VersionBloc();
    galleryBloc = GalleryBloc();
    freeCountBloc = FreeCountBloc();

    var apiServerToken = settingRepo.get(settingAPIServerToken);
    var usingGuestMode = settingRepo.boolDefault(settingUsingGuestMode, false);

    final openAISelfHosted =
        settingRepo.boolDefault(settingOpenAISelfHosted, false);
    final deepAISelfHosted =
        settingRepo.boolDefault(settingDeepAISelfHosted, false);
    final stabilityAISelfHosted =
        settingRepo.boolDefault(settingStabilityAISelfHosted, false);

    final shouldLogin = (apiServerToken == null || apiServerToken == '') &&
        !usingGuestMode &&
        !openAISelfHosted &&
        !deepAISelfHosted &&
        !stabilityAISelfHosted;

    _router = GoRouter(
      initialLocation: shouldLogin ? '/login' : Ability().homeRoute,
      observers: [
        BotToastNavigatorObserver(),
      ],
      navigatorKey: _rootNavigatorKey,
      routes: [
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return AppScaffold(
              settingRepo: settingRepo,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/login',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: versionBloc),
                  ],
                  child: SignInScreen(
                    settings: settingRepo,
                    username: state.queryParameters['username'],
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/signin-or-signup',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: versionBloc),
                  ],
                  child: SigninOrSignupScreen(
                    settings: settingRepo,
                    username: state.queryParameters['username']!,
                    isSignup: state.queryParameters['is_signup'] == 'true',
                    signInMethod: state.queryParameters['sign_in_method']!,
                    wechatBindToken: state.queryParameters['wechat_bind_token'],
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/user/change-password',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                ChangePasswordScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              path: '/user/destroy',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                DestroyAccountScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              path: '/signup',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                SignupScreen(
                  settings: settingRepo,
                  username: state.queryParameters['username'],
                ),
              ),
            ),
            GoRoute(
              path: '/retrieve-password',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                RetrievePasswordScreen(
                  username: state.queryParameters['username'],
                  setting: settingRepo,
                ),
              ),
            ),
            GoRoute(
              name: 'chat_anywhere',
              path: '/chat-anywhere',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: ChatBlocManager().getBloc(
                        chatAnywhereRoomId,
                        chatHistoryId: int.tryParse(
                            state.queryParameters['chat_id'] ?? ''),
                      ),
                    ),
                    BlocProvider.value(value: chatRoomBloc),
                    BlocProvider(create: (context) => NotifyBloc()),
                    BlocProvider.value(value: freeCountBloc),
                  ],
                  child: HomeChatPage(
                    stateManager: messageStateManager,
                    setting: settingRepo,
                    chatId:
                        int.tryParse(state.queryParameters['chat_id'] ?? '0'),
                    initialMessage: state.queryParameters['init_message'],
                    model: state.queryParameters['model'] == ''
                        ? null
                        : state.queryParameters['model'],
                    title: state.queryParameters['title'] == ''
                        ? null
                        : state.queryParameters['title'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'chat_chat',
              path: '/chat-chat',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) => ChatChatBloc(chatMsgRepo)),
                    BlocProvider.value(value: freeCountBloc),
                  ],
                  child: HomePage(
                    setting: settingRepo,
                    showInitialDialog:
                        state.queryParameters['show_initial_dialog'] == 'true',
                    reward:
                        int.tryParse(state.queryParameters['reward'] ?? '0'),
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'chat_chat_history',
              path: '/chat-chat/history',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) => ChatChatBloc(chatMsgRepo)),
                  ],
                  child: HomeChatHistoryPage(
                    setting: settingRepo,
                    chatMessageRepo: chatMsgRepo,
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/lab/avatar-selector',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                const AvatarSelectorScreen(usage: AvatarUsage.room),
              ),
            ),
            GoRoute(
              path: '/lab/draw-board',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                const DrawboardScreen(),
              ),
            ),
            GoRoute(
              name: 'characters',
              path: '/',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [BlocProvider.value(value: chatRoomBloc)],
                  child: RoomsPage(setting: settingRepo),
                ),
              ),
            ),
            GoRoute(
              name: 'create-room',
              path: '/create-room',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [BlocProvider.value(value: chatRoomBloc)],
                  child: RoomCreatePage(setting: settingRepo),
                ),
              ),
            ),
            GoRoute(
              name: 'chat',
              path: '/room/:room_id/chat',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final roomId = int.parse(state.pathParameters['room_id']!);
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: ChatBlocManager().getBloc(roomId),
                      ),
                      BlocProvider.value(value: chatRoomBloc),
                      BlocProvider(create: (context) => NotifyBloc()),
                      BlocProvider.value(value: freeCountBloc),
                    ],
                    child: RoomChatPage(
                      roomId: roomId,
                      stateManager: messageStateManager,
                      setting: settingRepo,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'room_setting',
              path: '/room/:room_id/setting',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final roomId = int.parse(state.pathParameters['room_id']!);
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: chatRoomBloc),
                      BlocProvider.value(
                        value: ChatBlocManager().getBloc(roomId),
                      ),
                    ],
                    child: RoomEditPage(roomId: roomId, setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'account-security-setting',
              path: '/setting/account-security',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: accountBloc),
                  ],
                  child: AccountSecurityScreen(
                    settings: context.read<SettingRepository>(),
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'lab-user-center',
              path: '/lab/user-center',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: accountBloc),
                    BlocProvider(
                        create: (context) =>
                            CreativeIslandBloc(creativeIslandRepo)),
                  ],
                  child: UserCenterScreen(
                      settings: context.read<SettingRepository>()),
                ),
              ),
            ),
            GoRoute(
              name: 'setting',
              path: '/setting',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: accountBloc),
                  ],
                  child: SettingScreen(
                      settings: context.read<SettingRepository>()),
                ),
              ),
            ),
            GoRoute(
              name: 'setting-background-selector',
              path: '/setting/background-selector',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                BlocProvider(
                  create: (context) => BackgroundImageBloc(),
                  child: BackgroundSelectorScreen(setting: settingRepo),
                ),
              ),
            ),
            GoRoute(
              name: 'setting-openai-custom',
              path: '/setting/openai-custom',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                OpenAISettingScreen(
                  settings: settingRepo,
                  source: state.queryParameters['source'],
                ),
              ),
            ),
            GoRoute(
              name: 'creative-draw',
              path: '/creative-draw',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) =>
                            CreativeIslandBloc(creativeIslandRepo)),
                  ],
                  child: DrawListScreen(
                    setting: settingRepo,
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-upscale',
              path: '/creative-draw/create-upscale',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) =>
                            CreativeIslandBloc(creativeIslandRepo)),
                  ],
                  child: ImageEditDirectScreen(
                    setting: settingRepo,
                    title: AppLocale.superResolution.getString(context),
                    apiEndpoint: 'upscale',
                    note: state.queryParameters['note'],
                    initWaitDuration: 15,
                    initImage: state.queryParameters['init_image'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-colorize',
              path: '/creative-draw/create-colorize',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) =>
                            CreativeIslandBloc(creativeIslandRepo)),
                  ],
                  child: ImageEditDirectScreen(
                    setting: settingRepo,
                    title: AppLocale.colorizeImage.getString(context),
                    apiEndpoint: 'colorize',
                    note: state.queryParameters['note'],
                    initWaitDuration: 15,
                    initImage: state.queryParameters['init_image'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-video',
              path: '/creative-draw/create-video',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) =>
                            CreativeIslandBloc(creativeIslandRepo)),
                  ],
                  child: ImageEditDirectScreen(
                    setting: settingRepo,
                    title: '图生视频',
                    apiEndpoint: 'image-to-video',
                    note: state.queryParameters['note'],
                    initWaitDuration: 60,
                    initImage: state.queryParameters['init_image'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-draw-gallery-preview',
              path: '/creative-draw/gallery/:id',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: galleryBloc),
                  ],
                  child: GalleryItemScreen(
                    setting: settingRepo,
                    galleryId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-draw-create',
              path: '/creative-draw/create',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: galleryBloc),
                  ],
                  child: DrawCreateScreen(
                    setting: settingRepo,
                    galleryCopyId: int.tryParse(
                      state.queryParameters['gallery_copy_id'] ?? '',
                    ),
                    mode: state.queryParameters['mode']!,
                    id: state.queryParameters['id']!,
                    note: state.queryParameters['note'],
                    initImage: state.queryParameters['init_image'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-artistic-text',
              path: '/creative-draw/artistic-text',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: galleryBloc),
                  ],
                  child: ArtisticQRScreen(
                    setting: settingRepo,
                    galleryCopyId: int.tryParse(
                      state.queryParameters['gallery_copy_id'] ?? '',
                    ),
                    type: state.queryParameters['type']!,
                    id: state.queryParameters['id']!,
                    note: state.queryParameters['note'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-artistic-wordart',
              path: '/creative-draw/artistic-wordart',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: galleryBloc),
                  ],
                  child: ArtisticWordArtScreen(
                    setting: settingRepo,
                    galleryCopyId: int.tryParse(
                      state.queryParameters['gallery_copy_id'] ?? '',
                    ),
                    id: state.queryParameters['id']!,
                    note: state.queryParameters['note'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-island-history-all',
              path: '/creative-island/history',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) =>
                              CreativeIslandBloc(creativeIslandRepo)),
                    ],
                    child: MyCreationScreen(
                      setting: settingRepo,
                      mode: state.queryParameters['mode'] ?? '',
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-island-models',
              path: '/creative-island/models',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) =>
                              CreativeIslandBloc(creativeIslandRepo)),
                    ],
                    child: CreativeModelScreen(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-island-history-item',
              path: '/creative-island/:id/history/:item_id',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final itemId = int.tryParse(state.pathParameters['item_id']!);
                final showErrorMessage =
                    state.queryParameters['show_error'] == 'true';
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) =>
                              CreativeIslandBloc(creativeIslandRepo)),
                    ],
                    child: MyCreationItemPage(
                      setting: settingRepo,
                      islandId: id,
                      itemId: itemId!,
                      showErrorMessage: showErrorMessage,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'quota-details',
              path: '/quota-details',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                PaymentHistoryScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'quota-usage-statistics',
              path: '/quota-usage-statistics',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                QuotaUsageStatisticsScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'quota-usage-daily-details',
              path: '/quota-usage-daily-details',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                QuotaUsageDetailScreen(
                  setting: settingRepo,
                  date: state.queryParameters['date'] ??
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                ),
              ),
            ),
            GoRoute(
              name: 'prompt-editor',
              path: '/prompt-editor',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                var prompt = state.queryParameters['prompt'] ?? '';
                return transitionResolver(PromptScreen(prompt: prompt));
              },
            ),
            GoRoute(
              name: 'payment',
              path: '/payment',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(create: ((context) => PaymentBloc())),
                    ],
                    child: PaymentScreen(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'bind-phone',
              path: '/bind-phone',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: accountBloc),
                    ],
                    child: BindPhoneScreen(
                      setting: settingRepo,
                      isSignIn: state.queryParameters['is_signin'] != 'false',
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-gallery',
              path: '/creative-gallery',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: galleryBloc),
                  ],
                  child: GalleryScreen(setting: settingRepo),
                ),
              ),
            ),
            GoRoute(
              name: 'diagnosis',
              path: '/diagnosis',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                DiagnosisScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'free-statistics',
              path: '/free-statistics',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [BlocProvider.value(value: freeCountBloc)],
                  child: FreeStatisticsPage(setting: settingRepo),
                ),
              ),
            ),
            GoRoute(
              name: 'custom-home-models',
              path: '/setting/custom-home-models',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) => transitionResolver(
                CustomHomeModelsPage(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'group-chat-chat',
              path: '/group-chat/:group_id/chat',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final groupId = int.tryParse(state.pathParameters['group_id']!);

                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: ((context) =>
                            GroupChatBloc(stateManager: messageStateManager)),
                      ),
                      BlocProvider.value(value: chatRoomBloc),
                    ],
                    child: GroupChatPage(
                      setting: settingRepo,
                      stateManager: messageStateManager,
                      groupId: groupId!,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'group-chat-create',
              path: '/group-chat-create',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: ((context) =>
                            GroupChatBloc(stateManager: messageStateManager)),
                      ),
                      BlocProvider.value(value: chatRoomBloc),
                    ],
                    child: GroupCreatePage(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'group-chat-edit',
              path: '/group-chat/:group_id/edit',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: ((context) =>
                            GroupChatBloc(stateManager: messageStateManager)),
                      ),
                      BlocProvider.value(value: chatRoomBloc),
                    ],
                    child: GroupEditPage(
                      setting: settingRepo,
                      groupId: int.tryParse(state.pathParameters['group_id']!)!,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'user-api-keys',
              path: '/setting/user-api-keys',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: ((context) => UserApiKeysBloc()),
                      ),
                    ],
                    child: UserAPIKeysScreen(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'notifications',
              path: '/notifications',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  NotificationScreen(setting: settingRepo),
                );
              },
            ),
            GoRoute(
              name: 'articles',
              path: '/article',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  ArticleScreen(
                    settings: settingRepo,
                    id: int.tryParse(state.queryParameters['id'] ?? '') ?? 0,
                  ),
                );
              },
            ),
            GoRoute(
              name: 'web-payment-result',
              path: '/payment/result',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(WebPaymentResult(
                  paymentId: state.queryParameters['payment_id']!,
                  action: state.queryParameters['action'],
                ));
              },
            ),
            GoRoute(
              name: 'web-payment-proxy',
              path: '/payment/proxy',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(WebPaymentProxy(
                  setting: settingRepo,
                  paymentId: state.queryParameters['id']!,
                  paymentIntent: state.queryParameters['intent']!,
                  price: state.queryParameters['price']!,
                  publishableKey: state.queryParameters['key']!,
                  finishAction:
                      state.queryParameters['finish_action'] ?? 'close',
                ));
              },
            ),

            /// 管理员接口
            GoRoute(
              name: 'admin-dashboard',
              path: '/admin/dashboard',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  AdminDashboardPage(setting: settingRepo),
                );
              },
            ),
            GoRoute(
              name: 'admin-models',
              path: '/admin/models',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => ModelBloc(),
                      ),
                    ],
                    child: AdminModelsPage(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'admin-models-create',
              path: '/admin/models/create',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => ModelBloc(),
                      ),
                    ],
                    child: AdminModelCreatePage(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'admin-models-edit',
              path: '/admin/models/edit/:id',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => ModelBloc(),
                      ),
                    ],
                    child: AdminModelEditPage(
                      setting: settingRepo,
                      modelId: state.pathParameters['id']!,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'admin-channels',
              path: '/admin/channels',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => ChannelBloc(),
                      ),
                    ],
                    child: ChannelsPage(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'admin-channels-create',
              path: '/admin/channels/create',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => ChannelBloc(),
                      ),
                    ],
                    child: ChannelAddPage(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'admin-channels-edit',
              path: '/admin/channels/edit/:id',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final channelId = int.parse(state.pathParameters['id']!);

                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => ChannelBloc(),
                      ),
                    ],
                    child: ChannelEditPage(
                      setting: settingRepo,
                      channelId: channelId,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'admin-users',
              path: '/admin/users',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => UserBloc(),
                      ),
                    ],
                    child: AdminUsersPage(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'admin-users-detail',
              path: '/admin/users/:id',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final userId = int.parse(state.pathParameters['id']!);

                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => UserBloc(),
                      ),
                    ],
                    child: AdminUserPage(setting: settingRepo, userId: userId),
                  ),
                );
              },
            ),

            GoRoute(
              name: 'admin-payment-histories',
              path: '/admin/payment/histories',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => AdminPaymentBloc(),
                      ),
                    ],
                    child: PaymentHistoriesPage(setting: settingRepo),
                  ),
                );
              },
            ),

            GoRoute(
              name: 'admin-user-rooms',
              path: '/admin/users/:id/rooms',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final userId = int.parse(state.pathParameters['id']!);

                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => AdminRoomBloc(),
                      ),
                    ],
                    child: AdminRoomsPage(setting: settingRepo, userId: userId),
                  ),
                );
              },
            ),

            GoRoute(
              name: 'admin-user-rooms-messages',
              path: '/admin/users/:id/rooms/:room_id/messages',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final userId = int.parse(state.pathParameters['id']!);
                final roomId = int.parse(state.pathParameters['room_id']!);

                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => AdminRoomBloc(),
                      ),
                    ],
                    child: AdminRoomMessagesPage(
                      setting: settingRepo,
                      userId: userId,
                      roomId: roomId,
                      roomType: int.parse(state.queryParameters['room_type']!),
                    ),
                  ),
                );
              },
            ),

            GoRoute(
              name: 'admin-recently-messages',
              path: '/admin/recently-messages',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => AdminRoomBloc(),
                      ),
                    ],
                    child: AdminRecentlyMessagesPage(setting: settingRepo),
                  ),
                );
              },
            ),
          ],
        )
      ],
    );
  }

  final SettingRepository settingRepo;
  final ChatMessageRepository chatMsgRepo;
  final OpenAIRepository openAIRepo;
  final CacheRepository cacheRepo;
  final CreativeIslandRepository creativeIslandRepo;

  @override
  State<MyApp> createState() => _MyAppState();
}
List<DisplayMode> modes = <DisplayMode>[];

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    print("9999");
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      print("888");
      modes = await FlutterDisplayMode.supported;
      modes.forEach(print);
      await FlutterDisplayMode.preferred;
      await FlutterDisplayMode.active;
      await FlutterDisplayMode.setHighRefreshRate();
      setState(() {

      });
    });

    // 初始化多语言
    // final defaultLanguage = resolveSystemLanguage(PlatformTool.localeName());
    // var initLanguage =
    //     widget.settingRepo.stringDefault(settingLanguage, defaultLanguage);

    widget.localization.init(
      mapLocales: [
        const MapLocale('zh', AppLocale.zh),
        const MapLocale('zh-CHS', AppLocale.zh),
        const MapLocale('en', AppLocale.en),
      ],
      // initLanguageCode: initLanguage == '' ? defaultLanguage : initLanguage,
      initLanguageCode: 'zh-CHS',
    );

    widget.localization.onTranslatedLanguage = (Locale? locale) {
      setState(() {});
    };

    if (PlatformTool.isIOS() || PlatformTool.isAndroid()) {
      registerWxApi(
        appId: weixinAppId,
        universalLink: universalLink,
      );
    }

    // weChatResponseEventHandler.listen((event) {
    //   print("=====================");
    //   print("errorCode: ${event.errCode}");
    //   print("errorMessage: ${event.errStr}");
    //   if (event is WeChatShareResponse) {
    //     print("type: ${event.type}");
    //     print("success:${event.isSuccessful}");
    //   }
    //   showSuccessMessage('分享成功', duration: const Duration(seconds: 3));
    // });

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ChatMessageRepository>(
            create: (context) => widget.chatMsgRepo),
        RepositoryProvider<OpenAIRepository>(
            create: (context) => widget.openAIRepo),
        RepositoryProvider<SettingRepository>(
            create: (context) => widget.settingRepo),
        RepositoryProvider<CacheRepository>(
            create: (context) => widget.cacheRepo),
      ],
      child: ChangeNotifierProvider(
          create: (context) => AppTheme.instance
            ..mode = AppTheme.themeModeFormString(
                widget.settingRepo.stringDefault(settingThemeMode, 'system')),
          builder: (context, _) {
            final appTheme = context.watch<AppTheme>();
            return Sizer(
              builder: (context, orientation, deviceType) {
                return MaterialApp.router(
                  title: 'AIdea',
                  themeMode: appTheme.mode,
                  theme: createLightThemeData(),
                  darkTheme: createDarkThemeData(),
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) {
                    // 这里设置了全局字体固定大小，不随系统设置变更
                    // TODO 后面要增加一个设置项，允许用户自定义字体大小
                    return MediaQuery(
                      data:
                          MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: BotToastInit()(context, child),
                    );
                  },
                  routerConfig: widget._router,
                  supportedLocales: widget.localization.supportedLocales,
                  localizationsDelegates:
                      widget.localization.localizationsDelegates,
                  scrollBehavior:
                      PlatformTool.isAndroid() || PlatformTool.isIOS()
                          ? null
                          : const MaterialScrollBehavior().copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.stylus,
                                PointerDeviceKind.trackpad,
                              },
                            ),
                );
              },
            );
          }),
    );
  }
}

ThemeData createLightThemeData() {
  return ThemeData.light().copyWith(
    extensions: [CustomColors.light],
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      // backgroundColor: Color.fromARGB(255, 250, 250, 250),
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: PlatformTool.isMacOS()
        ? IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          )
        : null,
    dividerColor: Colors.transparent,
    dialogBackgroundColor: Colors.white,
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(
            255, 9, 185, 85), // This is a custom color variable
      ),
    ),
  );
}

ThemeData createDarkThemeData() {
  return ThemeData.dark().copyWith(
    extensions: [CustomColors.dark],
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      // backgroundColor: Color.fromARGB(255, 48, 48, 48),
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: PlatformTool.isMacOS()
        ? IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          )
        : null,
    dividerColor: Colors.transparent,
    dialogBackgroundColor: const Color.fromARGB(255, 48, 48, 48),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(
            255, 9, 185, 85), // This is a custom color variable
      ),
    ),
  );
}
