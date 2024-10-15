import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/bloc/notify_bloc.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/component/model_switcher.dart';
import 'package:askaide/page/chat/component/stop_button.dart';
import 'package:askaide/page/chat/room_chat.dart';
import 'package:askaide/page/component/audio_player.dart';
import 'package:askaide/page/component/chat/chat_input.dart';
import 'package:askaide/page/component/chat/chat_preview.dart';
import 'package:askaide/page/component/chat/empty.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/help_tips.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/component/chat/role_avatar.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_error.dart';
import 'package:askaide/page/component/global_alert.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/select_mode_toolbar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/custom_scaffold.dart';
import 'package:askaide/page/drawer.dart';
import 'package:askaide/repo/api/model.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:askaide/repo/model/model.dart' as mm;

class NewHomePage extends StatefulWidget {
  final SettingRepository settings;

  /// 聊天内容窗口状态管理器
  final MessageStateManager stateManager;
  const NewHomePage({
    super.key,
    required this.settings,
    required this.stateManager,
  });

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  // 聊天内容界面控制器
  final ChatPreviewController chatPreviewController = ChatPreviewController();
  // 聊天内容滚动控制器
  final ScrollController scrollController = ScrollController();
  // 输入框是否可编辑
  final ValueNotifier<bool> enableInput = ValueNotifier(true);
  // 音频播放器控制器
  final AudioPlayerController audioPlayerController =
      AudioPlayerController(useRemoteAPI: true);

  // 聊天室 ID，当没有值时，会在第一个聊天消息发送后自动设置新值
  int? chatId;
  // The selected image files for image upload
  List<FileUpload> selectedImageFiles = [];
  // The selected file for file upload
  FileUpload? selectedFile;

  // 是否显示音频播放器
  bool showAudioPlayer = false;
  // 是否显示音频播放器加载中
  bool audioLoadding = false;

  /// 当前选择的模型
  mm.Model? selectedModel;
  // 全量模型列表
  List<mm.Model> supportModels = [];
  // 当前聊天所使用的模型（v2）
  HomeModelV2? currentModelV2;

  @override
  void initState() {
    super.initState();

    Cache().intGet(key: 'last_chat_id').then((value) {
      chatId = value;
      reloadPage(loadAll: true);
    });

    reloadModels();
    initListeners();
  }

  /// 重新加载页面
  void reloadPage({bool loadAll = false}) {
    // 加载当前用户信息
    context.read<AccountBloc>().add(AccountLoadEvent());

    if (loadAll) {
      // 加载当前聊天室信息
      context.read<RoomBloc>().add(RoomLoadEvent(
            chatAnywhereRoomId,
            chatHistoryId: chatId,
            cascading: true,
          ));

      // 查询最近聊天记录
      context
          .read<ChatMessageBloc>()
          .add(ChatMessageGetRecentEvent(chatHistoryId: chatId));
    }
  }

  /// 加载模型列表，用于查询模型名称
  void reloadModels() {
    ModelAggregate.models().then((value) {
      setState(() {
        supportModels = value;
      });

      Cache().stringGet(key: 'last_selected_model').then((value) {
        final selected = supportModels.where((e) => e.id == value).firstOrNull;
        if (selected != null) {
          setState(() {
            selectedModel = selected;
          });
        }

        if (selectedModel == null && supportModels.isNotEmpty) {
          setState(() {
            selectedModel = supportModels.first;
          });
        }

        if (selectedModel != null) {
          loadCurrentModel(selectedModel!.id);
        }
      });
    });
  }

  void initListeners() {
    chatPreviewController.addListener(() {
      setState(() {});
    });

    audioPlayerController.onPlayStopped = () {
      setState(() {
        showAudioPlayer = false;
      });
    };
    audioPlayerController.onPlayAudioStarted = () {
      setState(() {
        showAudioPlayer = true;
      });
    };
    audioPlayerController.onPlayAudioLoading = (loading) {
      setState(() {
        audioLoadding = loading;
      });
    };
  }

  /// 创建新的聊天
  void createNewChat() {
    Cache().setInt(
      key: 'last_chat_id',
      value: 0,
      duration: const Duration(days: 3650),
    );
    setState(() {
      chatId = null;
    });

    reloadPage(loadAll: true);
  }

  /// 更新当前聊天
  void updateCurrentChat(int chatId) {
    Cache().setInt(
      key: 'last_chat_id',
      value: chatId,
      duration: const Duration(days: 3650),
    );
    if (this.chatId == chatId) {
      return;
    }

    setState(() {
      this.chatId = chatId;
    });
    reloadPage();
  }

  @override
  void dispose() {
    scrollController.dispose();
    chatPreviewController.dispose();
    audioPlayerController.dispose();

    super.dispose();
  }

  Future<void> loadCurrentModel(String model) async {
    if (!model.startsWith('v2@') || currentModelV2 != null) {
      return;
    }

    currentModelV2 = await APIServer().customHomeModelsItemV2(
      uniqueKey: model.split('v2@').last,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return CustomScaffold(
      settings: widget.settings,
      appBarBackground: Image.asset(
        customColors.appBarBackgroundImage!,
        fit: BoxFit.cover,
      ),
      showBackAppBar: chatPreviewController.selectMode,
      backAppBar: AppBar(
        title: Text(
          AppLocale.select.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            chatPreviewController.exitSelectMode();
          },
          child: Text(
            AppLocale.cancel.getString(context),
            style: TextStyle(color: customColors.linkColor),
          ),
        ),
        toolbarHeight: CustomSize.toolbarHeight,
      ),
      // 标题，点击后弹出模型选择对话框
      title: GestureDetector(
        onTap: () {
          ModelSwitcher.openActionDialog(
            context: context,
            onSelected: (selected) {
              setState(() {
                selectedModel = selected;
              });

              if (selected != null) {
                Cache().setString(
                  key: 'last_selected_model',
                  value: selected.id,
                  duration: const Duration(days: 3650),
                );
              }
            },
            initValue: selectedModel,
          );
        },
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              alignment: Alignment.center,
              child: BlocBuilder<ChatMessageBloc, ChatMessageState>(
                buildWhen: (previous, current) => current is ChatMessagesLoaded,
                builder: (context, state) {
                  if (state is ChatMessagesLoaded) {
                    return Text(
                      state.chatHistory == null ||
                              state.chatHistory!.title == null
                          ? AppLocale.chatAnywhere.getString(context)
                          : state.chatHistory!.title!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: CustomSize.appBarTitleSize,
                      ),
                    );
                  }

                  return Text(
                    AppLocale.chatAnywhere.getString(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        const TextStyle(fontSize: CustomSize.appBarTitleSize),
                  );
                },
              ),
            ),
            if (selectedModel != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedModel!.name,
                    style: TextStyle(
                      fontSize: CustomSize.appBarTitleSize * 0.6,
                      color: customColors.backgroundInvertedColor,
                    ),
                  ),
                  Icon(
                    Icons.unfold_more,
                    color: customColors.backgroundInvertedColor,
                    size: CustomSize.appBarTitleSize * 0.6,
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.post_add),
          onPressed: createNewChat,
        ),
      ],
      body: BlocConsumer<RoomBloc, RoomState>(
        listenWhen: (previous, current) => current is RoomLoaded,
        listener: (context, state) async {
          if (state is RoomLoaded && currentModelV2 == null) {
            await loadCurrentModel(state.room.model);
          }

          if (state is RoomLoaded && state.cascading) {
            if (state.room.model.startsWith('v2@')) {
              if (currentModelV2 != null && currentModelV2!.modelId != null) {
                // 加载免费使用次数
                // ignore: use_build_context_synchronously
                context.read<FreeCountBloc>().add(FreeCountReloadEvent(
                      model: currentModelV2!.modelId!,
                    ));
              }
            } else {
              // 加载免费使用次数
              // ignore: use_build_context_synchronously
              context.read<FreeCountBloc>().add(FreeCountReloadEvent(
                    model: selectedModel?.id ?? state.room.model,
                  ));
            }
          }
        },
        buildWhen: (previous, current) => current is RoomLoaded,
        builder: (context, room) {
          // 加载聊天室
          if (room is RoomLoaded) {
            if (room.error != null) {
              return EnhancedErrorWidget(error: room.error);
            }

            return buildChatComponents(
              customColors,
              context,
              room,
            );
          } else {
            return Container();
          }
        },
      ),
      drawer: MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<AccountBloc>(),
          ),
          BlocProvider.value(
            value: context.read<ChatChatBloc>(),
          ),
        ],
        child: const LeftDrawer(),
      ),
    );
  }

  /// 构建聊天室窗口
  Widget buildChatComponents(
    CustomColors customColors,
    BuildContext context,
    RoomLoaded room,
  ) {
    return Column(
      children: [
        if (Ability().showGlobalAlert) const GlobalAlert(pageKey: 'chat'),
        if (showAudioPlayer)
          EnhancedAudioPlayer(
            controller: audioPlayerController,
            loading: audioLoadding,
          ),
        // 聊天内容窗口
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              BlocConsumer<ChatMessageBloc, ChatMessageState>(
                listener: (context, state) {
                  if (state is ChatAnywhereInited) {
                    updateCurrentChat(state.chatId);
                  }

                  if (state is ChatMessagesLoaded && state.error == null) {
                    setState(() {
                      selectedImageFiles = [];
                    });
                  }
                  // 显示错误提示
                  else if (state is ChatMessagesLoaded && state.error != null) {
                    showErrorMessageEnhanced(context, state.error);
                  } else if (state is ChatMessageUpdated) {
                    // 聊天内容窗口滚动到底部
                    if (!state.processing && scrollController.hasClients) {
                      scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    }

                    if (state.processing && enableInput.value) {
                      // 聊天回复中时，禁止输入框编辑
                      setState(() {
                        enableInput.value = false;
                      });
                    } else if (!state.processing && !enableInput.value) {
                      // 更新免费使用次数
                      context.read<FreeCountBloc>().add(FreeCountReloadEvent(
                          model: selectedModel?.id ?? room.room.model));

                      // 聊天回复完成时，取消输入框的禁止编辑状态
                      setState(() {
                        enableInput.value = true;
                      });
                    }
                  }
                },
                buildWhen: (prv, cur) => cur is ChatMessagesLoaded,
                builder: (context, state) {
                  if (state is ChatMessagesLoaded) {
                    return buildChatPreviewArea(
                      state,
                      room.examples ?? [],
                      room,
                      customColors,
                      chatPreviewController.selectMode,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              if (!enableInput.value)
                Positioned(
                  bottom: 10,
                  width: CustomSize.adaptiveMaxWindowWidth(context),
                  child: Center(
                    child: StopButton(
                      label: '停止输出',
                      onPressed: () {
                        HapticFeedbackHelper.mediumImpact();
                        context
                            .read<ChatMessageBloc>()
                            .add(ChatMessageStopEvent());
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 聊天输入窗口
        if (!chatPreviewController.selectMode)
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: customColors.chatInputPanelBackground,
            ),
            child: BlocBuilder<FreeCountBloc, FreeCountState>(
              builder: (context, freeState) {
                var hintText = '有问题尽管问我';
                if (freeState is FreeCountLoadedState) {
                  final matched = freeState.model(room.room.model);
                  if (matched != null &&
                      matched.leftCount > 0 &&
                      matched.maxCount > 0) {
                    hintText += '（今日还可免费${matched.leftCount}次）';
                  }
                }

                return BlocBuilder<ChatMessageBloc, ChatMessageState>(
                  buildWhen: (previous, current) =>
                      current is ChatMessagesLoaded,
                  builder: (context, state) {
                    var enableImageUpload = false;
                    if (state is ChatMessagesLoaded) {
                      if (currentModelV2 != null) {
                        enableImageUpload =
                            currentModelV2?.supportVision ?? false;
                      } else {
                        var model = state.chatHistory?.model ?? room.room.model;
                        final cur = supportModels
                            .where((e) => e.id == model)
                            .firstOrNull;
                        enableImageUpload = cur?.supportVision ?? false;
                      }
                    }

                    enableImageUpload = selectedModel == null
                        ? enableImageUpload
                        : (selectedModel?.supportVision ?? false);

                    return ChatInput(
                      enableNotifier: enableInput,
                      onSubmit: (value) {
                        handleSubmit(value);
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      enableImageUpload: enableImageUpload,
                      onImageSelected: (files) {
                        setState(() {
                          selectedImageFiles = files;
                        });
                      },
                      selectedImageFiles:
                          enableImageUpload ? selectedImageFiles : [],
                      hintText: hintText,
                      onVoiceRecordTappedEvent: () {
                        audioPlayerController.stop();
                      },
                      onStopGenerate: () {
                        context
                            .read<ChatMessageBloc>()
                            .add(ChatMessageStopEvent());
                      },
                    );
                  },
                );
              },
            ),
          ),

        // 选择模式工具栏
        if (chatPreviewController.selectMode)
          SelectModeToolbar(chatPreviewController: chatPreviewController),
      ],
    );
  }

  /// 构建聊天内容窗口
  Widget buildChatPreviewArea(
    ChatMessagesLoaded loadedState,
    List<ChatExample> examples,
    RoomLoaded room,
    CustomColors customColors,
    bool selectMode,
  ) {
    final loadedMessages = loadedState.messages as List<Message>;
    if (room.room.initMessage != null &&
        room.room.initMessage != '' &&
        loadedMessages.isEmpty) {
      loadedMessages.add(
        Message(
          Role.receiver,
          room.room.initMessage!,
          type: MessageType.initMessage,
        ),
      );
    }

    // 聊天内容为空时，显示示例页面
    if (loadedMessages.isEmpty) {
      return EmptyPreview(
        examples: examples,
        onSubmit: handleSubmit,
      );
    }

    final messages = loadedMessages.map((e) {
      if (e.model != null && !e.model!.startsWith('v2@')) {
        final mod = supportModels.where((m) => m.id == e.model).firstOrNull;
        if (mod != null) {
          e.senderName = mod.shortName;
          e.avatarUrl = mod.avatarUrl;
        }
      }

      if (e.avatarUrl == null || e.senderName == null) {
        if (loadedState.chatHistory != null &&
            loadedState.chatHistory!.model != null) {
          if (currentModelV2 != null) {
            e.senderName = currentModelV2!.name;
            e.avatarUrl = currentModelV2!.avatarUrl;
          } else {
            final mod = supportModels
                .where((e) => e.id == loadedState.chatHistory!.model!)
                .firstOrNull;
            if (mod != null) {
              e.senderName = mod.shortName;
              e.avatarUrl = mod.avatarUrl;
            }
          }
        }
      }

      final stateMessage =
          room.states[widget.stateManager.getKey(e.roomId ?? 0, e.id ?? 0)] ??
              MessageState();
      return MessageWithState(e, stateMessage);
    }).toList();

    chatPreviewController.setAllMessageIds(messages);

    return ChatPreview(
      padding: enableInput.value ? null : const EdgeInsets.only(bottom: 35),
      messages: messages,
      scrollController: scrollController,
      controller: chatPreviewController,
      stateManager: widget.stateManager,
      robotAvatar: selectMode
          ? null
          : RoleAvatar(
              avatarUrl: room.room.avatarUrl,
              his: loadedState.chatHistory,
              alternativeAvatarUrl: currentModelV2?.avatarUrl,
            ),
      senderNameBuilder: (message) {
        if (message.senderName == null) {
          return null;
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 10, 7),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Text(
            message.senderName!,
            style: TextStyle(
              color: customColors.weakTextColor,
              fontSize: 12,
            ),
          ),
        );
      },
      onDeleteMessage: (id) {
        handleDeleteMessage(context, id, chatHistoryId: chatId);
      },
      onResetContext: () => handleResetContext(context),
      onResentEvent: (message, index) {
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

        handleSubmit(message.text,
            messagetType: message.type, index: index, isResent: true);
      },
      onSpeakEvent: (message) {
        audioPlayerController.playAudio(message.text);
      },
      helpWidgets: loadedState.processing || loadedMessages.last.isInitMessage()
          ? null
          : [HelpTips(onSubmitMessage: handleSubmit)],
    );
  }

  /// 提交新消息
  void handleSubmit(
    String text, {
    messagetType = MessageType.text,
    int? index,
    bool isResent = false,
  }) async {
    setState(() {
      enableInput.value = false;
    });

    if (selectedImageFiles.isNotEmpty) {
      final cancel = BotToast.showCustomLoading(
        toastBuilder: (cancel) {
          return const LoadingIndicator(
            message: '正在上传图片，请稍后...',
          );
        },
        allowClick: false,
      );

      try {
        final uploader = ImageUploader(widget.settings);

        for (var file in selectedImageFiles) {
          if (file.uploaded) {
            continue;
          }

          if (file.file.bytes != null) {
            final res = await uploader.base64(
              imageData: file.file.bytes,
              maxSize: 1024 * 1024,
              compressWidth: 512,
              compressHeight: 512,
            );
            file.setUrl(res);
          } else {
            final res = await uploader.base64(
              path: file.file.path!,
              maxSize: 1024 * 1024,
              compressWidth: 512,
              compressHeight: 512,
            );
            file.setUrl(res);
          }
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        showErrorMessageEnhanced(context, e);
        return;
      } finally {
        cancel();
      }
    }

    // ignore: use_build_context_synchronously
    context.read<ChatMessageBloc>().add(
          ChatMessageSendEvent(
            Message(
              Role.sender,
              text,
              user: 'me',
              ts: DateTime.now(),
              model: selectedModel!.id,
              type: messagetType,
              chatHistoryId: chatId,
              images: selectedImageFiles
                  .where((e) => e.uploaded)
                  .map((e) => e.url!)
                  .toList(),
            ),
            index: index,
            isResent: isResent,
          ),
        );

    // ignore: use_build_context_synchronously
    context
        .read<RoomBloc>()
        .add(RoomLoadEvent(chatAnywhereRoomId, cascading: false));
  }
}
