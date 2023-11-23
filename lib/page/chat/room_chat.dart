import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/audio_player.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/chat_share.dart';
import 'package:askaide/page/component/chat/empty.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/help_tips.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/component/effect/glass.dart';
import 'package:askaide/page/component/enhanced_popup_menu.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/bloc/notify_bloc.dart';
import 'package:askaide/page/component/chat/chat_input.dart';
import 'package:askaide/page/component/chat/chat_preview.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:askaide/repo/model/model.dart' as mm;

import '../component/dialog.dart';

class RoomChatPage extends StatefulWidget {
  final int roomId;
  final MessageStateManager stateManager;
  final SettingRepository setting;

  const RoomChatPage({
    super.key,
    required this.roomId,
    required this.stateManager,
    required this.setting,
  });

  @override
  State<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends State<RoomChatPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _inputEnabled = ValueNotifier(true);
  final ChatPreviewController _chatPreviewController = ChatPreviewController();
  final AudioPlayerController _audioPlayerController =
      AudioPlayerController(useRemoteAPI: true);
  bool showAudioPlayer = false;
  bool audioLoadding = false;

  List<FileUpload> selectedImageFiles = [];

  @override
  void initState() {
    super.initState();

    context.read<ChatMessageBloc>().add(ChatMessageGetRecentEvent());
    context.read<RoomBloc>().add(RoomLoadEvent(widget.roomId, cascading: true));

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
        appBar: _buildAppBar(context, customColors),
        backgroundColor: Colors.transparent,
        body: _buildChatComponents(customColors),
      ),
    );
  }

  mm.Model? roomModel;

  Widget _buildChatComponents(CustomColors customColors) {
    return BlocConsumer<RoomBloc, RoomState>(
      listenWhen: (previous, current) => current is RoomLoaded,
      listener: (context, state) {
        if (state is RoomLoaded && state.cascading) {
          // 加载免费使用次数
          context
              .read<FreeCountBloc>()
              .add(FreeCountReloadEvent(model: state.room.model));
        }

        if (state is RoomLoaded) {
          ModelAggregate.model(state.room.model).then((value) {
            setState(() {
              roomModel = value;
            });
          });
        }
      },
      buildWhen: (previous, current) => current is RoomLoaded,
      builder: (context, room) {
        if (room is RoomLoaded) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                // 语音输出中提示
                if (showAudioPlayer)
                  EnhancedAudioPlayer(
                    controller: _audioPlayerController,
                    loading: audioLoadding,
                  ),
                // 聊天内容窗口
                Expanded(
                  child: _buildChatPreviewArea(
                      room, customColors, _chatPreviewController.selectMode),
                ),

                // 聊天输入窗口
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
                        child: _chatPreviewController.selectMode
                            ? buildSelectModeToolbars(
                                context,
                                _chatPreviewController,
                                customColors,
                              )
                            : ChatInput(
                                enableNotifier: _inputEnabled,
                                onSubmit: (value) {
                                  _handleSubmit(value);
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                enableImageUpload: roomModel != null &&
                                    roomModel!.supportVision,
                                onImageSelected: (files) {
                                  setState(() {
                                    selectedImageFiles = files;
                                  });
                                },
                                selectedImageFiles: selectedImageFiles,
                                onNewChat: () => handleResetContext(context),
                                hintText: hintText,
                                onVoiceRecordTappedEvent: () {
                                  _audioPlayerController.stop();
                                },
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  BlocConsumer<ChatMessageBloc, ChatMessageState> _buildChatPreviewArea(
    RoomLoaded room,
    CustomColors customColors,
    bool selectMode,
  ) {
    return BlocConsumer<ChatMessageBloc, ChatMessageState>(
      listener: (context, state) {
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
            context
                .read<FreeCountBloc>()
                .add(FreeCountReloadEvent(model: room.room.model));

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
          final loadedMessages = state.messages as List<Message>;
          if (room.room.initMessage != null &&
              room.room.initMessage != '' &&
              loadedMessages.isEmpty) {
            loadedMessages.add(
              Message(
                Role.receiver,
                room.room.initMessage!,
                type: MessageType.initMessage,
                id: 0,
              ),
            );
          }

          if (loadedMessages.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: EmptyPreview(
                examples: room.examples ?? [],
                onSubmit: _handleSubmit,
              ),
            );
          }

          final messages = loadedMessages.map((e) {
            e.avatarUrl = room.room.avatarUrl;
            e.senderName = room.room.name;

            return MessageWithState(
              e,
              room.states[
                      widget.stateManager.getKey(e.roomId ?? 0, e.id ?? 0)] ??
                  MessageState(),
            );
          }).toList();

          _chatPreviewController.setAllMessageIds(messages);

          return ChatPreview(
            messages: messages,
            scrollController: _scrollController,
            controller: _chatPreviewController,
            stateManager: widget.stateManager,
            robotAvatar: selectMode ? null : _buildAvatar(room.room),
            onDeleteMessage: (id) {
              handleDeleteMessage(context, id);
            },
            onResetContext: () => handleResetContext(context),
            onSpeakEvent: (message) {
              _audioPlayerController.playAudio(message.text);
            },
            onResentEvent: (message, index) {
              _scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut);
              _handleSubmit(message.text,
                  messagetType: message.type, index: index, isResent: true);
            },
            helpWidgets: state.processing || loadedMessages.last.isInitMessage()
                ? null
                : [
                    HelpTips(
                      onSubmitMessage: _handleSubmit,
                      onNewChat: () => handleResetContext(context),
                    )
                  ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// 构建 AppBar
  AppBar _buildAppBar(BuildContext context, CustomColors customColors) {
    return _chatPreviewController.selectMode
        ? AppBar(
            title: Text(
              AppLocale.select.getString(context),
              style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
            ),
            centerTitle: true,
            elevation: 0,
            leading: TextButton(
              onPressed: () {
                _chatPreviewController.exitSelectMode();
              },
              child: Text(
                AppLocale.cancel.getString(context),
                style: TextStyle(color: customColors.linkColor),
              ),
            ),
            toolbarHeight: CustomSize.toolbarHeight,
          )
        : AppBar(
            centerTitle: true,
            elevation: 0,
            // backgroundColor: customColors.chatRoomBackground,
            title: BlocBuilder<RoomBloc, RoomState>(
              buildWhen: (previous, current) => current is RoomLoaded,
              builder: (context, state) {
                if (state is RoomLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 房间名称
                      Text(
                        state.room.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      // BlocBuilder<FreeCountBloc, FreeCountState>(
                      //   buildWhen: (previous, current) =>
                      //       current is FreeCountLoadedState,
                      //   builder: (context, freeState) {
                      //     if (freeState is FreeCountLoadedState) {
                      //       final matched = freeState.model(state.room.model);
                      //       if (matched != null &&
                      //           matched.leftCount > 0 &&
                      //           matched.maxCount > 0) {
                      //         return Text(
                      //           '今日剩余免费 ${matched.leftCount} 次',
                      //           style: TextStyle(
                      //             color: customColors.weakTextColor,
                      //             fontSize: 12,
                      //           ),
                      //         );
                      //       }
                      //     }
                      //     return const SizedBox();
                      //   },
                      // ),
                      // 模型名称
                      // Text(
                      //   state.room.model.split(':').last,
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Theme.of(context).textTheme.bodySmall!.color,
                      //   ),
                      // ),
                    ],
                  );
                }

                return Container();
              },
            ),
            actions: [
              buildChatMoreMenu(context, widget.roomId),
            ],
            toolbarHeight: CustomSize.toolbarHeight,
          );
  }

  Widget _buildAvatar(Room room) {
    if (room.avatarUrl != null && room.avatarUrl!.startsWith('http')) {
      return RemoteAvatar(
        avatarUrl: imageURL(room.avatarUrl!, qiniuImageTypeAvatar),
        size: 30,
      );
    }

    return Initicon(
      text: room.name.split('、').join(' '),
      size: 30,
      backgroundColor: Colors.grey.withAlpha(100),
      borderRadius: BorderRadius.circular(8),
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
              type: messagetType,
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
        .add(RoomLoadEvent(widget.roomId, cascading: false));
  }
}

/// 处理消息删除事件
void handleDeleteMessage(BuildContext context, int id, {int? chatHistoryId}) {
  openConfirmDialog(
    context,
    AppLocale.confirmDelete.getString(context),
    () => context
        .read<ChatMessageBloc>()
        .add(ChatMessageDeleteEvent([id], chatHistoryId: chatHistoryId)),
    danger: true,
  );
}

/// 重置上下文
void handleResetContext(BuildContext context) {
  // openConfirmDialog(
  //   context,
  //   AppLocale.confirmStartNewChat.getString(context),
  //   () {
  context.read<ChatMessageBloc>().add(ChatMessageBreakContextEvent());
  HapticFeedbackHelper.mediumImpact();
  //   },
  // );
}

/// 清空历史消息
void handleClearHistory(BuildContext context) {
  openConfirmDialog(
    context,
    AppLocale.confirmClearMessages.getString(context),
    () {
      context.read<ChatMessageBloc>().add(ChatMessageClearAllEvent());
      showSuccessMessage(AppLocale.operateSuccess.getString(context));
      HapticFeedbackHelper.mediumImpact();
    },
    danger: true,
  );
}

/// 打开示例问题列表
void handleOpenExampleQuestion(
  BuildContext context,
  Room room,
  List<ChatExample> examples,
  Function(String text) onSubmit,
) {
  final customColors = Theme.of(context).extension<CustomColors>()!;

  openModalBottomSheet(
    context,
    (context) {
      return FractionallySizedBox(
        heightFactor: 0.8,
        child: GlassEffect(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Text(
                  AppLocale.examples.getString(context),
                  textScaleFactor: 1.2,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: examples.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: customColors.chatExampleItemBackground,
                        ),
                        child: Column(
                          children: [
                            Text(
                              examples[i].title,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: customColors.chatExampleItemText,
                              ),
                            ),
                            if (examples[i].content != null)
                              const SizedBox(height: 5),
                            if (examples[i].content != null)
                              Text(
                                examples[i].content!,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: customColors.chatExampleItemText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      onTap: () {
                        final controller = TextEditingController();
                        controller.text = examples[i].text;

                        openDialog(
                          context,
                          title: Text(
                            AppLocale.confirmSend.getString(context),
                            textAlign: TextAlign.left,
                            textScaleFactor: 0.8,
                          ),
                          builder: Builder(
                            builder: (context) {
                              return EnhancedTextField(
                                controller: controller,
                                maxLines: 5,
                                maxLength: 4000,
                                customColors: customColors,
                              );
                            },
                          ),
                          onSubmit: () {
                            onSubmit(controller.text.trim());
                            return true;
                          },
                          afterSubmit: () => context.pop(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 构建聊天内容窗口
Widget buildSelectModeToolbars(
  BuildContext context,
  ChatPreviewController chatPreviewController,
  CustomColors customColors,
) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      color: customColors.backgroundColor,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          onPressed: () {
            var messages = chatPreviewController.selectedMessages();
            if (messages.isEmpty) {
              showErrorMessageEnhanced(
                  context, AppLocale.noMessageSelected.getString(context));
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => ChatShareScreen(
                  messages: messages
                      .map((e) => ChatShareMessage(
                            content: e.message.text,
                            username: e.message.senderName,
                            avatarURL: e.message.avatarUrl,
                            leftSide: e.message.role == Role.receiver,
                            images: e.message.images,
                          ))
                      .toList(),
                ),
              ),
            );
            // var messages = chatPreviewController.selectedMessages();
            // if (messages.isEmpty) {
            //   showErrorMessageEnhanced(
            //       context, AppLocale.noMessageSelected.getString(context));
            //   return;
            // }
            // var shareText = messages.map((e) {
            //   if (e.message.role == Role.sender) {
            //     return '我：\n${e.message.text}';
            //   }

            //   return '助理：\n${e.message.text}';
            // }).join('\n\n');

            // shareTo(
            //   context,
            //   content: shareText,
            //   title: AppLocale.chatHistory.getString(context),
            // );
          },
          icon: Icon(Icons.share, color: customColors.linkColor),
          label: Text(
            AppLocale.share.getString(context),
            style: TextStyle(color: customColors.linkColor),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            chatPreviewController.selectAllMessage();
          },
          icon: Icon(Icons.select_all_outlined, color: customColors.linkColor),
          label: Text(
            AppLocale.selectAll.getString(context),
            style: TextStyle(color: customColors.linkColor),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            if (chatPreviewController.selectedMessageIds.isEmpty) {
              showErrorMessageEnhanced(
                  context, AppLocale.noMessageSelected.getString(context));
              return;
            }

            openConfirmDialog(
              context,
              AppLocale.confirmDelete.getString(context),
              () {
                final ids = chatPreviewController.selectedMessageIds.toList();
                if (ids.isNotEmpty) {
                  context
                      .read<ChatMessageBloc>()
                      .add(ChatMessageDeleteEvent(ids));

                  showErrorMessageEnhanced(
                      context, AppLocale.operateSuccess.getString(context));

                  chatPreviewController.exitSelectMode();
                }
              },
              danger: true,
            );
          },
          icon: Icon(Icons.delete, color: customColors.linkColor),
          label: Text(
            AppLocale.delete.getString(context),
            style: TextStyle(color: customColors.linkColor),
          ),
        ),
      ],
    ),
  );
}

/// 构建聊天设置下拉菜单
Widget buildChatMoreMenu(
  BuildContext context,
  int chatRoomId, {
  bool useLocalContext = true,
  bool withSetting = true,
}) {
  var customColors = Theme.of(context).extension<CustomColors>()!;

  return EnhancedPopupMenu(
    items: [
      EnhancedPopupMenuItem(
        title: AppLocale.newChat.getString(context),
        icon: Icons.post_add,
        iconColor: Colors.blue,
        onTap: (ctx) {
          handleResetContext(useLocalContext ? ctx : context);
        },
      ),
      EnhancedPopupMenuItem(
        title: AppLocale.clearChatHistory.getString(context),
        icon: Icons.delete_forever,
        iconColor: Colors.red,
        onTap: (ctx) {
          handleClearHistory(useLocalContext ? ctx : context);
        },
      ),
      if (withSetting)
        EnhancedPopupMenuItem(
          title: AppLocale.settings.getString(context),
          icon: Icons.settings,
          iconColor: customColors.linkColor,
          onTap: (_) {
            context.push('/room/$chatRoomId/setting');
          },
        ),
    ],
  );
}
