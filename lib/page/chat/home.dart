import 'dart:io';
import 'dart:math';

import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/helper/global_store.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/empty.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/voice_record.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/global_alert.dart';
import 'package:askaide/page/component/model_indicator.dart';
import 'package:askaide/page/component/notify_message.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/model.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  final SettingRepository setting;
  final bool showInitialDialog;
  final int? reward;
  const HomePage({
    super.key,
    required this.setting,
    this.showInitialDialog = false,
    this.reward,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class ChatModel {
  String id;
  String name;
  Color backgroundColor;
  String backgroundImage;

  ChatModel({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.backgroundImage,
  });
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();

  ModelIndicator? currentModel;

  List<HomeModelV2> models = [
    HomeModelV2(
      modelId: "openai:gpt-3.5-turbo",
      modelName: 'Chat-3.5',
      type: 'model',
      id: 'openai:gpt-3.5-turbo',
      supportVision: false,
      name: 'Chat-3.5',
      avatarUrl: 'https://ssl.aicode.cc/ai-server/assets/avatar/gpt35.png',
    ),
    HomeModelV2(
      modelId: "openai:gpt-4",
      modelName: 'Chat-4',
      type: 'model',
      id: 'openai:gpt-4',
      supportVision: false,
      name: 'Chat-4',
      avatarUrl: 'https://ssl.aicode.cc/ai-server/assets/avatar/gpt4-preview.png',
    ),
  ];

  /// 是否显示提示消息对话框
  bool showFreeModelNotifyMessage = false;

  List<FileUpload> selectedImageFiles = [];

  /// 促销事件
  PromotionEvent? promotionEvent;

  /// Maximum height of the chat input box
  int inputMaxLines = 6;

  /// 用于监听键盘事件，实现回车发送消息，Shift+Enter换行
  late final FocusNode _focusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (!HardwareKeyboard.instance.isShiftPressed && event.logicalKey.keyLabel == 'Enter') {
        if (event is KeyDownEvent) {
          onSubmit(context, _textController.text.trim());
        }

        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());

    if (Ability().homeModels.isNotEmpty) {
      models = Ability().homeModels;
    }

    APIServer().capabilities().then((cap) {
      Ability().updateCapabilities(cap);

      if (cap.homeModels.isNotEmpty) {
        models = cap.homeModels;

        if (mounted) {
          setState(() {});
        }
      }
    });

    // 是否显示免费模型提示消息
    Cache().boolGet(key: 'show_home_free_model_message').then((show) async {
      if (show) {
        final promotions = await APIServer().notificationPromotionEvents();
        if (promotions['chat_page'] == null || promotions['chat_page']!.isEmpty) {
          return;
        }

        // 多个促销事件，则随机选择一个
        promotionEvent = promotions['chat_page']![Random().nextInt(promotions['chat_page']!.length)];
      }

      setState(() {
        showFreeModelNotifyMessage = show;
      });
    });

    _textController.addListener(() {
      setState(() {});
    });

    setState(() {
      currentModel = ModelIndicator(
        model: models[0],
        iconAndColor: iconAndColors[0],
      );
    });

    if (widget.showInitialDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBeautyDialog(
          context,
          type: QuickAlertType.info,
          text:
              '恭喜您，账号创建成功！${(widget.reward != null && widget.reward! > 0) ? '\n\n为了庆祝这一时刻，我们向您的账户赠送了 ${widget.reward} 个智慧果。' : ''}',
          confirmBtnText: '开始使用',
          onConfirmBtnTap: () {
            context.pop();
          },
        );
      });
    } else {
      // 版本检查
      APIServer().versionCheck().then((resp) {
        final lastVersion = widget.setting.get('last_server_version');
        if (resp.serverVersion == lastVersion && !resp.forceUpdate) {
          return;
        }

        if (resp.hasUpdate) {
          showBeautyDialog(
            context,
            type: QuickAlertType.success,
            text: resp.message,
            confirmBtnText: '去更新',
            onConfirmBtnTap: () {
              launchUrlString(resp.url, mode: LaunchMode.externalApplication);
            },
            cancelBtnText: '暂不更新',
            showCancelBtn: true,
          );
        }

        widget.setting.set('last_server_version', resp.serverVersion);
      });
    }

    super.initState();
  }

  Map<String, ModelIndicator> buildModelIndicators() {
    Map<String, ModelIndicator> map = {};

    for (var i = 0; i < models.length; i++) {
      var model = models[i];
      map[model.id] = ModelIndicator(
        model: model,
        selected: model.id == currentModel?.model.id,
        iconAndColor: iconAndColors[i],
        itemCount: models.length,
      );
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<ChatChatBloc, ChatChatState>(
          buildWhen: (previous, current) => current is ChatChatRecentHistoriesLoaded,
          builder: (context, state) {
            if (state is ChatChatRecentHistoriesLoaded) {
              return SliverSingleComponent(
                title: Text(
                  AppLocale.chatAnywhere.getString(context),
                  style: TextStyle(
                    fontSize: CustomSize.appBarTitleSize,
                    color: customColors.backgroundInvertedColor,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      context.push('/chat-chat/history').whenComplete(() {
                        context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
                      });
                    },
                  ),
                ],
                appBarExtraWidgets: () {
                  return [
                    SliverStickyHeader(
                      header: SafeArea(
                        top: false,
                        child: buildChatComponents(customColors, context, state),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              return SafeArea(
                                top: false,
                                bottom: false,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10, left: 15),
                                  child: Text(
                                    AppLocale.histories.getString(context),
                                    style: TextStyle(
                                      color: customColors.weakTextColor?.withAlpha(100),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (index == state.histories.length && index > 3) {
                              return SafeArea(
                                top: false,
                                bottom: false,
                                child: GestureDetector(
                                  onTap: () {
                                    context.push('/chat-chat/history').whenComplete(() {
                                      context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(top: 5, bottom: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.keyboard_double_arrow_left,
                                          size: 12,
                                          color: customColors.weakTextColor!.withAlpha(120),
                                        ),
                                        Text(
                                          "查看更多",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: customColors.weakTextColor!.withAlpha(120),
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_double_arrow_right,
                                          size: 12,
                                          color: customColors.weakTextColor!.withAlpha(120),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return SafeArea(
                              top: false,
                              bottom: false,
                              child: ChatHistoryItem(
                                history: state.histories[index - 1],
                                customColors: customColors,
                                onTap: () {
                                  context
                                      .push(
                                          '/chat-anywhere?chat_id=${state.histories[index - 1].id}&model=${state.histories[index - 1].model}&title=${state.histories[index - 1].title}')
                                      .whenComplete(() {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
                                  });
                                },
                              ),
                            );
                          },
                          childCount: state.histories.isNotEmpty ? state.histories.length + 1 : 0,
                        ),
                      ),
                    ),
                  ];
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Container buildChatComponents(
    CustomColors customColors,
    BuildContext context,
    ChatChatRecentHistoriesLoaded state,
  ) {
    final indicators = buildModelIndicators();
    return Container(
      color: customColors.backgroundContainerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Ability().showGlobalAlert) const GlobalAlert(pageKey: 'home'),
          if (showFreeModelNotifyMessage && promotionEvent != null)
            // 首页通知消息组件
            buildNotifyMessageWidget(context),
          // 模型选择
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            padding: const EdgeInsets.only(
              left: 5,
              right: 5,
              top: 10,
            ),
            child: CustomSlidingSegmentedControl<String>(
              children: indicators,
              padding: 0,
              isStretch: true,
              height: Ability().showHomeModelDescription ? 60 : 45,
              innerPadding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: customColors.columnBlockBackgroundColor?.withAlpha(150),
                borderRadius: CustomSize.borderRadius,
              ),
              thumbDecoration: BoxDecoration(
                color: currentModel?.iconAndColor.color,
                borderRadius: CustomSize.borderRadius,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInToLinear,
              onValueChanged: (value) {
                setState(() {
                  currentModel = indicators[value];
                });
              },
            ),
          ),
          // 聊天内容输入框
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            child: ColumnBlock(
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 15,
                right: 15,
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 聊天问题输入框
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentModel != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              right: 4,
                            ),
                            child: Icon(
                              Icons.circle,
                              color: currentModel?.iconAndColor.color,
                              size: 10,
                            ),
                          ),
                        Expanded(
                          child: EnhancedTextField(
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                setState(() {
                                  inputMaxLines = 15;
                                });
                              } else {
                                setState(() {
                                  inputMaxLines = 6;
                                });
                              }
                            },
                            focusNode: _focusNode,
                            controller: _textController,
                            customColors: customColors,
                            maxLines: inputMaxLines,
                            minLines: 6,
                            hintText: AppLocale.askMeAnyQuestion.getString(context),
                            maxLength: 150000,
                            showCounter: false,
                            hintColor: customColors.textfieldHintDeepColor,
                            hintTextSize: 15,
                          ),
                        ),
                      ],
                    ),
                    // 聊天控制工具栏
                    Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: _buildSendOrVoiceButton(
                        context,
                        customColors,
                      ),
                    ),
                    if (selectedImageFiles.isNotEmpty && currentModel != null && currentModel!.model.supportVision)
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: selectedImageFiles
                              .map(
                                (e) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(5),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: CustomSize.borderRadius,
                                        child: e.file.bytes != null
                                            ? Image.memory(
                                                e.file.bytes!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              )
                                            : Image.file(
                                                File(e.file.path!),
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                      ),
                                      Positioned(
                                        right: 5,
                                        top: 5,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedImageFiles.remove(e);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              borderRadius: CustomSize.borderRadius,
                                              color: customColors.chatRoomBackground,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 10,
                                              color: customColors.weakTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
          // 问题示例
          if (state.examples != null && state.examples!.isNotEmpty && state.histories.isEmpty)
            Container(
              decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 3),
              margin: const EdgeInsets.all(10),
              height: 260,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/app-256-transparent.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AppLocale.askMeLikeThis.getString(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: customColors.textfieldHintDeepColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0),
                      itemCount: state.examples!.length > 4 ? 4 : state.examples!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTextItem(
                          title: state.examples![index].title,
                          onTap: () {
                            onSubmit(
                              context,
                              state.examples![index].text,
                            );
                          },
                          customColors: customColors,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          color: customColors.chatExampleItemText?.withAlpha(20),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        setState(() {
                          state.examples!.shuffle();
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: customColors.weakTextColor,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            AppLocale.refresh.getString(context),
                            style: TextStyle(
                              color: customColors.weakTextColor,
                            ),
                            textScaler: const TextScaler.linear(0.9),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  NotifyMessageWidget buildNotifyMessageWidget(BuildContext context) {
    return NotifyMessageWidget(
      title: promotionEvent!.title != null
          ? Text(
              promotionEvent!.title!,
              style: TextStyle(
                color: stringToColor(promotionEvent!.textColor ?? 'FFFFFFFF'),
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      backgroundImageUrl: promotionEvent!.backgroundImage,
      height: 85,
      closeable: promotionEvent!.closeable,
      onClose: () {
        setState(() {
          showFreeModelNotifyMessage = false;
        });

        Cache().setBool(
          key: 'show_home_free_model_message',
          value: false,
          duration: Duration(days: promotionEvent!.maxCloseDurationInDays ?? 7),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              promotionEvent!.content,
              style: TextStyle(
                color: stringToColor(promotionEvent!.textColor ?? 'FFFFFFFF'),
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
          ),
          if (promotionEvent!.clickButtonType != PromotionEventClickButtonType.none &&
              promotionEvent!.clickValue != null &&
              promotionEvent!.clickValue!.isNotEmpty)
            InkWell(
              onTap: () {
                switch (promotionEvent!.clickButtonType) {
                  case PromotionEventClickButtonType.url:
                    if (promotionEvent!.clickValue != null && promotionEvent!.clickValue!.isNotEmpty) {
                      launchUrlString(promotionEvent!.clickValue!, mode: LaunchMode.externalApplication);
                    }
                    break;
                  case PromotionEventClickButtonType.inAppRoute:
                    if (promotionEvent!.clickValue != null && promotionEvent!.clickValue!.isNotEmpty) {
                      context.push(promotionEvent!.clickValue!);
                    }

                    break;
                  case PromotionEventClickButtonType.none:
                }
              },
              child: Row(
                children: [
                  Text(
                    '详情',
                    style: TextStyle(
                      color: stringToColor(promotionEvent!.clickButtonColor ?? 'FFFFFFFF'),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.keyboard_double_arrow_right,
                    size: 16,
                    color: stringToColor(promotionEvent!.clickButtonColor ?? 'FFFFFFFF'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建发送或者语音按钮
  Widget _buildSendOrVoiceButton(
    BuildContext context,
    CustomColors customColors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                HapticFeedbackHelper.mediumImpact();

                openModalBottomSheet(
                  context,
                  (context) {
                    return VoiceRecord(
                      onFinished: (text) {
                        _textController.text = _textController.text + text;
                        Navigator.pop(context);
                      },
                      onStart: () {},
                    );
                  },
                  isScrollControlled: false,
                  heightFactor: 0.8,
                );
              },
              child: Icon(
                Icons.mic,
                color: customColors.chatInputPanelText,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            if (currentModel != null && currentModel!.model.supportVision)
              InkWell(
                onTap: () async {
                  // 上传图片
                  HapticFeedbackHelper.mediumImpact();
                  if (selectedImageFiles.length >= 4) {
                    showSuccessMessage(AppLocale.uploadImageLimit4.getString(context));
                    return;
                  }

                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final files = selectedImageFiles;
                    files.addAll(result.files.map((e) => FileUpload(file: e)).toList());
                    setState(() {
                      selectedImageFiles = files.sublist(0, files.length > 4 ? 4 : files.length);
                    });
                  }
                },
                child: Icon(
                  Icons.camera_alt,
                  color: customColors.chatInputPanelText,
                  size: 28,
                ),
              ),
          ],
        ),
        const SizedBox(),
        InkWell(
          onTap: () {
            onSubmit(context, _textController.text.trim());
          },
          child: Icon(
            Icons.send,
            color: _textController.text.trim().isNotEmpty
                ? customColors.linkColor ?? const Color.fromARGB(255, 70, 165, 73)
                : customColors.chatInputPanelText,
            size: 26,
          ),
        )
      ],
    );
  }

  void onSubmit(BuildContext context, String text) {
    if (text.trim().isEmpty) {
      return;
    }

    if (currentModel != null && currentModel!.model.supportVision) {
      GlobalStore().uploadedFiles = selectedImageFiles;
    }

    selectedImageFiles = [];

    context
        .push(Uri(path: '/chat-anywhere', queryParameters: {
      'init_message': text,
      'model': 'v2@${currentModel?.model.uniqueKey}',
    }).toString())
        .whenComplete(() {
      _textController.clear();
      GlobalStore().uploadedFiles.clear();

      FocusScope.of(context).requestFocus(FocusNode());
      context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
    });
  }
}

class ChatHistoryItem extends StatelessWidget {
  const ChatHistoryItem({
    super.key,
    required this.history,
    required this.customColors,
    required this.onTap,
  });

  final ChatHistory history;
  final CustomColors customColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: AppLocale.delete.getString(context),
              borderRadius: CustomSize.borderRadiusAll,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              onPressed: (_) {
                openConfirmDialog(
                  context,
                  AppLocale.confirmDelete.getString(context),
                  () {
                    context.read<ChatChatBloc>().add(ChatChatDeleteHistory(history.id!));
                  },
                  danger: true,
                );
              },
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: CustomSize.borderRadius,
            color: customColors.listTileBackgroundColor,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(borderRadius: CustomSize.borderRadius),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    (history.title ?? '未命名').trim(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                    maxLines: 1,
                  ),
                ),
                // Text(
                //   humanTime(history.updatedAt),
                //   style: TextStyle(
                //     color: customColors.weakTextColor,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
            dense: true,
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                (history.lastMessage ?? '暂无内容').trim().replaceAll("\n", " "),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: customColors.weakTextColor?.withAlpha(150),
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            onTap: () {
              HapticFeedbackHelper.lightImpact();
              onTap();
            },
            tileColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
