import 'dart:math';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/advanced_button.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/global_alert.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/prompt_tags_selector.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/creative_island/draw/components/artistic_style_selector.dart';
import 'package:askaide/page/creative_island/draw/components/content_preview.dart';
import 'package:askaide/page/creative_island/draw/draw_result.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';

class ArtisticWordArtScreen extends StatefulWidget {
  final SettingRepository setting;
  final int? galleryCopyId;
  final String id;
  final String? note;

  const ArtisticWordArtScreen({
    super.key,
    required this.id,
    required this.setting,
    this.galleryCopyId,
    this.note,
  });

  @override
  State<ArtisticWordArtScreen> createState() => _ArtisticWordArtScreenState();
}

class _ArtisticWordArtScreenState extends State<ArtisticWordArtScreen> {
  bool showAdvancedOptions = false;

  CreativeIslandCapacity? capacity;

  CreativeIslandArtisticStyle? selectedStyle;
  CreativeIslandArtisticStyle? selectedFonts;

  /// 是否停止周期性查询任务执行状态
  var stopPeriodQuery = false;

  int generationImageCount = 1;

  TextEditingController promptController = TextEditingController();
  TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    promptController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    APIServer().creativeIslandCapacity(mode: 'artistic-text', id: widget.id).then((cap) {
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

          setState(() {});
        });
      }
    });

    if (widget.note != null) {
      Cache().boolGet(key: 'creative:tutorials:artistic-text:dialog').then((show) {
        if (!show) {
          return;
        }

        openDefaultTutorials(onConfirm: () {
          Cache().setBool(
            key: 'creative:tutorials:artistic-text:dialog',
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
          title: const Text(
            '艺术字',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
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
          maxWidth: CustomSize.smallWindowSize,
          backgroundColor: customColors.backgroundColor,
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
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 0),
            children: [
              if (capacity != null && capacity!.artisticTextStyles.isNotEmpty)
                ArtisticStyleSelector(
                  styles: capacity!.artisticTextStyles,
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
                labelText: '文字内容',
                customColors: customColors,
                controller: textController,
                textAlignVertical: TextAlignVertical.top,
                hintText: '要在画面中绘制的文字。',
                maxLength: 20,
                maxLines: 3,
                minLines: 1,
                showCounter: false,
              ),

              // 生成内容
              ...buildPromptField(customColors),
            ],
          ),

          if (showAdvancedOptions)
            ColumnBlock(
              innerPanding: 10,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              children: [
                if (capacity != null && capacity!.artisticTextFonts.isNotEmpty)
                  ArtisticStyleSelector(
                    title: '文字字体',
                    styles: capacity!.artisticTextFonts,
                    onSelected: (style) {
                      setState(() {
                        selectedFonts = style;
                      });
                    },
                    selectedStyle: selectedFonts,
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
          final examples = await APIServer().exampleByTag('artistic-wordart');
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
      showErrorMessage('文本内容不能为空');
      return;
    }

    var params = <String, dynamic>{
      'prompt': prompt,
      'prompt_tags': selectedTags.map((e) => e.value).join(','),
      'gallery_copy_id': widget.galleryCopyId,
      'text': text,
      'type': 'word_art',
      'image_count': generationImageCount,
      'style_preset': selectedStyle?.id,
      'font_name': selectedFonts?.id,
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
      request(45);
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
