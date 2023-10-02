import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/empty.dart';
import 'package:askaide/page/component/chat/voice_record.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/model_indicator.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ChatChatScreen extends StatefulWidget {
  final SettingRepository setting;
  final bool showInitialDialog;
  final int? reward;
  const ChatChatScreen({
    super.key,
    required this.setting,
    this.showInitialDialog = false,
    this.reward,
  });

  @override
  State<ChatChatScreen> createState() => _ChatChatScreenState();
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

class _ChatChatScreenState extends State<ChatChatScreen> {
  final TextEditingController _textController = TextEditingController();

  ModelIndicatorInfo? currentModel;

  List<ModelIndicatorInfo> models = [
    ModelIndicatorInfo(
      modelId: "gpt-3.5-turbo",
      modelName: 'GPT-3.5',
      description: '速度快，成本低',
      icon: Icons.bolt,
      activeColor: Colors.green,
    ),
    ModelIndicatorInfo(
      modelId: "gpt-4",
      modelName: 'GPT-4',
      description: '能力强，更精准',
      icon: Icons.auto_awesome,
      activeColor: const Color.fromARGB(255, 120, 73, 223),
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());

    if (Ability().homeModels.isNotEmpty) {
      models = Ability()
          .homeModels
          .map((e) => ModelIndicatorInfo(
                modelId: e.modelId,
                modelName: e.name,
                description: e.desc,
                icon: e.powerful ? Icons.auto_awesome : Icons.bolt,
                activeColor: stringToColor(e.color),
              ))
          .toList();
    }

    _textController.addListener(() {
      setState(() {});
    });

    setState(() {
      currentModel = models[0];
    });

    // 加载免费模型剩余使用次数
    if (currentModel != null) {
      context
          .read<FreeCountBloc>()
          .add(FreeCountReloadEvent(model: currentModel!.modelId));
    }

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
              launchUrlString(resp.url);
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

  Map<String, Widget> buildModelIndicators() {
    Map<String, Widget> map = {};
    for (var model in models) {
      map[model.modelId] = ModelIndicator(
        model: model,
        selected: model.modelId == currentModel?.modelId,
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
          buildWhen: (previous, current) =>
              current is ChatChatRecentHistoriesLoaded,
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
                backgroundImage: Image.asset(
                  customColors.appBarBackgroundImage!,
                  fit: BoxFit.cover,
                ),
                appBarExtraWidgets: () {
                  return [
                    SliverStickyHeader(
                      header: SafeArea(
                        top: false,
                        child: Container(
                          color: customColors.backgroundContainerColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  top: 7,
                                ),
                                child: CustomSlidingSegmentedControl<String>(
                                  children: buildModelIndicators(),
                                  padding: 0,
                                  isStretch: true,
                                  height: 60,
                                  innerPadding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: customColors
                                        .columnBlockBackgroundColor
                                        ?.withAlpha(150),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  thumbDecoration: BoxDecoration(
                                    color: currentModel?.activeColor ??
                                        customColors.linkColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInToLinear,
                                  onValueChanged: (value) {
                                    currentModel = models.firstWhere(
                                        (element) => element.modelId == value);

                                    // 重新读取模型的免费使用次数
                                    context.read<FreeCountBloc>().add(
                                        FreeCountReloadEvent(model: value));

                                    setState(() {});
                                  },
                                ),
                              ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (currentModel != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12,
                                                  right: 4,
                                                ),
                                                child: Icon(
                                                  Icons.circle,
                                                  color:
                                                      currentModel!.activeColor,
                                                  size: 10,
                                                ),
                                              ),
                                            Expanded(
                                              child: EnhancedTextField(
                                                controller: _textController,
                                                customColors: customColors,
                                                maxLines: 10,
                                                minLines: 6,
                                                hintText: AppLocale
                                                    .askMeAnyQuestion
                                                    .getString(context),
                                                maxLength: 2000,
                                                showCounter: false,
                                                hintColor: customColors
                                                    .textfieldHintDeepColor,
                                                hintTextSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 5),
                                          child: _buildSendOrVoiceButton(
                                            context,
                                            customColors,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              if (state.examples != null &&
                                  state.examples!.isNotEmpty &&
                                  state.histories.isEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 10, right: 10, bottom: 3),
                                  margin: const EdgeInsets.all(10),
                                  height: 260,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            AppLocale.askMeLikeThis
                                                .getString(context),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: customColors
                                                  .textfieldHintDeepColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: ListView.separated(
                                          padding: const EdgeInsets.all(0),
                                          itemCount: state.examples!.length > 4
                                              ? 4
                                              : state.examples!.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return ListTextItem(
                                              title:
                                                  state.examples![index].title,
                                              onTap: () {
                                                onSubmit(
                                                  context,
                                                  state.examples![index].text,
                                                );
                                              },
                                              customColors: customColors,
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return Divider(
                                              color: customColors
                                                  .chatExampleItemText
                                                  ?.withAlpha(20),
                                            );
                                          },
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          style: ButtonStyle(
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    Colors.transparent),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              state.examples!.shuffle();
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.refresh,
                                                color:
                                                    customColors.weakTextColor,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                AppLocale.refresh
                                                    .getString(context),
                                                style: TextStyle(
                                                  color: customColors
                                                      .weakTextColor,
                                                ),
                                                textScaleFactor: 0.9,
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
                        ),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              return SafeArea(
                                top: false,
                                bottom: false,
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 20, left: 15),
                                  child: Text(
                                    '历史记录',
                                    style: TextStyle(
                                      color: customColors.weakTextColor
                                          ?.withAlpha(100),
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 13,
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
                                          '/chat-anywhere?chat_id=${state.histories[index - 1].id}')
                                      .whenComplete(() {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    context
                                        .read<ChatChatBloc>()
                                        .add(ChatChatLoadRecentHistories());
                                  });
                                },
                              ),
                            );
                          },
                          childCount: state.histories.isNotEmpty
                              ? state.histories.length + 1
                              : 0,
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

  /// 构建发送或者语音按钮
  Widget _buildSendOrVoiceButton(
    BuildContext context,
    CustomColors customColors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
        BlocBuilder<FreeCountBloc, FreeCountState>(
          buildWhen: (previous, current) => current is FreeCountLoadedState,
          builder: (context, state) {
            if (state is FreeCountLoadedState) {
              if (currentModel != null) {
                final matched = state.model(currentModel!.modelId);
                if (matched != null &&
                    matched.leftCount > 0 &&
                    matched.maxCount > 0) {
                  return Text(
                    '今日剩余免费 ${matched.leftCount} 次',
                    style: TextStyle(
                      color: customColors.weakTextColor?.withAlpha(150),
                      fontSize: 12,
                    ),
                  );
                }
              }
            }
            return const SizedBox();
          },
        ),
        InkWell(
          onTap: () {
            if (_textController.text.trim().isEmpty) {
              return;
            }

            onSubmit(context, _textController.text.trim());
          },
          child: Icon(
            Icons.send,
            color: _textController.text.trim().isNotEmpty
                ? customColors.linkColor ??
                    const Color.fromARGB(255, 70, 165, 73)
                : customColors.chatInputPanelText,
            size: 26,
          ),
        )
      ],
    );
  }

  void onSubmit(BuildContext context, String text) {
    context
        .push(Uri(path: '/chat-anywhere', queryParameters: {
      'init_message': text,
      'model': currentModel?.modelId,
    }).toString())
        .whenComplete(() {
      _textController.clear();
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: AppLocale.delete.getString(context),
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              onPressed: (_) {
                openConfirmDialog(
                  context,
                  AppLocale.confirmDelete.getString(context),
                  () {
                    context
                        .read<ChatChatBloc>()
                        .add(ChatChatDeleteHistory(history.id!));
                  },
                  danger: true,
                );
              },
            ),
          ],
        ),
        child: Material(
          color: customColors.backgroundColor?.withAlpha(200),
          borderRadius: BorderRadius.all(
            Radius.circular(customColors.borderRadius ?? 8),
          ),
          child: InkWell(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(customColors.borderRadius ?? 8),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (history.title ?? '未命名').trim(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: customColors.weakTextColor,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    humanTime(history.updatedAt),
                    style: TextStyle(
                      color: customColors.weakTextColor?.withAlpha(65),
                      fontSize: 12,
                    ),
                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}
