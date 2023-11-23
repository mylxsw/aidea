import 'dart:async';

import 'package:askaide/bloc/group_chat_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/component/group_empty.dart';
import 'package:askaide/page/component/audio_player.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/chat_share.dart';
import 'package:askaide/page/component/chat/help_tips.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/component/enhanced_popup_menu.dart';
import 'package:askaide/page/component/multi_item_selector.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/chat/chat_input.dart';
import 'package:askaide/page/component/chat/chat_preview.dart';
import 'package:askaide/repo/model/group.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class GroupChatPage extends StatefulWidget {
  final SettingRepository setting;
  final int groupId;
  final MessageStateManager stateManager;

  const GroupChatPage({
    super.key,
    required this.setting,
    required this.groupId,
    required this.stateManager,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _inputEnabled = ValueNotifier(true);
  final ChatPreviewController _chatPreviewController = ChatPreviewController();
  final AudioPlayerController _audioPlayerController =
      AudioPlayerController(useRemoteAPI: true);
  bool showAudioPlayer = false;
  bool audioLoadding = false;

  List<GroupMember>? selectedMembers = [];
  List<GroupMessage> messages = [];

  ChatGroup? group;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    context.read<GroupChatBloc>().add(GroupChatLoadEvent(widget.groupId));

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
    timer?.cancel();
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

  Widget _buildChatComponents(CustomColors customColors) {
    return BlocConsumer<GroupChatBloc, GroupChatState>(
      listenWhen: (previous, current) =>
          current is GroupChatLoaded || current is GroupDefaultMemberSelected,
      listener: (context, state) {
        if (state is GroupChatLoaded) {
          // 加载聊天记录列表
          context.read<GroupChatBloc>().add(
              GroupChatMessagesLoadEvent(widget.groupId, isInitRequest: true));

          // 选中默认的聊天成员
          selectedMembers = state.group.members
              .where((e) => state.defaultChatMembers?.contains(e.id) ?? false)
              .toList();

          setState(() {
            group = state.group;
          });
        }

        if (state is GroupDefaultMemberSelected) {
          // 选中默认的聊天成员
          if (group != null) {
            selectedMembers = group?.members
                .where((e) => state.members.contains(e.id))
                .toList();
          }
        }
      },
      buildWhen: (previous, current) => current is GroupChatLoaded,
      builder: (context, groupState) {
        if (groupState is GroupChatLoaded) {
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
                    groupState,
                    customColors,
                    _chatPreviewController.selectMode,
                  ),
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
                  child: SafeArea(
                    child: _chatPreviewController.selectMode
                        ? buildSelectModeToolbars(
                            context,
                            _chatPreviewController,
                            customColors,
                          )
                        : ChatInput(
                            enableNotifier: _inputEnabled,
                            enableImageUpload: false,
                            onSubmit: (value) {
                              _handleSubmit(value);
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            onNewChat: () => handleResetContext(context),
                            hintText: '有问题尽管问我',
                            onVoiceRecordTappedEvent: () {
                              _audioPlayerController.stop();
                            },
                            leftSideToolsBuilder: () {
                              return [
                                Stack(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      padding: const EdgeInsets.all(5),
                                      child: InkWell(
                                        onTap: () {
                                          onModelSelect(
                                            context,
                                            groupState,
                                            customColors,
                                          );
                                        },
                                        child: Icon(
                                          Icons.alternate_email,
                                          color: selectedMembers != null &&
                                                  selectedMembers!.isNotEmpty
                                              ? customColors.linkColor
                                              : customColors.chatInputPanelText,
                                        ),
                                      ),
                                    ),
                                    if (selectedMembers != null &&
                                        selectedMembers!.isNotEmpty)
                                      Positioned(
                                        right: 2,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 3),
                                          child: Text(
                                              'x${selectedMembers!.length}',
                                              style: TextStyle(
                                                fontSize: 7,
                                                color: customColors.linkColor,
                                              )),
                                        ),
                                      ),
                                  ],
                                )
                              ];
                            },
                          ),
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

  void onModelSelect(
    BuildContext context,
    GroupChatLoaded groupState,
    CustomColors customColors,
  ) {
    openModalBottomSheet(
      context,
      (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15, left: 20),
              child: Text(
                '选择本次对话成员',
                style: TextStyle(
                  fontSize: 14,
                  color: customColors.weakLinkColor,
                ),
              ),
            ),
            Expanded(
              child: MultiItemSelector(
                itemBuilder: (item) {
                  return Text(item.modelName);
                },
                items: groupState.group.members
                    .where((e) => e.status != 2)
                    .toList(),
                onChanged: (selected) {
                  setState(() {
                    selectedMembers = selected;
                  });
                },
                itemAvatarBuilder: (item) {
                  return _buildAvatar(
                    avatarUrl: item.avatarUrl,
                    id: item.id,
                    size: 30,
                  );
                },
                selectedItems: selectedMembers,
              ),
            ),
          ],
        );
      },
      heightFactor: 0.6,
    );
  }

  BlocConsumer<GroupChatBloc, GroupChatState> _buildChatPreviewArea(
    GroupChatLoaded group,
    CustomColors customColors,
    bool selectMode,
  ) {
    return BlocConsumer<GroupChatBloc, GroupChatState>(
      listenWhen: (previous, current) => current is GroupChatMessagesLoaded,
      listener: (context, state) {
        if (state is GroupChatMessagesLoaded) {
          if (state.error != null) {
            showErrorMessageEnhanced(context, state.error);
          }

          messages = state.messages;

          // 聊天内容窗口滚动到底部
          if (!state.hasWaitTasks && _scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }

          if (state.hasWaitTasks && _inputEnabled.value) {
            // 聊天回复中时，禁止输入框编辑
            setState(() {
              _inputEnabled.value = false;
            });
          } else if (!state.hasWaitTasks && !_inputEnabled.value) {
            // 聊天回复完成时，取消输入框的禁止编辑状态
            setState(() {
              _inputEnabled.value = true;
            });
          }

          // 启动定时器，定时刷新聊天记录
          timer ??= Timer.periodic(const Duration(seconds: 3), (timer) {
            context
                .read<GroupChatBloc>()
                .add(GroupChatUpdateMessageStatusEvent(widget.groupId));
          });
        }
      },
      buildWhen: (prv, cur) => cur is GroupChatMessagesLoaded,
      builder: (context, state) {
        if (state is GroupChatMessagesLoaded) {
          if (state.messages.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10),
              child: GroupEmptyBoard(),
            );
          }

          final loadedMessages = state.messages.map((e) {
            var member =
                e.memberId != null ? group.group.findMember(e.memberId!) : null;

            return Message(
              id: e.id,
              Role.getRoleFromText(e.role),
              e.message,
              type: MessageType.getTypeFromText(e.type),
              status: e.status,
              refId: e.pid,
              ts: e.createdAt,
              avatarUrl: member?.avatarUrl,
              senderName: member?.modelName,
              roomId: e.groupId,
            );
          }).toList();

          final messages = loadedMessages.map((e) {
            return MessageWithState(
              e,
              group.states[
                      widget.stateManager.getKey(e.roomId ?? 0, e.id ?? 0)] ??
                  MessageState(),
            );
          }).toList();

          _chatPreviewController.setAllMessageIds(messages);

          return ChatPreview(
            supportBloc: false,
            messages: messages,
            scrollController: _scrollController,
            controller: _chatPreviewController,
            stateManager: widget.stateManager,
            robotAvatar: selectMode
                ? null
                : _buildAvatar(
                    avatarUrl: group.group.group.avatarUrl,
                    id: group.group.group.id,
                  ),
            avatarBuilder: selectMode
                ? null
                : (Message message) {
                    if (message.avatarUrl == null) {
                      return null;
                    }

                    return _buildAvatar(avatarUrl: message.avatarUrl!);
                  },
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
              _handleSubmit(message.text, index: index, isResent: true);
            },
            helpWidgets: state.hasWaitTasks || loadedMessages.isEmpty
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
            title: BlocBuilder<GroupChatBloc, GroupChatState>(
              buildWhen: (previous, current) => current is GroupChatLoaded,
              builder: (context, state) {
                if (state is GroupChatLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 房间名称
                      Text(
                        state.group.group.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                }

                return Container();
              },
            ),
            actions: [
              buildChatMoreMenu(context, widget.groupId),
            ],
            toolbarHeight: CustomSize.toolbarHeight,
          );
  }

  Widget _buildAvatar({String? avatarUrl, int? id, int size = 30}) {
    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return RemoteAvatar(
        avatarUrl: imageURL(avatarUrl, qiniuImageTypeAvatar),
        size: size,
      );
    }

    return RandomAvatar(
      id: id ?? 0,
      size: size,
      usage:
          Ability().enableAPIServer() ? AvatarUsage.room : AvatarUsage.legacy,
    );
  }

  /// 提交新消息
  void _handleSubmit(
    String text, {
    int? index,
    bool isResent = false,
  }) {
    setState(() {
      _inputEnabled.value = false;
    });

    var replyMemberIds = (selectedMembers ?? []).map((e) => e.id!).toList();
    context.read<GroupChatBloc>().add(GroupChatSendEvent(
          widget.groupId,
          text,
          replyMemberIds,
          index: index,
          isResent: isResent,
        ));
  }

  /// 处理消息删除事件
  void handleDeleteMessage(BuildContext context, int id, {int? chatHistoryId}) {
    openConfirmDialog(
      context,
      AppLocale.confirmDelete.getString(context),
      () {
        context
            .read<GroupChatBloc>()
            .add(GroupChatDeleteEvent(widget.groupId, id));
        HapticFeedbackHelper.mediumImpact();
      },
      danger: true,
    );
  }

  /// 重置上下文
  void handleResetContext(BuildContext context) {
    context.read<GroupChatBloc>().add(GroupChatSendSystemEvent(
          widget.groupId,
          MessageType.contextBreak,
          message: 'context-break-message',
        ));
    HapticFeedbackHelper.mediumImpact();
  }

  /// 清空历史消息
  void handleClearHistory(BuildContext context) {
    openConfirmDialog(
      context,
      AppLocale.confirmClearMessages.getString(context),
      () {
        context
            .read<GroupChatBloc>()
            .add(GroupChatDeleteAllEvent(widget.groupId));
        HapticFeedbackHelper.mediumImpact();
      },
      danger: true,
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
              // var shareText = messages.map((e) {
              //   if (e.message.role == Role.sender) {
              //     return '我：\n${e.message.text}';
              //   }

              //   return '${e.message.senderName ?? "助理"}：\n${e.message.text}';
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
            icon:
                Icon(Icons.select_all_outlined, color: customColors.linkColor),
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
                    // context
                    //     .read<ChatMessageBloc>()
                    //     .add(ChatMessageDeleteEvent(ids));

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
              context.push('/group-chat/$chatRoomId/edit').whenComplete(() {
                context
                    .read<GroupChatBloc>()
                    .add(GroupChatLoadEvent(widget.groupId, forceUpdate: true));
              });
            },
          ),
      ],
    );
  }
}
