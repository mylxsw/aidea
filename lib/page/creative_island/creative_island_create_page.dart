import 'dart:math';

import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/creative_island/content_preview.dart';
import 'package:askaide/page/creative_island/creative_island_result.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/creative_island_repo.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';

class CreativeIslandCreatePage extends StatefulWidget {
  final String id;
  final CreativeIslandRepository repo;
  final SettingRepository setting;
  const CreativeIslandCreatePage({
    super.key,
    required this.id,
    required this.repo,
    required this.setting,
  });

  @override
  State<CreativeIslandCreatePage> createState() =>
      _CreativeIslandCreatePageState();
}

class ImageSize {
  final String name;
  final int width;
  final int height;

  const ImageSize(this.name, this.width, this.height);
}

class StabilityAIImageStyle {
  final String name;
  final String value;

  const StabilityAIImageStyle(this.name, this.value);
}

class _CreativeIslandCreatePageState extends State<CreativeIslandCreatePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _negativeTextController = TextEditingController();
  // 字数限制
  final TextEditingController _wordCountController = TextEditingController();

  var _generationImageCount = 1;

  bool selectDialogOpened = false;
  String? selectedImagePath;
  // 是否启用 AI 改写
  bool _enableAIRewrite = false;
  // 是否显示高级选项
  bool _showAdvancedOptions = false;

  CreativeIslandItemExtSize? _selectedImageSize;
  ModelStyle _imageStyle = ModelStyle(id: '', name: '');

  @override
  void initState() {
    super.initState();

    context
        .read<CreativeIslandBloc>()
        .add(CreativeIslandItemLoadEvent(widget.id));
  }

  @override
  void dispose() {
    _contentController.dispose();
    _negativeTextController.dispose();
    _wordCountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BlocConsumer<CreativeIslandBloc, CreativeIslandState>(
      listener: (context, state) {
        if (state is CreativeIslandItemLoaded) {
          setState(() {
            _enableAIRewrite = state.item.aiRewriteDefaultValue;
            if (!state.item.showAdvanceButton) {
              _showAdvancedOptions = true;
            }
          });
        }
      },
      listenWhen: (previous, current) => current is CreativeIslandItemLoaded,
      buildWhen: (previous, current) => current is CreativeIslandItemLoaded,
      builder: (context, state) {
        if (state is CreativeIslandItemLoaded) {
          return _buildIslandEditArea(
            state,
            state.item,
            context,
            customColors,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocale.creativeIsland.getString(context),
              style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
            ),
            centerTitle: true,
          ),
          body: const Center(
            child: Text('Loading ...'),
          ),
        );
      },
    );
  }

  /// 构建创意岛编辑区域
  Widget _buildIslandEditArea(
    CreativeIslandItemLoaded state,
    CreativeIslandItem item,
    BuildContext context,
    CustomColors customColors,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.title,
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
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
            child: state.item.bgImage != null
                ? Image(
                    image: CachedNetworkImageProviderEnhanced(
                      state.item.bgImage!,
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedbackHelper.mediumImpact();
              context.push('/creative-island/${widget.id}/history');
            },
            icon: const Icon(Icons.article_outlined),
          ),
        ],
      ),
      body: _buildEditPanel(customColors, state, context),
    );
  }

  /// 构建编辑面板
  Widget _buildEditPanel(
    CustomColors customColors,
    CreativeIslandItemLoaded state,
    BuildContext context,
  ) {
    return BackgroundContainer(
      setting: widget.setting,
      enabled: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上传图片（图生图）
              if (state.item.modelType == creativeIslandModelTypeImageToImage)
                ColumnBlock(
                  innerPanding: 10,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '原图',
                          style: TextStyle(
                            fontSize: 16,
                            color: customColors.textfieldLabelColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Material(
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              if (selectDialogOpened) return;

                              selectDialogOpened = true;
                              HapticFeedbackHelper.mediumImpact();
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(type: FileType.image)
                                  .whenComplete(
                                      () => selectDialogOpened = false);
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  selectedImagePath = result.files.first.path!;
                                });
                              }
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: selectedImagePath != null &&
                                                selectedImagePath != null
                                            ? BoxDecoration(
                                                image: selectedImagePath !=
                                                            null &&
                                                        selectedImagePath != ''
                                                    ? DecorationImage(
                                                        image: resolveImageProvider(
                                                            selectedImagePath!),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                                color: customColors
                                                    .backgroundContainerColor
                                                    ?.withAlpha(100),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              )
                                            : null,
                                        child: const SizedBox(
                                          width: double.infinity,
                                          height: 200,
                                        ),
                                      ),
                                      selectedImagePath == null ||
                                              selectedImagePath == ''
                                          ? SizedBox(
                                              height: 200,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt,
                                                    size: 30,
                                                    color: customColors
                                                        .chatInputPanelText,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    '选择图片',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: customColors
                                                          .chatInputPanelText
                                                          ?.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                color: const Color.fromARGB(
                                                    80, 255, 255, 255),
                                                height: 50,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons.camera_alt,
                                                      size: 30,
                                                      color: Color.fromARGB(
                                                          147, 255, 255, 255),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '点击此处更换图片',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromARGB(
                                                            147, 255, 255, 255),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              if (!state.item.noPrompt)
                ColumnBlock(
                  innerPanding: 10,
                  children: [
                    // 生成内容
                    EnhancedTextField(
                      labelPosition: LabelPosition.top,
                      labelText: state.item.promptInputTitle ??
                          (state.item.modelType == creativeIslandModelTypeText
                              ? AppLocale.writeYourIdeas.getString(context)
                              : AppLocale.describeYourImages
                                  .getString(context)),
                      customColors: customColors,
                      controller: _contentController,
                      textAlignVertical: TextAlignVertical.top,
                      hintText: state.item.hint ??
                          AppLocale.required.getString(context),
                      maxLines: 10,
                      minLines: 5,
                      maxLength: (state.item.wordCount ?? 0) > 0
                          ? state.item.wordCount
                          : 1000,
                      showCounter: false,
                      bottomButton: state.item.modelType ==
                              creativeIslandModelTypeImage
                          ? Row(
                              children: [
                                Icon(
                                  Icons.shuffle,
                                  size: 13,
                                  color: customColors.linkColor?.withAlpha(150),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '随机',
                                  style: TextStyle(
                                    color:
                                        customColors.linkColor?.withAlpha(150),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : null,
                      bottomButtonOnPressed: () async {
                        final examples = await APIServer()
                            .exampleByTag(state.item.modelType);
                        if (examples.isEmpty) {
                          return;
                        }

                        // 随机选取一个例子
                        final example =
                            examples[Random().nextInt(examples.length)];
                        _contentController.text = example.text;
                      },
                    ),
                    // 文本类生成选项
                    if (state.item.modelType == creativeIslandModelTypeText)
                      _buildTextGenerationToolbar(
                        state.item,
                        customColors,
                      ),
                  ],
                ),

              if (_showAdvancedOptions)
                ColumnBlock(
                  children: [
                    // 排除关键词
                    if (state.item.isShowNegativeText)
                      EnhancedTextField(
                        labelPosition: LabelPosition.top,
                        labelText: AppLocale.excludeContents.getString(context),
                        customColors: customColors,
                        controller: _negativeTextController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: 'text, blurry, low quality',
                        maxLength: 500,
                        showCounter: false,
                      ),

                    if (state.item.isShowAIRewrite)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('AI 优化'),
                          Switch(
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.withOpacity(0.5),
                            activeColor: customColors.linkColor,
                            value: _enableAIRewrite,
                            onChanged: (value) {
                              setState(() {
                                _enableAIRewrite = value;
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),

              // 图片风格
              if (_showAdvancedOptions &&
                  (state.item.modelType ==
                          creativeIslandModelTypeImageToImage ||
                      state.item.modelType == creativeIslandModelTypeImage) &&
                  state.item.showImageStyleSelector)
                ColumnBlock(
                  children: [
                    _buildImageStyleField(
                        context, customColors, state.item.vendor),
                  ],
                ),
              if (_showAdvancedOptions &&
                  state.item.modelType == creativeIslandModelTypeImage)
                ColumnBlock(
                  children: _buildImageGenerationToolbar(
                    customColors,
                    state.item,
                  ),
                ),

              // 生成按钮
              const SizedBox(height: 20),
              Row(
                children: [
                  if (state.item.showAdvanceButton)
                    EnhancedButton(
                      title: '高级选项',
                      width: 100,
                      backgroundColor: Colors.transparent,
                      color: customColors.weakLinkColor,
                      fontSize: 15,
                      icon: Icon(
                        _showAdvancedOptions
                            ? Icons.unfold_less
                            : Icons.unfold_more,
                        color: customColors.weakLinkColor,
                        size: 15,
                      ),
                      onPressed: () {
                        setState(() {
                          _showAdvancedOptions = !_showAdvancedOptions;
                        });
                      },
                    ),
                  if (state.item.showAdvanceButton) const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: EnhancedButton(
                      title: state.item.submitBtnText ??
                          AppLocale.generate.getString(context),
                      onPressed: () {
                        onGenerate(
                          context,
                          state.item.modelType,
                          state.item.vendor,
                          state.item.waitSeconds,
                          state.item.noPrompt,
                          customColors,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageStyleItemPreview(ModelStyle style, {double? size}) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: style.preview != null
              ? DecorationImage(
                  image: CachedNetworkImageProviderEnhanced(style.preview!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: style.preview == null
            ? const Center(
                child: Icon(
                  Icons.interests,
                  color: Colors.grey,
                  size: 40,
                ),
              )
            : null);
  }

  Widget _buildImageStyleField(
    BuildContext context,
    CustomColors customColors,
    String vendor,
  ) {
    return EnhancedInput(
      title: Text(
        AppLocale.style.getString(context),
        style: TextStyle(
          color: customColors.textfieldLabelColor,
          fontSize: 16,
        ),
      ),
      value: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_imageStyle.name == ''
              ? AppLocale.auto.getString(context)
              : _imageStyle.name),
          const SizedBox(width: 10),
          _buildImageStyleItemPreview(_imageStyle, size: 50),
        ],
      ),
      onPressed: () {
        openModalBottomSheet(
          context,
          (context) {
            return FutureBuilder(
              future: APIServer().modelStyles(vendor),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  showErrorMessage(resolveError(context, snapshot.error!));
                  return Text(
                    resolveError(context, snapshot.error!),
                    style: const TextStyle(color: Colors.red),
                  );
                }

                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                var data = snapshot.data ?? [];
                data.insert(
                  0,
                  ModelStyle(
                    id: '',
                    name: AppLocale.auto.getString(context),
                  ),
                );

                return GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  padding: const EdgeInsets.only(top: 20),
                  children: [
                    for (var item in data)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _imageStyle = item;
                          });

                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: _buildImageStyleItemPreview(item),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
          heightFactor: 0.8,
        );
      },
    );
  }

  /// 构建文本生成工具栏
  List<Widget> _buildImageGenerationToolbar(
    CustomColors customColors,
    CreativeIslandItem item,
  ) {
    return <Widget>[
      // 图片数量
      if (item.vendor == modelTypeStabilityAI || item.vendor == modelTypeLeapAI)
        EnhancedInput(
          title: Text(
            AppLocale.imageCount.getString(context),
            style: TextStyle(
              color: customColors.textfieldLabelColor,
              fontSize: 16,
            ),
          ),
          value: Text(_generationImageCount.toString()),
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
                  _generationImageCount = value.value;
                });
                return true;
              },
              // title: AppLocale.imageCount.getString(context),
              heightFactor: 0.4,
              value: _generationImageCount,
            );
          },
        ),

      //图片尺寸
      if (item.imageAllowSizes.isNotEmpty)
        EnhancedInput(
          title: Text(
            AppLocale.imageSize.getString(context),
            style: TextStyle(
              color: customColors.textfieldLabelColor,
              fontSize: 16,
            ),
          ),
          value: _selectedImageSize == null
              ? const Text('自动')
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSizeImage(_selectedImageSize!, customColors),
                  ],
                ),
          onPressed: () {
            openListSelectDialog(
              context,
              item.imageAllowSizes
                  .map(
                    (e) => SelectorItem(
                      _buildSizeImage(e, customColors),
                      e.aspectRatio,
                    ),
                  )
                  .toList(),
              (value) {
                setState(() {
                  _selectedImageSize = item.imageAllowSizes
                      .firstWhere((e) => e.aspectRatio == value.value);
                });
                return true;
              },
              // title: AppLocale.imageSize.getString(context),
              value: _selectedImageSize?.aspectRatio,
              heightFactor: 0.25,
              horizontal: true,
              horizontalCount: 4,
            );
          },
        ),
    ];
  }

  Widget _buildSizeImage(
    CreativeIslandItemExtSize e,
    CustomColors customColors,
  ) {
    final width = e.width > e.height ? 40 : 40 * e.width / e.height;
    final height = e.width > e.height ? 40 * e.height / e.width : 40;
    return Container(
      width: width.toDouble(),
      height: height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: customColors.backgroundContainerColor,
      ),
      alignment: Alignment.center,
      child: Text(
        e.aspectRatio,
        style: const TextStyle(fontSize: 12, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 构建文本生成工具栏
  Widget _buildTextGenerationToolbar(
    CreativeIslandItem item,
    CustomColors customColors,
  ) {
    return EnhancedTextField(
      labelText: AppLocale.wordCount.getString(context),
      labelPosition: LabelPosition.left,
      customColors: customColors,
      controller: _wordCountController,
      hintText: '≤ 1000',
      showCounter: false,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textDirection: TextDirection.rtl,
      fieldWidth: 50,
    );
  }

  /// 是否停止周期性查询任务执行状态
  var stopPeriodQuery = false;

  /// 生成事件处理
  void onGenerate(
    BuildContext context,
    String modelType,
    String modelCategory,
    int waitSeconds,
    bool noPrompt,
    CustomColors customColors,
  ) async {
    FocusScope.of(context).requestFocus(FocusNode());
    HapticFeedbackHelper.mediumImpact();

    final content = _contentController.text.trim();
    if (!noPrompt && content.isEmpty) {
      showErrorMessage(AppLocale.contentIsRequired.getString(context));
      return;
    }

    var params = <String, dynamic>{};

    if (modelType == creativeIslandModelTypeText) {
      final wordCount = int.parse(
          _wordCountController.text == '' ? '500' : _wordCountController.text);
      if (wordCount < 0 || wordCount > 1000) {
        showErrorMessage(AppLocale.wordCountInvalid.getString(context));
        return;
      }

      params = <String, dynamic>{
        "word_count": wordCount,
        "prompt": content,
      };
    } else if (modelType == creativeIslandModelTypeImage) {
      params = <String, dynamic>{
        "prompt": content,
        "width": _selectedImageSize?.width,
        "height": _selectedImageSize?.height,
        "image_count": _generationImageCount,
        "negative_prompt": _negativeTextController.text,
        'style_preset': _imageStyle.id,
        'ai_rewrite': _enableAIRewrite,
      };
    }
    // 图生图，先上传图片
    else if (modelType == creativeIslandModelTypeImageToImage) {
      if (selectedImagePath == null || selectedImagePath == '') {
        showErrorMessage('请选择图片');
        return;
      }

      params = <String, dynamic>{
        "prompt": content,
        "negative_prompt": _negativeTextController.text,
        'style_preset': _imageStyle.id,
        "width": _selectedImageSize?.width,
        "height": _selectedImageSize?.height,
        'ai_rewrite': _enableAIRewrite,
        'image':
            'https://${selectedImagePath ?? 'demo'}', // 仅用于测试消耗量，正式上传后会被替换为 URL
      };
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

    request() async {
      try {
        cancel();

        if (modelType == creativeIslandModelTypeImageToImage) {
          final cancel = BotToast.showCustomLoading(
            toastBuilder: (cancel) {
              return const LoadingIndicator(
                message: '正在上传图片，请稍后...',
              );
            },
            allowClick: false,
          );

          final uploadRes = await ImageUploader(widget.setting)
              .upload(selectedImagePath!)
              .whenComplete(() => cancel());
          params['image'] = uploadRes.url;
        }

        final taskId = await APIServer().creativeIslandCompletionsAsync(
          widget.id,
          params,
        );

        stopPeriodQuery = false;

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => CreativeIslandResultDialog(
              future: _generateResult(
                modelType,
                taskId,
                waitSeconds > 30 ? 5 : 3,
                params: params,
              ),
              waitDuration: waitSeconds,
            ),
          ),
        ).whenComplete(() {
          stopPeriodQuery = true;
          context.read<CreativeIslandBloc>().add(
              CreativeIslandHistoriesLoadEvent(widget.id, forceRefresh: true));
        });
      } catch (e) {
        stopPeriodQuery = true;
        cancel();
        // ignore: use_build_context_synchronously
        showErrorMessage(resolveError(context, e));
      }
    }

    try {
      final res = await APIServer()
          .creativeIslandCompletionsEvaluate(widget.id, params);
      if (!res.enough) {
        if (context.mounted) {
          showBeautyDialog(
            context,
            type: QuickAlertType.warning,
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
        // ignore: use_build_context_synchronously
        openConfirmDialog(
          context,
          '【测试专用】\n本次请求预计消耗 ${res.cost} 个智慧果，是否继续操作？',
          () => request(),
        );
      } else {
        request();
      }
    } catch (e) {
      cancel();
      showErrorMessageEnhanced(context, e);
    }
  }

  Future<IslandResult> _generateResult(
    String modelType,
    String taskId,
    int delaySeconds, {
    Map<String, dynamic>? params,
  }) async {
    return await Future.delayed(Duration(seconds: delaySeconds), () async {
      return await _queryCompletionTaskStatus(
        taskId,
        modelType,
        0,
        delaySeconds,
        params: params,
      );
    });
  }

  Future<IslandResult> _queryCompletionTaskStatus(
    String taskId,
    String modelType,
    int retryTimes,
    int delaySeconds, {
    Map<String, dynamic>? params,
  }) async {
    if (retryTimes > 60) {
      return Future.error(AppLocale.generateTimeout.getString(context));
    }

    final resp = await APIServer().asyncTaskStatus(taskId);

    if (resp.status == 'success') {
      if (modelType == creativeIslandModelTypeImage ||
          modelType == creativeIslandModelTypeImageToImage) {
        return IslandResult(
          result: resp.resources ?? const [],
          params: params,
        );
      }

      return IslandResult(
        result: [resp.resources!.join("\n\n")],
        params: params,
      );
    } else if (resp.status == 'failed') {
      return Future.error(resp.errors!.join(";"));
    } else {
      if (stopPeriodQuery) {
        // ignore: use_build_context_synchronously
        return Future.error(AppLocale.generateTimeout.getString(context));
      }

      return await Future.delayed(Duration(seconds: delaySeconds), () async {
        return await _queryCompletionTaskStatus(
          taskId,
          modelType,
          retryTimes + 1,
          delaySeconds,
          params: params,
        );
      });
    }
  }
}
