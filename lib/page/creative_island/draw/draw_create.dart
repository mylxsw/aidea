import 'dart:math';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/upload.dart';
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
import 'package:askaide/page/creative_island/draw/components/content_preview.dart';
import 'package:askaide/page/creative_island/draw/draw_result.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/creative_island/draw/components/image_selector.dart';
import 'package:askaide/page/creative_island/draw/components/image_size.dart';
import 'package:askaide/page/creative_island/draw/components/image_style_selector.dart';
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

class DrawCreateScreen extends StatefulWidget {
  final SettingRepository setting;
  final int? galleryCopyId;
  final String mode;
  final String id;
  final String? note;
  final String? initImage;

  const DrawCreateScreen({
    super.key,
    required this.id,
    required this.setting,
    this.galleryCopyId,
    required this.mode,
    this.note,
    this.initImage,
  });

  @override
  State<DrawCreateScreen> createState() => _DrawCreateScreenState();
}

class _DrawCreateScreenState extends State<DrawCreateScreen> {
  String? selectedImagePath;
  Uint8List? selectedImageData;

  bool enableAIRewrite = false;
  int generationImageCount = 1;
  CreativeIslandVendorModel? selectedModel;
  String? upscaleBy;
  String selectedImageSize = '1:1';
  bool showAdvancedOptions = false;
  CreativeIslandImageFilter? selectedStyle;
  double? imageStrength = 0.65;

  /// 是否停止周期性查询任务执行状态
  var stopPeriodQuery = false;
  CreativeIslandCapacity? capacity;

  TextEditingController promptController = TextEditingController();
  TextEditingController negativePromptController = TextEditingController();
  TextEditingController seedController = TextEditingController();

  /// 是否强制显示 negativePrompt
  bool forceShowNegativePrompt = false;

  @override
  void dispose() {
    promptController.dispose();
    negativePromptController.dispose();
    seedController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.initImage != null) {
      selectedImagePath = widget.initImage;
    }

    APIServer().creativeIslandCapacity(mode: widget.mode, id: widget.id).then((cap) {
      setState(() {
        capacity = cap;
      });

      if (widget.galleryCopyId != null && widget.galleryCopyId! > 0) {
        APIServer().creativeGalleryItem(id: widget.galleryCopyId!).then((response) {
          final gallery = response.item;
          if (gallery.prompt != null && gallery.prompt!.isNotEmpty) {
            promptController.text = gallery.prompt!;
          }

          if (gallery.negativePrompt != null && gallery.negativePrompt!.isNotEmpty) {
            if (gallery.negativePrompt != null && gallery.negativePrompt!.isNotEmpty) {
              forceShowNegativePrompt = true;
            }

            negativePromptController.text = gallery.negativePrompt!;
          }

          if (gallery.metaMap['model_id'] != null && gallery.metaMap['model_id'] != '') {
            final matchedModels = capacity!.vendorModels
                .where((e) => e.id == gallery.metaMap['model_id'] || e.id == 'model-${gallery.metaMap['model_id']}');
            if (matchedModels.isNotEmpty) {
              selectedModel = matchedModels.first;
            }
          }

          if (gallery.metaMap['image_ratio'] != null && gallery.metaMap['image_ratio'] != '') {
            selectedImageSize = gallery.metaMap['image_ratio']!;
          }

          if (gallery.metaMap['filter_id'] != null && gallery.metaMap['filter_id'] > 0) {
            final matchedStyles = capacity!.filters.where((e) => e.id == gallery.metaMap['filter_id']);
            if (matchedStyles.isNotEmpty) {
              selectedStyle = matchedStyles.first;
            }
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
      Cache().boolGet(key: 'creative:tutorials:${widget.mode}:dialog').then((show) {
        if (!show) {
          return;
        }

        openDefaultTutorials(onConfirm: () {
          Cache().setBool(
            key: 'creative:tutorials:${widget.mode}:dialog',
            value: false,
            duration: const Duration(days: 30),
          );
        });
      });
    }

    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == 'image-to-image'
                ? AppLocale.imageToImage.getString(context)
                : AppLocale.textToImage.getString(context),
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

  Widget buildEditPanel(BuildContext context, CustomColors customColors) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColumnBlock(
            innerPanding: 10,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            children: [
              // 上传图片
              if (widget.mode == 'image-to-image')
                ImageSelector(
                  onImageSelected: ({path, data}) {
                    if (path != null) {
                      setState(() {
                        selectedImagePath = path;
                        selectedImageData = null;
                      });
                    }

                    if (data != null) {
                      setState(() {
                        selectedImageData = data;
                        selectedImagePath = null;
                      });
                    }
                  },
                  selectedImagePath: selectedImagePath,
                  selectedImageData: selectedImageData,
                  title: AppLocale.referenceImage.getString(context),
                  height: _calImageSelectorHeight(context),
                  titleHelper: InkWell(
                    onTap: () {
                      showBeautyDialog(
                        context,
                        type: QuickAlertType.info,
                        text: AppLocale.referenceImageNote.getString(context),
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
                ),

              // 图片风格
              if (capacity != null && capacity!.showStyle && capacity!.filters.isNotEmpty)
                ImageStyleSelector(
                  styles: capacity!.filters,
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
              // 生成内容
              if (widget.mode == 'text-to-image') ...buildPromptField(customColors),
              // AI 优化配置
              if (capacity != null && capacity!.showAIRewrite && widget.mode != 'image-to-image')
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
                if (widget.mode == 'image-to-image' && capacity != null && capacity!.showPromptForImage2Image)
                  ...buildPromptField(customColors),
                // 反向提示语
                if ((capacity != null && capacity!.showNegativeText) || forceShowNegativePrompt)
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
                // 原图相似度
                if (capacity != null && capacity!.showImageStrength && widget.mode == 'image-to-image')
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(AppLocale.imagination.getString(context)),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              showBeautyDialog(
                                context,
                                type: QuickAlertType.info,
                                text: '想象力\n\n提高想象力，得到更有创造力的内容。降低想象力，效果与参考图更相似。',
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
                          value: imageStrength ?? 0.65,
                          min: 0,
                          max: 1,
                          divisions: 20,
                          label: imageStrengthText(),
                          activeColor: customColors.linkColor,
                          onChanged: (value) {
                            setState(() {
                              imageStrength = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        ((imageStrength ?? 0) * 100).toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 12,
                          color: customColors.weakTextColor,
                        ),
                      ),
                    ],
                  ),
                // 图片数量
                if (capacity != null && capacity!.showImageCount && widget.mode != 'image-to-image')
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
                // 图片尺寸
                if (capacity != null && capacity!.allowRatios.isNotEmpty && widget.mode != 'image-to-image')
                  EnhancedInput(
                    title: Text(
                      AppLocale.imageSize.getString(context),
                      style: TextStyle(
                        color: customColors.textfieldLabelColor,
                        fontSize: 16,
                      ),
                    ),
                    value: ImageSize(aspectRatio: selectedImageSize),
                    onPressed: () {
                      openListSelectDialog(
                        context,
                        capacity!.allowRatios.map((e) => SelectorItem(ImageSize(aspectRatio: e), e)).toList(),
                        (value) {
                          setState(() {
                            selectedImageSize = value.value;
                          });

                          return true;
                        },
                        value: selectedImageSize,
                        heightFactor: 0.3,
                        horizontal: true,
                        horizontalCount: capacity!.allowRatios.length > 3 ? 4 : capacity!.allowRatios.length,
                      );
                    },
                  ),
              ],
            ),
          if (showAdvancedOptions)
            ColumnBlock(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              children: [
                // 模型
                if (capacity != null && capacity!.vendorModels.isNotEmpty)
                  EnhancedInput(
                    title: Text(
                      AppLocale.model.getString(context),
                      style: TextStyle(
                        color: customColors.textfieldLabelColor,
                        fontSize: 16,
                      ),
                    ),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width - 200,
                      child: Text(
                        selectedModel?.name ?? '自动',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () {
                      openListSelectDialog(
                        context,
                        [
                          SelectorItem(const Text('自动'), null),
                          ...capacity!.vendorModels
                              .map((e) => SelectorItem(
                                    Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(top: 25, bottom: 10),
                                          alignment: Alignment.center,
                                          child: Text(
                                            e.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 14),
                                            textWidthBasis: TextWidthBasis.longestLine,
                                          ),
                                        ),
                                        if (e.vendor != null && e.vendor!.isNotEmpty)
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: CustomSize.borderRadius,
                                                color: modelTypeTagColors[e.vendor!],
                                              ),
                                              child: Text(
                                                e.vendor!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    e.id,
                                    search: (keywrod) {
                                      return e.name.contains(keywrod) ||
                                          (e.vendor != null && e.vendor!.contains(keywrod));
                                    },
                                  ))
                              .toList(),
                        ],
                        (value) {
                          setState(() {
                            if (value.value == null) {
                              selectedModel = null;
                              return;
                            }

                            selectedModel = capacity!.vendorModels.firstWhere((e) => e.id == value.value);
                          });
                          return true;
                        },
                        heightFactor: 0.8,
                        value: selectedModel?.id,
                        enableSearch: true,
                        innerPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                      );
                    },
                  ),
                if (capacity != null &&
                    capacity!.showUpscaleBy &&
                    capacity!.allowUpscaleBy.isNotEmpty &&
                    (selectedModel?.upscale ?? false))
                  EnhancedInput(
                    title: Text(
                      'Upscale',
                      style: TextStyle(
                        color: customColors.textfieldLabelColor,
                        fontSize: 16,
                      ),
                    ),
                    value: Text(upscaleBy ?? '自动'),
                    onPressed: () {
                      openListSelectDialog(
                        context,
                        [
                          SelectorItem(const Text('自动'), null),
                          ...capacity!.allowUpscaleBy.map((e) => SelectorItem(Text(e), e)).toList(),
                        ],
                        (value) {
                          setState(() {
                            upscaleBy = value.value;
                          });
                          return true;
                        },
                        heightFactor: 0.5,
                        value: upscaleBy,
                      );
                    },
                  ),

                // Seed
                if (capacity != null && capacity!.showSeed)
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
          final examples = await APIServer().exampleByTag('image-generation');
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
    if (prompt.isEmpty && widget.mode == 'text-to-image') {
      showErrorMessage(AppLocale.contentIsRequired.getString(context));
      return;
    }

    if (widget.mode == 'image-to-image' && selectedImagePath == null && selectedImageData == null) {
      showErrorMessage(AppLocale.selectReferenceImage.getString(context));
      return;
    }

    final seed = int.tryParse(seedController.text);
    if (seed != null && (seed < 0 || seed > 2147483647)) {
      showErrorMessage('Seed 取值范围为 0 ~ 2147483647');
      return;
    }

    var params = <String, dynamic>{
      'prompt': prompt,
      'negative_prompt': negativePromptController.text,
      'prompt_tags': selectedTags.map((e) => e.value).join(','),
      'filter_id': selectedStyle?.id,
      'image_ratio': selectedImageSize,
      'image_count': generationImageCount,
      'ai_rewrite': enableAIRewrite,
      'gallery_copy_id': widget.galleryCopyId,
      'upscale_by': upscaleBy,
      'model': selectedModel?.id,
      'image_strength': imageStrength,
      'seed': seed,
    };

    if (selectedImagePath != null && selectedImagePath!.isNotEmpty) {
      params['image'] = 'https://${selectedImagePath ?? 'demo'}'; // 仅用于测试消耗量，正式上传后会被替换为 URL
    }

    if (selectedImageData != null && selectedImageData!.isNotEmpty) {
      params['image'] = "https://fake-image-url.com";
    }

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
        cancel();

        if (params['image'] != null && params['image'] != '') {
          final cancel = BotToast.showCustomLoading(
            toastBuilder: (cancel) {
              return LoadingIndicator(
                message: AppLocale.imageUploading.getString(context),
              );
            },
            allowClick: false,
          );

          if (selectedImagePath != null &&
              (selectedImagePath!.startsWith('http://') || selectedImagePath!.startsWith('https://'))) {
            params['image'] = selectedImagePath;
            cancel();
          } else {
            if (selectedImagePath != null && selectedImagePath!.isNotEmpty) {
              final uploadRes =
                  await ImageUploader(widget.setting).upload(selectedImagePath!).whenComplete(() => cancel());
              params['image'] = uploadRes.url;
            } else if (selectedImageData != null && selectedImageData!.isNotEmpty) {
              final uploadRes =
                  await ImageUploader(widget.setting).uploadData(selectedImageData!).whenComplete(() => cancel());
              params['image'] = uploadRes.url;
            }
          }
        }

        final taskId = await APIServer().creativeIslandCompletionsAsyncV2(params);

        stopPeriodQuery = false;

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
      final res = await APIServer().creativeIslandCompletionsEvaluateV2(params);
      if (!res.enough) {
        if (context.mounted) {
          showBeautyDialog(
            // ignore: use_build_context_synchronously
            context,
            type: QuickAlertType.warning,
            // ignore: use_build_context_synchronously
            text: AppLocale.quotaExceeded.getString(context),
            confirmBtnText: '立即购买',
            showCancelBtn: true,
            onConfirmBtnTap: () {
              context.pop();
              context.push('/payment');
            },
          );
        }
        return;
      }
      if (res.cost > 0) {
        cancel();
        openConfirmDialog(
          // ignore: use_build_context_synchronously
          context,
          '本次请求预计消耗 ${res.cost} 个智慧果，是否继续操作？',
          () => request(res.waitDuration ?? 60),
        );
      } else {
        request(res.waitDuration ?? 60);
      }
    } catch (e) {
      cancel();
      // ignore: use_build_context_synchronously
      showErrorMessageEnhanced(context, e);
    }
  }

  String imageStrengthText() {
    if (imageStrength == 0) {
      return '自动';
    }

    if (imageStrength! >= 0.4 && imageStrength! <= 0.67) {
      return '适中';
    }

    if (imageStrength! > 0.65 && imageStrength! < 0.9) {
      return '更有创造力';
    }

    if (imageStrength! >= 0.9) {
      return '尽情发挥创造力';
    }

    return '更接近参考图';
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

  double _calImageSelectorHeight(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (width > CustomSize.smallWindowSize) {
      width = CustomSize.smallWindowSize;
    }

    return width - 15 * 2 - 10 * 2 - 10;
  }
}
