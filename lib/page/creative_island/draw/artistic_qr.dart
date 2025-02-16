import 'dart:math';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/advanced_button.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/global_alert.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/prompt_tags_selector.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/creative_island/draw/components/artistic_style_selector.dart';
import 'package:askaide/page/creative_island/draw/components/content_preview.dart';
import 'package:askaide/page/creative_island/draw/draw_result.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';

class ArtisticQRScreen extends StatefulWidget {
  final SettingRepository setting;
  final int? galleryCopyId;
  final String type;
  final String id;
  final String? note;

  const ArtisticQRScreen({
    super.key,
    required this.id,
    required this.setting,
    this.galleryCopyId,
    required this.type,
    this.note,
  });

  @override
  State<ArtisticQRScreen> createState() => _ArtisticQRScreenState();
}

class _ArtisticQRScreenState extends State<ArtisticQRScreen> {
  bool enableAIRewrite = false;
  bool showAdvancedOptions = false;

  CreativeIslandCapacity? capacity;

  CreativeIslandArtisticStyle? selectedStyle;

  /// 是否停止周期性查询任务执行状态
  var stopPeriodQuery = false;

  int generationImageCount = 1;
  double? textWeight = 1.35;

  TextEditingController promptController = TextEditingController();
  TextEditingController negativePromptController = TextEditingController();
  TextEditingController textController = TextEditingController();
  TextEditingController seedController = TextEditingController();

  @override
  void dispose() {
    promptController.dispose();
    negativePromptController.dispose();
    textController.dispose();
    seedController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    APIServer().creativeIslandCapacity(mode: widget.type, id: widget.id).then((cap) {
      setState(() {
        capacity = cap;
      });

      if (widget.galleryCopyId != null && widget.galleryCopyId! > 0) {
        APIServer().creativeGalleryItem(id: widget.galleryCopyId!).then((response) {
          final gallery = response.item;
          if (gallery.prompt != null && gallery.prompt!.isNotEmpty) {
            promptController.text = gallery.prompt!;
          }

          if (gallery.metaMap['real_prompt'] != null && gallery.metaMap['real_prompt'] != '') {
            promptController.text = gallery.metaMap['real_prompt']!;
          }

          if (gallery.metaMap['negative_prompt'] != null && gallery.metaMap['negative_prompt'] != '') {
            negativePromptController.text = gallery.metaMap['negative_prompt']!;
          }

          if (gallery.metaMap['real_negative_prompt'] != null && gallery.metaMap['real_negative_prompt'] != '') {
            negativePromptController.text = gallery.metaMap['real_negative_prompt']!;
          }

          // 创建同款时，默认关闭 AI 优化，除非该同款包含 ai_rewrite 的设定
          enableAIRewrite = false;
          if ((gallery.metaMap['real_prompt'] == null || gallery.metaMap['real_prompt'] == '') &&
              gallery.metaMap['ai_rewrite'] != null &&
              gallery.metaMap['ai_rewrite']) {
            enableAIRewrite = gallery.metaMap['ai_rewrite'];
          }

          setState(() {});
        });
      }
    });

    if (widget.note != null) {
      Cache().boolGet(key: 'creative:tutorials:${widget.type}:dialog').then((show) {
        if (!show) {
          return;
        }

        openDefaultTutorials(onConfirm: () {
          Cache().setBool(
            key: 'creative:tutorials:${widget.type}:dialog',
            value: false,
            duration: const Duration(days: 30),
          );
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.type == 'qr' ? '艺术二维码' : '图文融合',
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          toolbarHeight: CustomSize.toolbarHeight,
          backgroundColor: customColors.backgroundColor,
          actions: [
            if (widget.note != null)
              IconButton(
                onPressed: () {
                  openDefaultTutorials();
                },
                icon: const Icon(Icons.help_outline),
              )
          ],
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          maxWidth: CustomSize.smallWindowSize,
          child: Column(
            children: [
              if (Ability().showGlobalAlert) const GlobalAlert(pageKey: 'creative_create'),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: buildEditPanel(context, customColors),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openDefaultTutorials({Function? onConfirm}) {
    showBeautyDialog(
      context,
      type: QuickAlertType.info,
      text: '     ${widget.note!}',
      onConfirmBtnTap: () async {
        onConfirm?.call();
        context.pop();
      },
      showCancelBtn: true,
      confirmBtnText: AppLocale.gotIt.getString(context),
    );
  }

  Widget buildEditPanel(BuildContext context, CustomColors customColors) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColumnBlock(
            innerPanding: 10,
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 0),
            children: [
              if (capacity != null && capacity!.artisticStyles.isNotEmpty)
                ArtisticStyleSelector(
                  styles: capacity!.artisticStyles,
                  onSelected: (style) {
                    setState(() {
                      selectedStyle = style;
                    });
                  },
                  selectedStyle: selectedStyle,
                ),
            ],
          ),
          ColumnBlock(
            innerPanding: 10,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            children: [
              EnhancedTextField(
                labelPosition: LabelPosition.top,
                labelText: widget.type == 'qr' ? '链接地址' : '文字内容',
                customColors: customColors,
                controller: textController,
                textAlignVertical: TextAlignVertical.top,
                hintText: widget.type == 'qr' ? '要生成的二维码链接地址。' : '要在画面中绘制的文字。',
                maxLength: widget.type == 'qr' ? 250 : 20,
                maxLines: 3,
                minLines: 1,
                showCounter: false,
              ),
              // 生成内容
              ...buildPromptField(customColors),
              // AI 优化配置
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocale.smartOptimization.getString(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          showBeautyDialog(
                            context,
                            type: QuickAlertType.info,
                            text: AppLocale.onceEnabledSmartOptimization.getString(context),
                            confirmBtnText: AppLocale.gotIt.getString(context),
                            showCancelBtn: false,
                          );
                        },
                        child: Icon(
                          Icons.help_outline,
                          size: 16,
                          color: customColors.weakLinkColor?.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    activeColor: customColors.linkColor,
                    value: enableAIRewrite,
                    onChanged: (value) {
                      setState(() {
                        enableAIRewrite = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          if (showAdvancedOptions)
            ColumnBlock(
              innerPanding: 10,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              children: [
                // 反向提示语
                EnhancedTextField(
                  labelPosition: LabelPosition.top,
                  labelText: AppLocale.excludeContents.getString(context),
                  customColors: customColors,
                  controller: negativePromptController,
                  textAlignVertical: TextAlignVertical.top,
                  hintText: AppLocale.unwantedElements.getString(context),
                  maxLength: 500,
                  maxLines: 5,
                  minLines: 3,
                  showCounter: false,
                ),
                // 权重
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('文本权重'),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            showBeautyDialog(
                              context,
                              type: QuickAlertType.info,
                              text: '文本权重\n\n权重越高，图像中出现的文本痕迹越明显。',
                              confirmBtnText: AppLocale.gotIt.getString(context),
                              showCancelBtn: false,
                            );
                          },
                          child: Icon(
                            Icons.help_outline,
                            size: 16,
                            color: customColors.weakLinkColor?.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Slider(
                        value: textWeight ?? 1.35,
                        min: 0,
                        max: 3,
                        divisions: 60,
                        activeColor: customColors.linkColor,
                        onChanged: (value) {
                          setState(() {
                            textWeight = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      (textWeight ?? 1.38).toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 12,
                        color: customColors.weakTextColor,
                      ),
                    ),
                  ],
                ),
                // 图片数量
                EnhancedInput(
                  title: Text(
                    AppLocale.imageCount.getString(context),
                    style: TextStyle(
                      color: customColors.textfieldLabelColor,
                      fontSize: 16,
                    ),
                  ),
                  value: Text(generationImageCount.toString()),
                  onPressed: () {
                    openListSelectDialog(
                      context,
                      <SelectorItem>[
                        SelectorItem(const Text('1', textAlign: TextAlign.center), 1),
                        SelectorItem(const Text('2', textAlign: TextAlign.center), 2),
                        SelectorItem(const Text('3', textAlign: TextAlign.center), 3),
                        SelectorItem(const Text('4', textAlign: TextAlign.center), 4),
                      ],
                      (value) {
                        setState(() {
                          generationImageCount = value.value;
                        });
                        return true;
                      },
                      heightFactor: 0.4,
                      value: generationImageCount,
                    );
                  },
                ),
                // Seed
                EnhancedTextField(
                  controller: seedController,
                  customColors: customColors,
                  labelText: 'Seed',
                  labelPosition: LabelPosition.left,
                  showCounter: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  hintText: '默认随机',
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          // 生成按钮
          AdvancedButton(
            showAdvancedOptions: showAdvancedOptions,
            onPressed: (value) {
              setState(() {
                showAdvancedOptions = value;
              });
            },
          ),
          if (capacity != null) const SizedBox(height: 10),
          EnhancedButton(
            title: AppLocale.generate.getString(context),
            onPressed: onGenerate,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> buildPromptField(CustomColors customColors) {
    return [
      EnhancedTextField(
        labelPosition: LabelPosition.top,
        labelText: AppLocale.yourIdeas.getString(context),
        customColors: customColors,
        controller: promptController,
        textAlignVertical: TextAlignVertical.top,
        hintText: AppLocale.keywordsSeparatedByCommas.getString(context),
        maxLines: 10,
        minLines: 2,
        maxLength: 460,
        showCounter: false,
        inputSelector: IconButton(
          onPressed: () {
            openModalBottomSheet(
              context,
              (context) {
                return PromptTagsSelector(
                  selectedTags: selectedTags,
                  onSubmit: (tags) {
                    setState(() {
                      selectedTags = tags;
                    });
                    context.pop();
                  },
                );
              },
              heightFactor: 0.8,
              useSafeArea: true,
            );
          },
          icon: Icon(
            Icons.lightbulb_outline,
            color: customColors.linkColor,
            size: 16,
          ),
        ),
        middleWidget: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 30),
          child: Wrap(
            spacing: 3,
            runSpacing: 3,
            children: selectedTags
                .map(
                  (e) => Tag(
                    name: e.name,
                    backgroundColor: customColors.linkColor,
                    textColor: Colors.white,
                    fontsize: 10,
                    onDeleted: () {
                      setState(() {
                        selectedTags.remove(e);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ),
        bottomButton: Row(
          children: [
            Icon(
              Icons.shuffle,
              size: 13,
              color: customColors.linkColor?.withAlpha(150),
            ),
            const SizedBox(width: 5),
            Text(
              AppLocale.random.getString(context),
              style: TextStyle(
                color: customColors.linkColor?.withAlpha(150),
                fontSize: 13,
              ),
            ),
          ],
        ),
        bottomButtonOnPressed: () async {
          final examples = await APIServer().exampleByTag('artistic-text');
          if (examples.isEmpty) {
            return;
          }

          // 随机选取一个例子
          final example = examples[Random().nextInt(examples.length)];
          promptController.text = example.text;
        },
      ),
    ];
  }

  List<PromptTag> selectedTags = [];

  void onGenerate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    HapticFeedbackHelper.mediumImpact();

    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      showErrorMessage(AppLocale.contentIsRequired.getString(context));
      return;
    }

    final text = textController.text.trim();
    if (text.isEmpty) {
      showErrorMessage('${widget.type == "qr" ? "链接地址" : "文本内容"}不能为空');
      return;
    }

    final seed = int.tryParse(seedController.text);
    if (seed != null && (seed < 0 || seed > 2147483647)) {
      showErrorMessage('Seed 取值范围为 0 ~ 2147483647');
      return;
    }

    var params = <String, dynamic>{
      'prompt': prompt,
      'prompt_tags': selectedTags.map((e) => e.value).join(','),
      'negative_prompt': negativePromptController.text,
      'ai_rewrite': enableAIRewrite,
      'gallery_copy_id': widget.galleryCopyId,
      'text': text,
      'type': widget.type,
      'seed': seed,
      'image_count': generationImageCount,
      'control_weight': textWeight,
      'style_preset': selectedStyle?.id,
    };

    final cancel = BotToast.showCustomLoading(
      toastBuilder: (cancel) {
        return const LoadingIndicator(
          message: '思考中，请稍候...',
        );
      },
      allowClick: false,
      duration: const Duration(seconds: 15),
    );

    request(int waitDuration) async {
      try {
        final taskId = await APIServer().creativeIslandArtisticTextCompletionsAsyncV2(params);

        stopPeriodQuery = false;

        cancel();

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => DrawResultPage(
              future: Future.delayed(const Duration(seconds: 10), () async {
                return await queryCompletionTaskStatus(
                  taskId: taskId,
                  retryTimes: 0,
                  delaySeconds: 3,
                  params: params,
                );
              }),
              waitDuration: waitDuration,
            ),
          ),
        ).whenComplete(() {
          stopPeriodQuery = true;
        });
      } catch (e) {
        stopPeriodQuery = true;
        cancel();
        // ignore: use_build_context_synchronously
        showErrorMessageEnhanced(context, e);
      }
    }

    try {
      request(30);
    } catch (e) {
      cancel();
      // ignore: use_build_context_synchronously
      showErrorMessageEnhanced(context, e);
    }
  }

  Future<IslandResult> queryCompletionTaskStatus({
    required String taskId,
    required int retryTimes,
    required int delaySeconds,
    Map<String, dynamic>? params,
  }) async {
    if (retryTimes > 60) {
      return Future.error(AppLocale.generateTimeout.getString(context));
    }

    final resp = await APIServer().asyncTaskStatus(taskId);
    switch (resp.status) {
      case 'success':
        if (params != null && resp.originImage != null && resp.originImage != '') {
          params['image'] = resp.originImage;
        }
        return IslandResult(
          result: resp.resources ?? const [],
          params: params,
        );
      case 'failed':
        return Future.error(resp.errors!.join(";"));
      default:
        if (stopPeriodQuery) {
          // ignore: use_build_context_synchronously
          return Future.error(AppLocale.generateTimeout.getString(context));
        }

        return await Future.delayed(Duration(seconds: delaySeconds), () async {
          return await queryCompletionTaskStatus(
            taskId: taskId,
            retryTimes: retryTimes + 1,
            delaySeconds: 3,
            params: params,
          );
        });
    }
  }
}
