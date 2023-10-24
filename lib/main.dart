import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/bloc/background_image_bloc.dart';
import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/bloc/gallery_bloc.dart';
import 'package:askaide/bloc/group_chat_bloc.dart';
import 'package:askaide/bloc/payment_bloc.dart';
import 'package:askaide/bloc/version_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/helper/model_resolver.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/data/migrate.dart';
import 'package:askaide/page/account_security.dart';
import 'package:askaide/page/app_scaffold.dart';
import 'package:askaide/page/avatar_selector.dart';
import 'package:askaide/page/background_selector.dart';
import 'package:askaide/page/bind_phone_page.dart';
import 'package:askaide/page/change_password.dart';
import 'package:askaide/page/chat_anywhere.dart';
import 'package:askaide/page/chat_chat.dart';
import 'package:askaide/page/chat_history.dart';
import 'package:askaide/page/chat_room_create.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/transition_resolver.dart';
import 'package:askaide/page/creative_island/creative_island.dart';
import 'package:askaide/page/creative_island/creative_island_create_page.dart';
import 'package:askaide/page/creative_island/creative_island_gallery.dart';
import 'package:askaide/page/creative_island/creative_island_history.dart';
import 'package:askaide/page/creative_island/creative_island_history_all.dart';
import 'package:askaide/page/creative_island/creative_island_history_preview.dart';
import 'package:askaide/page/custom_home_models.dart';
import 'package:askaide/page/free_statistics.dart';
import 'package:askaide/page/group/chat.dart';
import 'package:askaide/page/group/create.dart';
import 'package:askaide/page/group/edit.dart';
import 'package:askaide/page/lab/creative_models.dart';
import 'package:askaide/page/destroy_account.dart';
import 'package:askaide/page/diagnosis.dart';
import 'package:askaide/page/draw/draw.dart';
import 'package:askaide/page/draw/draw_create.dart';
import 'package:askaide/page/draw/image_edit_direct.dart';
import 'package:askaide/page/lab/draw_board.dart';
import 'package:askaide/page/gallery/gallery.dart';
import 'package:askaide/page/gallery/gallery_item.dart';
import 'package:askaide/page/openai_setting.dart';
import 'package:askaide/page/payment.dart';
import 'package:askaide/page/prompt.dart';
import 'package:askaide/page/quota_usage_statistics.dart';
import 'package:askaide/page/signin_or_signup.dart';
import 'package:askaide/page/signin_screen.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/quota_detail_screen.dart';
import 'package:askaide/page/retrieve_password_screen.dart';
import 'package:askaide/page/signup_screen.dart';
import 'package:askaide/page/lab/user_center.dart';
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
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluwx/fluwx.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:askaide/bloc/bloc_manager.dart';
import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/bloc/notify_bloc.dart';
import 'package:askaide/page/chat_room_setting.dart';
import 'package:askaide/page/chat_screen.dart';
import 'package:askaide/page/home_screen.dart';
import 'package:askaide/page/setting_screen.dart';
import 'package:askaide/repo/data/chat_message_data.dart';
import 'package:askaide/repo/chat_message_repo.dart';
import 'package:askaide/repo/data/room_data.dart';
import 'package:askaide/repo/openai_repo.dart';
import 'package:askaide/repo/data/settings_data.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'page/theme/theme.dart';
import 'package:sizer/sizer.dart';
import 'package:askaide/helper/http.dart' as httpx;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  httpx.HttpClient.init();

  // FlutterError.onError = (FlutterErrorDetails details) {
  //   if (details.library == 'rendering library' ||
  //       details.library == 'image resource service') {
  //     return;
  //   }

  //   Logger.instance.e(details.summary, details.exception, details.stack);
  //   print(details.stack);
  // };

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    if (PlatformTool.isWindows()) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
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
    final capabilities = await APIServer().capabilities();
    Ability().init(settingRepo, capabilities);
  } catch (e) {
    Logger.instance.e('获取客户端能力清单失败', error: e);
    Ability().init(
      settingRepo,
      Capabilities(
        applePayEnabled: true,
        alipayEnabled: true,
        translateEnabled: true,
        mailEnabled: true,
        openaiEnabled: true,
        homeModels: [],
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
  late final CreativeIslandBloc creativeIslandBloc;
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
    creativeIslandBloc = CreativeIslandBloc(creativeIslandRepo);
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
      initialLocation: shouldLogin ? '/login' : '/chat-chat',
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
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/user/change-password',
              pageBuilder: (context, state) => transitionResolver(
                ChangePasswordScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              path: '/user/destroy',
              pageBuilder: (context, state) => transitionResolver(
                DestroyAccountScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              path: '/signup',
              pageBuilder: (context, state) => transitionResolver(
                SignupScreen(
                  settings: settingRepo,
                  username: state.queryParameters['username'],
                ),
              ),
            ),
            GoRoute(
              path: '/retrieve-password',
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
                  child: ChatAnywhereScreen(
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
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) => ChatChatBloc(chatMsgRepo)),
                    BlocProvider.value(value: freeCountBloc),
                  ],
                  child: ChatChatScreen(
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
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) => ChatChatBloc(chatMsgRepo)),
                  ],
                  child: ChatHistoryPage(
                    setting: settingRepo,
                    chatMessageRepo: chatMsgRepo,
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/lab/avatar-selector',
              pageBuilder: (context, state) => transitionResolver(
                const AvatarSelectorScreen(usage: AvatarUsage.room),
              ),
            ),
            GoRoute(
              path: '/lab/draw-board',
              pageBuilder: (context, state) => transitionResolver(
                const DrawboardScreen(),
              ),
            ),
            GoRoute(
              name: 'characters',
              path: '/',
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [BlocProvider.value(value: chatRoomBloc)],
                  child: CharactersScreen(setting: settingRepo),
                ),
              ),
            ),
            GoRoute(
              name: 'create-room',
              path: '/create-room',
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [BlocProvider.value(value: chatRoomBloc)],
                  child: ChatRoomCreateScreen(setting: settingRepo),
                ),
              ),
            ),
            GoRoute(
              name: 'chat',
              path: '/room/:room_id/chat',
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
                    child: ChatScreen(
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
                    child: ChatRoomSettingScreen(
                        roomId: roomId, setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'account-security-setting',
              path: '/setting/account-security',
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
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: accountBloc),
                    BlocProvider.value(value: creativeIslandBloc),
                  ],
                  child: UserCenterScreen(
                      settings: context.read<SettingRepository>()),
                ),
              ),
            ),
            GoRoute(
              name: 'setting',
              path: '/setting',
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
              pageBuilder: (context, state) => transitionResolver(
                OpenAISettingScreen(
                  settings: settingRepo,
                  source: state.queryParameters['source'],
                ),
              ),
            ),
            GoRoute(
              name: 'creative-island',
              path: '/creative-island',
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: creativeIslandBloc),
                  ],
                  child: CreativeIsland(
                    setting: settingRepo,
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-draw',
              path: '/creative-draw',
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: creativeIslandBloc),
                  ],
                  child: DrawScreen(
                    setting: settingRepo,
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-upscale',
              path: '/creative-draw/create-upscale',
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: creativeIslandBloc),
                  ],
                  child: ImageEditDirectScreen(
                    setting: settingRepo,
                    title: AppLocale.superResolution.getString(context),
                    apiEndpoint: 'upscale',
                    note: state.queryParameters['note'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-colorize',
              path: '/creative-draw/create-colorize',
              pageBuilder: (context, state) => transitionResolver(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: creativeIslandBloc),
                  ],
                  child: ImageEditDirectScreen(
                    setting: settingRepo,
                    title: AppLocale.colorizeImage.getString(context),
                    apiEndpoint: 'colorize',
                    note: state.queryParameters['note'],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-draw-gallery-preview',
              path: '/creative-draw/gallery/:id',
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
                  ),
                ),
              ),
            ),
            GoRoute(
              name: 'creative-island-create',
              path: '/creative-island/:id/create',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: creativeIslandBloc),
                    ],
                    child: CreativeIslandCreatePage(
                      id: id,
                      repo: creativeIslandRepo,
                      setting: settingRepo,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-island-history-all',
              path: '/creative-island/history',
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: creativeIslandBloc),
                    ],
                    child: CreativeIslandHistoriesAllScreen(
                      setting: settingRepo,
                      mode: state.queryParameters['mode'] ?? '',
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-island-gallery',
              path: '/creative-island/gallery',
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: creativeIslandBloc),
                    ],
                    child: CreativeIslandGalleryScreen(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-island-models',
              path: '/creative-island/models',
              pageBuilder: (context, state) {
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: creativeIslandBloc),
                    ],
                    child: CreativeModelScreen(setting: settingRepo),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-island-history',
              path: '/creative-island/:id/history',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: creativeIslandBloc),
                    ],
                    child: CreativeIslandHistoryPage(
                      id: id,
                      repo: creativeIslandRepo,
                      setting: settingRepo,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'creative-island-history-item',
              path: '/creative-island/:id/history/:item_id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final itemId = int.tryParse(state.pathParameters['item_id']!);
                final showErrorMessage =
                    state.queryParameters['show_error'] == 'true';
                return transitionResolver(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: creativeIslandBloc),
                    ],
                    child: CreativeIslandHistoryPreview(
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
              pageBuilder: (context, state) => transitionResolver(
                QuotaDetailScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'quota-usage-statistics',
              path: '/quota-usage-statistics',
              pageBuilder: (context, state) => transitionResolver(
                QuotaUsageStatisticsScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'prompt-editor',
              path: '/prompt-editor',
              pageBuilder: (context, state) {
                var prompt = state.queryParameters['prompt'] ?? '';
                return transitionResolver(PromptScreen(prompt: prompt));
              },
            ),
            GoRoute(
              name: 'payment',
              path: '/payment',
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
              pageBuilder: (context, state) => transitionResolver(
                DiagnosisScreen(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'free-statistics',
              path: '/free-statistics',
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
              pageBuilder: (context, state) => transitionResolver(
                CustomHomeModelsPage(setting: settingRepo),
              ),
            ),
            GoRoute(
              name: 'group-chat-chat',
              path: '/group-chat/:group_id/chat',
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

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
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
                  builder: BotToastInit(),
                  routerConfig: widget._router,
                  supportedLocales: widget.localization.supportedLocales,
                  localizationsDelegates:
                      widget.localization.localizationsDelegates,
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
