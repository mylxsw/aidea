import 'dart:async';
import 'dart:convert';

import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/attached_button_panel.dart';
import 'package:askaide/page/component/chat/chat_share.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/chat/markdown.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ChatPreview extends StatefulWidget {
  final List<MessageWithState> messages;
  final ScrollController? scrollController;
  final void Function(int id)? onDeleteMessage;
  final void Function()? onResetContext;
  final ChatPreviewController controller;
  final MessageStateManager stateManager;
  final List<Widget>? helpWidgets;
  final Widget? robotAvatar;
  final Widget? Function(Message message)? avatarBuilder;
  final Widget? Function(Message message)? senderNameBuilder;
  final bool supportBloc;
  final void Function(Message message)? onSpeakEvent;
  final void Function(Message message, int index)? onResentEvent;

  const ChatPreview({
    super.key,
    required this.messages,
    this.scrollController,
    this.onDeleteMessage,
    this.onResetContext,
    required this.controller,
    required this.stateManager,
    this.robotAvatar,
    this.avatarBuilder,
    this.senderNameBuilder,
    this.helpWidgets,
    this.onSpeakEvent,
    this.onResentEvent,
    this.supportBloc = true,
  });

  @override
  State<ChatPreview> createState() => _ChatPreviewState();
}

class _ChatPreviewState extends State<ChatPreview> {
  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    var messages = widget.messages.reversed.toList();

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: messages.length,
      shrinkWrap: true,
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: MediaQuery.of(context).size.height * 10,
      itemBuilder: (context, index) {
        final message = messages[index];

        return Column(
          children: [
            // 消息类型为 hide，不展示
            if (message.message.type == MessageType.hide) Container(),

            if (message.message.type != MessageType.hide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 消息选择模式，显示选择框
                  if (widget.controller.selectMode &&
                      !message.message.isSystem())
                    Checkbox(
                      value: widget.controller
                          .isMessageSelected(message.message.id!),
                      activeColor: customColors.linkColor,
                      onChanged: (value) {
                        if (value != null && value) {
                          widget.controller.selectMessage(message.message.id!);
                        } else {
                          widget.controller
                              .unSelectMessage(message.message.id!);
                        }
                      },
                    ),

                  // 消息主体部分
                  Expanded(
                    child: widget.supportBloc
                        ? BlocBuilder<ChatMessageBloc, ChatMessageState>(
                            buildWhen: (previous, current) =>
                                (current is ChatMessageUpdated &&
                                    current.message.id == message.message.id),
                            builder: (context, state) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: _buildMessageBox(
                                  context,
                                  customColors,
                                  _resolveMessage(state, message),
                                  message.state,
                                  index,
                                ),
                              );
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: _buildMessageBox(
                              context,
                              customColors,
                              message.message,
                              message.state,
                              index,
                            ),
                          ),
                  ),
                ],
              ),

            if (index == 0 &&
                widget.helpWidgets != null &&
                !message.message.isSystem())
              for (var widget in widget.helpWidgets!) widget,
          ],
        );
      },
    );
  }

  Message _resolveMessage(ChatMessageState state, MessageWithState message) {
    if (state is ChatMessageUpdated && state.message.id == message.message.id) {
      return state.message;
    }

    return message.message;
  }

  /// 构建消息框
  Widget _buildMessageBox(
    BuildContext context,
    CustomColors customColors,
    Message message,
    MessageState state,
    int index,
  ) {
    // 系统消息
    if (message.isSystem()) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 5,
          ),
          child: Text(
            message.isTimeline()
                ? message.friendlyTime()
                : message.text.getString(context),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final showTranslate = state.showTranslate &&
        state.translateText != null &&
        state.translateText != '';

    final extra = index == 0 ? message.decodeExtra() : null;
    final extraInfo = extra != null ? extra['info'] ?? '' : '';

    // 普通消息
    return Align(
      alignment:
          message.role == Role.sender ? Alignment.topRight : Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _chatBoxMaxWidth(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.images != null && message.images!.isNotEmpty)
              Container(
                margin: message.role == Role.sender
                    ? const EdgeInsets.fromLTRB(0, 0, 10, 7)
                    : const EdgeInsets.fromLTRB(10, 0, 0, 7),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _chatBoxImagePreviewWidth(
                      context,
                      (message.images ?? []).length,
                    ),
                  ),
                  child: FileUploadPreview(images: message.images ?? []),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 消息头像
                buildAvatar(message),
                // 消息内容部分
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _chatBoxMaxWidth(context) - 80,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 发送人名称
                      if (message.role == Role.receiver &&
                          widget.senderNameBuilder != null)
                        widget.senderNameBuilder!(message) ?? const SizedBox(),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          // 错误指示器
                          if (message.role == Role.sender &&
                              message.statusIsFailed())
                            buildErrorIndicator(message, state, context, index),
                          // 消息主体
                          GestureDetector(
                            // 选择模式下，单击切换选择与否
                            // 非选择模式下，单击隐藏键盘
                            onTap: () {
                              if (widget.controller.selectMode) {
                                widget.controller
                                    .toggleMessageSelected(message.id!);
                              }
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            // 长按或者双击显示上下文菜单
                            onLongPressStart: (detail) {
                              _handleMessageTapControl(
                                context,
                                detail.globalPosition,
                                message,
                                state,
                                index,
                              );
                            },
                            onDoubleTapDown: (details) {
                              _handleMessageTapControl(
                                context,
                                details.globalPosition,
                                message,
                                state,
                                index,
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  margin: message.role == Role.sender
                                      ? const EdgeInsets.fromLTRB(0, 0, 10, 7)
                                      : const EdgeInsets.fromLTRB(10, 0, 0, 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: message.role == Role.receiver
                                        ? customColors.chatRoomReplyBackground
                                        : customColors.chatRoomSenderBackground,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      if ((message.statusPending() ||
                                              !message.isReady) &&
                                          message.text.isEmpty) {
                                        return LoadingAnimationWidget.waveDots(
                                          color: customColors.weakLinkColor!,
                                          size: 25,
                                        );
                                      }

                                      var text = message.text;
                                      if (!message.isReady && text != '') {
                                        text += ' ▌';
                                      }
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          state.showMarkdown
                                              ? Markdown(
                                                  data: text.trim(),
                                                  onUrlTap: (value) =>
                                                      launchUrlString(value),
                                                )
                                              : SelectableText(
                                                  text,
                                                  style: TextStyle(
                                                    color: customColors
                                                        .chatRoomSenderText,
                                                  ),
                                                ),
                                          if (message.quotaConsumed != null &&
                                              message.quotaConsumed! > 0)
                                            Row(
                                              children: [
                                                const Icon(Icons.check_circle,
                                                    size: 12,
                                                    color: Colors.green),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    '共 ${message.tokenConsumed} 个 Token， 消耗 ${message.quotaConsumed} 个智慧果',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: customColors
                                                          .weakTextColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                if (extraInfo.isNotEmpty)
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: InkWell(
                                      onTap: () {
                                        showCustomBeautyDialog(
                                          context,
                                          type: QuickAlertType.warning,
                                          confirmBtnText: AppLocale.gotIt
                                              .getString(context),
                                          showCancelBtn: false,
                                          title: '温馨提示',
                                          child: Markdown(
                                            data: extraInfo,
                                            onUrlTap: (value) {
                                              onMarkdownUrlTap(value);
                                              context.pop();
                                            },
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              color: customColors
                                                  .dialogDefaultTextColor,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: customColors.weakLinkColor
                                            ?.withAlpha(50),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (showTranslate)
                        Container(
                          margin: message.role == Role.sender
                              ? const EdgeInsets.fromLTRB(7, 10, 14, 7)
                              : const EdgeInsets.fromLTRB(10, 10, 0, 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: message.role == Role.receiver
                                ? customColors.chatRoomReplyBackgroundSecondary
                                : customColors
                                    .chatRoomSenderBackgroundSecondary,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Builder(
                            builder: (context) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  state.showMarkdown
                                      ? Markdown(data: state.translateText!)
                                      : SelectableText(
                                          state.translateText!,
                                          style: TextStyle(
                                            color:
                                                customColors.chatRoomSenderText,
                                          ),
                                        ),
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 12,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '翻译完成',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 145, 145, 145),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildErrorIndicator(
    Message message,
    MessageState state,
    BuildContext context,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 5, bottom: 10),
      child: GestureDetector(
        onTapUp: (details) {
          if (widget.controller.selectMode || message.isSystem()) {
            return;
          }

          HapticFeedbackHelper.mediumImpact();

          var confirmMessage = '';
          if (message.extra != null && message.extra!.isNotEmpty) {
            try {
              final extra = jsonDecode(message.extra!);
              if (extra['error'] != null && extra['error'] != '') {
                var e1 = extra['error'];
                try {
                  if (e1 is LanguageText) {
                    e1 = (e1 as String).getString(context);
                  }
                  // ignore: empty_catches
                } catch (ignored) {}
                confirmMessage = e1;
              }
              // ignore: empty_catches
            } catch (ignored) {}
          }

          openConfirmDialog(
            context,
            confirmMessage,
            () {
              widget.onResentEvent!(message, index);
            },
            title: Text(AppLocale.robotHasSomeError.getString(context)),
            confirmText: '重新发送',
          );
        },
        child: const Icon(Icons.error, color: Colors.red, size: 20),
      ),
    );
  }

  void onMarkdownUrlTap(value) {
    if (value.startsWith("aidea-app://")) {
      var route = value.substring('aidea-app://'.length);
      context.push(route);
    } else if (value.startsWith("aidea-command://")) {
      var command = value.substring('aidea-command://'.length);
      switch (command) {
        case "reset-context":
          if (widget.onResetContext != null) {
            widget.onResetContext!();
          }
          break;
      }
    } else {
      launchUrlString(value);
    }
  }

  Widget buildAvatar(Message message) {
    if (widget.avatarBuilder != null) {
      final avatar = widget.avatarBuilder!(message);
      if (avatar != null) {
        return avatar;
      }
    }

    if (widget.robotAvatar != null && message.role == Role.receiver) {
      return widget.robotAvatar!;
    }

    return const SizedBox();
  }

  /// 点击消息后控制操作弹窗菜单
  void _handleMessageTapControl(
    BuildContext context,
    Offset? offset,
    Message message,
    MessageState state,
    int index,
  ) {
    if (widget.controller.selectMode || message.isSystem()) {
      return;
    }

    HapticFeedbackHelper.mediumImpact();

    final showTranslate = state.showTranslate &&
        state.translateText != null &&
        state.translateText != '';

    BotToast.showAttachedWidget(
      target: offset,
      duration: const Duration(seconds: 8),
      animationDuration: const Duration(milliseconds: 200),
      animationReverseDuration: const Duration(milliseconds: 200),
      preferDirection: PreferDirection.topCenter,
      ignoreContentClick: false,
      onlyOne: true,
      allowClick: true,
      enableSafeArea: true,
      attachedBuilder: (cancel) => AttachedButtonPanel(
        buttons: [
          TextButton.icon(
            onPressed: () {
              if (!state.showMarkdown) {
                state.showMarkdown = true;
              } else {
                state.showMarkdown = false;
              }

              widget.stateManager
                  .setState(message.roomId!, message.id!, state)
                  .then((value) {
                setState(() {});
                context
                    .read<RoomBloc>()
                    .add(RoomLoadEvent(message.roomId!, cascading: false));
              });

              cancel();
            },
            label: const Text(''),
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.showMarkdown ? Icons.text_format : Icons.preview,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: 14,
                ),
                Text(
                  state.showMarkdown ? "文本" : "预览",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              FlutterClipboard.copy(message.text).then((value) {
                showSuccessMessage('已复制到剪贴板');
              });
              cancel();
            },
            label: const Text(''),
            icon: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copy,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 14,
                ),
                Text(
                  "复制",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          if (Ability().supportTranslate)
            TextButton.icon(
                onPressed: () {
                  cancel();

                  if (showTranslate) {
                    widget.stateManager
                        .setState(message.roomId!, message.id!,
                            state..showTranslate = false)
                        .then((value) {
                      setState(() {});
                      context.read<RoomBloc>().add(
                          RoomLoadEvent(message.roomId!, cascading: false));
                    });
                  } else {
                    if (state.translateText != null &&
                        state.translateText != '') {
                      widget.stateManager
                          .setState(message.roomId!, message.id!,
                              state..showTranslate = true)
                          .then((value) {
                        setState(() {});
                        context.read<RoomBloc>().add(
                            RoomLoadEvent(message.roomId!, cascading: false));
                      });
                      return;
                    }

                    APIServer().translate(message.text).then((value) {
                      widget.stateManager
                          .setState(
                        message.roomId!,
                        message.id!,
                        state
                          ..translateText = value.result!
                          ..showTranslate = true,
                      )
                          .then((value) {
                        setState(() {});
                        context.read<RoomBloc>().add(
                            RoomLoadEvent(message.roomId!, cascading: false));
                      });
                    }).onError((error, stackTrace) {
                      showErrorMessage(resolveError(context, error!));
                    });
                  }
                },
                label: const Text(''),
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.translate,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 14,
                    ),
                    Text(
                      showTranslate ? '隐藏' : '翻译',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  ],
                )),
          TextButton.icon(
              onPressed: () async {
                cancel();
                var messages = <ChatShareMessage>[];

                if (message.role == Role.receiver) {
                  final questions = widget.messages
                      .where((e) => e.message.id == message.refId)
                      .toList();
                  if (questions.isNotEmpty) {
                    var q = questions.first;
                    messages.add(ChatShareMessage(
                      content: q.message.text,
                      images: q.message.images,
                      leftSide: false,
                    ));
                  }
                }

                messages.add(ChatShareMessage(
                  content: message.text,
                  images: message.images,
                  leftSide: message.role == Role.receiver,
                  avatarURL: message.avatarUrl,
                  username: message.senderName,
                ));

                if (message.role == Role.sender) {
                  final answers = widget.messages
                      .where((e) => e.message.refId == message.id)
                      .toList();
                  if (answers.isNotEmpty) {
                    for (var a in answers) {
                      messages.add(ChatShareMessage(
                        content: a.message.text,
                        images: a.message.images,
                        leftSide: true,
                        avatarURL: a.message.avatarUrl,
                        username: a.message.senderName,
                      ));
                    }
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => ChatShareScreen(messages: messages),
                  ),
                );

                // await shareTo(context, content: message.text, title: '聊天记录');
              },
              label: const Text(''),
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.share,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 14,
                  ),
                  Text(
                    AppLocale.share.getString(context),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  )
                ],
              )),
          TextButton.icon(
              onPressed: () {
                widget.controller.enterSelectMode();
                cancel();
              },
              label: const Text(''),
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.select_all,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 14,
                  ),
                  Text(
                    AppLocale.select.getString(context),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  )
                ],
              )),
          if (widget.onDeleteMessage != null)
            TextButton.icon(
              onPressed: () {
                widget.onDeleteMessage!(message.id!);
                cancel();
              },
              label: const Text(''),
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 14,
                  ),
                  Text(
                    AppLocale.delete.getString(context),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  )
                ],
              ),
            ),
          if (Ability().supportSpeak && widget.onSpeakEvent != null)
            TextButton.icon(
              onPressed: () {
                cancel();
                widget.onSpeakEvent!(message);
              },
              label: const Text(''),
              icon: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.record_voice_over,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 14,
                  ),
                  Text(
                    '朗读',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                ],
              ),
            ),
          if (message.role == Role.sender && widget.onResentEvent != null)
            TextButton.icon(
              onPressed: () {
                widget.onResentEvent!(message, index);
                cancel();
              },
              label: const Text(''),
              icon: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restore,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 14,
                  ),
                  Text(
                    '重发',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 获取聊天框的最大宽度
  double _chatBoxMaxWidth(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= CustomSize.maxWindowSize) {
      return CustomSize.maxWindowSize;
    }

    return screenWidth;
  }

  /// 获取图片预览的最大宽度
  double _chatBoxImagePreviewWidth(BuildContext context, int imageCount) {
    final expect = _chatBoxMaxWidth(context) / 1.3;
    final max = imageCount > 1 ? 400.0 : 300.0;
    return expect > max ? max : expect;
  }
}

/// ChatPreview 控制器
class ChatPreviewController extends ChangeNotifier {
  /// 是否处于多选模式
  bool _selectMode = false;

  /// 选中的消息ID
  final _selectedMessageIds = <int>{};

  /// 所有消息
  List<MessageWithState>? _allMessages;

  bool get selectMode => _selectMode;
  Set<int> get selectedMessageIds => _selectedMessageIds;

  /// 获取选中的消息
  List<MessageWithState> selectedMessages() {
    if (_allMessages == null || _allMessages!.isEmpty) {
      return [];
    }

    return _allMessages!
        .where((element) => _selectedMessageIds.contains(element.message.id))
        .toList();
  }

  /// 设置所有消息
  void setAllMessageIds(List<MessageWithState> messages) {
    _allMessages = messages.where((e) => !e.message.isSystem()).toList();
  }

  void toggleSelectMode() {
    _selectMode = !_selectMode;
    notifyListeners();
  }

  void exitSelectMode() {
    _selectMode = false;
    _selectedMessageIds.clear();
    notifyListeners();
  }

  void enterSelectMode() {
    _selectMode = true;
    _selectedMessageIds.clear();
    notifyListeners();
  }

  void toggleMessageSelected(int messageId) {
    if (_selectedMessageIds.contains(messageId)) {
      _selectedMessageIds.remove(messageId);
    } else {
      _selectedMessageIds.add(messageId);
    }
    notifyListeners();
  }

  void selectAllMessage() {
    if (_allMessages == null || _allMessages!.isEmpty) {
      return;
    }

    if (_selectedMessageIds.length == _allMessages!.length) {
      _selectedMessageIds.clear();
      notifyListeners();
      return;
    }

    _selectedMessageIds.clear();
    for (var msg in _allMessages!) {
      _selectedMessageIds.add(msg.message.id!);
    }

    notifyListeners();
  }

  void selectMessage(int id) {
    _selectedMessageIds.add(id);
    notifyListeners();
  }

  void unSelectMessage(int id) {
    _selectedMessageIds.remove(id);
    notifyListeners();
  }

  bool isMessageSelected(int id) {
    return _selectedMessageIds.contains(id);
  }
}
