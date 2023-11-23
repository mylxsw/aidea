import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/bloc/notify_bloc.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/global_store.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/room_chat.dart';
import 'package:askaide/page/component/audio_player.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/chat_input.dart';
import 'package:askaide/page/component/chat/chat_preview.dart';
import 'package:askaide/page/component/chat/empty.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/help_tips.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/component/enhanced_error.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:askaide/repo/model/model.dart' as mm;

class HomeChatPage extends StatefulWidget {
  final MessageStateManager stateManager;
  final SettingRepository setting;
  final int? chatId;
  final String? initialMessage;
  final String? model;
  final String? title;

  const HomeChatPage({
    super.key,
    required this.stateManager,
    required this.setting,
    this.chatId,
    this.initialMessage,
    this.model,
    this.title,
  });

  @override
  State<HomeChatPage> createState() => _HomeChatPageState();
}

class _HomeChatPageState extends State<HomeChatPage> {
  final ChatPreviewController _chatPreviewController = ChatPreviewController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _inputEnabled = ValueNotifier(true);
  final AudioPlayerController _audioPlayerController =
      AudioPlayerController(useRemoteAPI: true);

  int? chatId;
  List<FileUpload> selectedImageFiles = [];

  bool showAudioPlayer = false;
  bool audioLoadding = false;

  List<mm.Model> supportModels = [];

  @override
  void initState() {
    chatId = widget.chatId;
    context.read<RoomBloc>().add(RoomLoadEvent(
          chatAnywhereRoomId,
          chatHistoryId: chatId,
          cascading: true,
        ));
    context
        .read<ChatMessageBloc>()
        .add(ChatMessageGetRecentEvent(chatHistoryId: widget.chatId));

    _chatPreviewController.addListener(() {
      setState(() {});
    });

    _audioPlayerController.onPlayStopped = () {
      setState(() {
        showAudioPlayer = false;
      });
    };
    _audioPlayerController.onPlayAudioStarted = () {
      setState(() {
        showAudioPlayer = true;
      });
    };
    _audioPlayerController.onPlayAudioLoading = (loading) {
      setState(() {
        audioLoadding = loading;
      });
    };

    // 加载模型列表，用于查询模型名称
    ModelAggregate.models().then((value) {
      setState(() {
        supportModels = value;
      });
    });

    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          selectedImageFiles = GlobalStore().uploadedFiles;
          _handleSubmit(widget.initialMessage!);
        });
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatPreviewController.dispose();
    _audioPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        // AppBar
        appBar: _buildAppBar(context, customColors),
        backgroundColor: Colors.transparent,
        // 聊天内容窗口
        body: BlocConsumer<RoomBloc, RoomState>(
          listenWhen: (previous, current) => current is RoomLoaded,
          listener: (context, state) {
            if (state is RoomLoaded && state.cascading) {
              // 加载免费使用次数
              context.read<FreeCountBloc>().add(FreeCountReloadEvent(
                    model: widget.model ?? state.room.model,
                  ));
            }
          },
          buildWhen: (previous, current) => current is RoomLoaded,
          builder: (context, room) {
            // 加载聊天室
            if (room is RoomLoaded) {
              if (room.error != null) {
                return EnhancedErrorWidget(error: room.error);
              }

              return _buildChatComponents(
                customColors,
                context,
                room,
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  /// 构建 AppBar
  AppBar _buildAppBar(BuildContext context, CustomColors customColors) {
    if (_chatPreviewController.selectMode) {
      return AppBar(
        title: Text(AppLocale.select.getString(context)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: TextButton(
          onPressed: () {
            _chatPreviewController.exitSelectMode();
          },
          child: Text(
            AppLocale.cancel.getString(context),
            style: TextStyle(color: customColors.linkColor),
          ),
        ),
      );
    }

    return AppBar(
      centerTitle: true,
      elevation: 0,
      toolbarHeight: CustomSize.toolbarHeight,
      title: BlocBuilder<ChatMessageBloc, ChatMessageState>(
        buildWhen: (previous, current) => current is ChatMessagesLoaded,
        builder: (context, state) {
          if (state is ChatMessagesLoaded) {
            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  alignment: Alignment.center,
                  child: Text(
                    widget.title ?? AppLocale.chatAnywhere.getString(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        const TextStyle(fontSize: CustomSize.appBarTitleSize),
                  ),
                ),
                if (state.chatHistory?.model != null)
                  Text(
                    supportModels
                            .where((e) => e.id == state.chatHistory!.model!)
                            .firstOrNull
                            ?.shortName ??
                        '',
                    style: TextStyle(
                      color: customColors.weakTextColor,
                      fontSize: 10,
                    ),
                  )
              ],
            );
          }

          return const SizedBox();
        },
      ),
      flexibleSpace: SizedBox(
        width: double.infinity,
        child: ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: Image.asset(
            customColors.appBarBackgroundImage!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// 构建聊天室窗口
  Widget _buildChatComponents(
    CustomColors customColors,
    BuildContext context,
    RoomLoaded room,
  ) {
    return Column(
      children: [
        if (showAudioPlayer)
          EnhancedAudioPlayer(
            controller: _audioPlayerController,
            loading: audioLoadding,
          ),
        // 聊天内容窗口
        Expanded(
          child: BlocConsumer<ChatMessageBloc, ChatMessageState>(
            listener: (context, state) {
              if (state is ChatAnywhereInited) {
                setState(() {
                  chatId = state.chatId;
                });
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
                if (!state.processing && _scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                }

                if (state.processing && _inputEnabled.value) {
                  // 聊天回复中时，禁止输入框编辑
                  setState(() {
                    _inputEnabled.value = false;
                  });
                } else if (!state.processing && !_inputEnabled.value) {
                  // 更新免费使用次数
                  context.read<FreeCountBloc>().add(FreeCountReloadEvent(
                      model: widget.model ?? room.room.model));

                  // 聊天回复完成时，取消输入框的禁止编辑状态
                  setState(() {
                    _inputEnabled.value = true;
                  });
                }
              }
            },
            buildWhen: (prv, cur) => cur is ChatMessagesLoaded,
            builder: (context, state) {
              if (state is ChatMessagesLoaded) {
                return _buildChatPreviewArea(
                  state,
                  room.examples ?? [],
                  room,
                  customColors,
                  _chatPreviewController.selectMode,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),

        // 聊天输入窗口
        if (!_chatPreviewController.selectMode)
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
                    hintText += '（今日还可免费畅享${matched.leftCount}次）';
                  }
                }

                return SafeArea(
                  child: BlocBuilder<ChatMessageBloc, ChatMessageState>(
                    buildWhen: (previous, current) =>
                        current is ChatMessagesLoaded,
                    builder: (context, state) {
                      var enableImageUpload = false;
                      if (state is ChatMessagesLoaded) {
                        var model = state.chatHistory?.model ?? room.room.model;
                        final cur = supportModels
                            .where((e) => e.id == model)
                            .firstOrNull;
                        enableImageUpload = cur?.supportVision ?? false;
                      }

                      return ChatInput(
                        enableNotifier: _inputEnabled,
                        onSubmit: (value) {
                          _handleSubmit(value);
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
                          _audioPlayerController.stop();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

        // 选择模式工具栏
        if (_chatPreviewController.selectMode)
          buildSelectModeToolbars(
            context,
            _chatPreviewController,
            customColors,
          ),
      ],
    );
  }

  /// 构建聊天内容窗口
  Widget _buildChatPreviewArea(
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
        onSubmit: _handleSubmit,
      );
    }

    final messages = loadedMessages.map((e) {
      if (loadedState.chatHistory != null &&
          loadedState.chatHistory!.model != null) {
        final mod = supportModels
            .where((e) => e.id == loadedState.chatHistory!.model!)
            .firstOrNull;
        if (mod != null) {
          e.senderName = mod.shortName;
          e.avatarUrl = mod.avatarUrl;
        }
      }

      final stateMessage =
          room.states[widget.stateManager.getKey(e.roomId ?? 0, e.id ?? 0)] ??
              MessageState();
      return MessageWithState(e, stateMessage);
    }).toList();

    _chatPreviewController.setAllMessageIds(messages);

    return ChatPreview(
      messages: messages,
      scrollController: _scrollController,
      controller: _chatPreviewController,
      stateManager: widget.stateManager,
      robotAvatar: selectMode
          ? null
          : _buildAvatar(room.room, his: loadedState.chatHistory),
      onDeleteMessage: (id) {
        handleDeleteMessage(context, id, chatHistoryId: chatId);
      },
      onResetContext: () => handleResetContext(context),
      onResentEvent: (message, index) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

        _handleSubmit(message.text,
            messagetType: message.type, index: index, isResent: true);
      },
      onSpeakEvent: (message) {
        _audioPlayerController.playAudio(message.text);
      },
      helpWidgets: loadedState.processing || loadedMessages.last.isInitMessage()
          ? null
          : [HelpTips(onSubmitMessage: _handleSubmit)],
    );
  }

  /// 提交新消息
  void _handleSubmit(
    String text, {
    messagetType = MessageType.text,
    int? index,
    bool isResent = false,
  }) async {
    setState(() {
      _inputEnabled.value = false;
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
        final uploader = ImageUploader(widget.setting);

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
              model: widget.model,
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
    context.read<NotifyBloc>().add(NotifyResetEvent());
    // ignore: use_build_context_synchronously
    context
        .read<RoomBloc>()
        .add(RoomLoadEvent(chatAnywhereRoomId, cascading: false));
  }

  Widget _buildAvatar(Room room, {ChatHistory? his}) {
    if (room.avatarUrl != null && room.avatarUrl!.startsWith('http')) {
      return RemoteAvatar(avatarUrl: room.avatarUrl!, size: 30);
    }

    if (his != null && his.model != null) {
      var mod = supportModels.where((e) => e.id == his.model!).firstOrNull;
      if (mod != null && mod.avatarUrl != null && mod.avatarUrl != '') {
        return RemoteAvatar(avatarUrl: mod.avatarUrl!, size: 30);
      }
    }

    return const LocalAvatar(assetName: 'assets/app.png', size: 30);
  }
}
