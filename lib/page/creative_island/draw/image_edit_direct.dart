import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/advanced_button.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/global_alert.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/creative_island/draw/components/content_preview.dart';
import 'package:askaide/page/creative_island/draw/draw_result.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/creative_island/draw/components/image_selector.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';

class ImageEditDirectScreen extends StatefulWidget {
  final SettingRepository setting;
  final String title;
  final String apiEndpoint;
  final String? note;
  final int initWaitDuration;
  final String? initImage;

  const ImageEditDirectScreen({
    super.key,
    required this.setting,
    required this.title,
    required this.apiEndpoint,
    this.note,
    this.initWaitDuration = 30,
    this.initImage,
  });

  @override
  State<ImageEditDirectScreen> createState() => _ImageEditDirectScreenState();
}

class _ImageEditDirectScreenState extends State<ImageEditDirectScreen> {
  String? selectedImagePath;
  Uint8List? selectedImageData;

  TextEditingController seedController = TextEditingController();
  double? cfgScale = 0.0;
  int? motionBucketId = 0;

  bool showAdvancedOptions = false;

  /// 是否停止周期性查询任务执行状态
  var stopPeriodQuery = false;

  @override
  void initState() {
    if (widget.initImage != null && widget.initImage!.isNotEmpty) {
      selectedImagePath = widget.initImage;
    }

    if (widget.note != null) {
      if (widget.apiEndpoint == 'image-to-video') {
        Cache().boolGet(key: 'creative:tutorials:${widget.apiEndpoint}:dialog').then((show) {
          if (!show) {
            return;
          }

          openImageToVideoTutorials(onConfirm: () {
            Cache().setBool(
              key: 'creative:tutorials:${widget.apiEndpoint}:dialog',
              value: false,
              duration: const Duration(days: 30),
            );
          });
        });
      } else {
        Cache().boolGet(key: 'creative:tutorials:${widget.apiEndpoint}:dialog').then((show) {
          if (!show) {
            return;
          }

          openDefaultTutorials(onConfirm: () {
            Cache().setBool(
              key: 'creative:tutorials:${widget.apiEndpoint}:dialog',
              value: false,
              duration: const Duration(days: 30),
            );
          });
        });
      }
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

  void openImageToVideoTutorials({Function? onConfirm}) {
    showBeautyDialog(
      context,
      type: QuickAlertType.custom,
      widget: Text('      ${widget.note!}'),
      customAsset: 'assets/text-to-video.gif',
      onConfirmBtnTap: () async {
        onConfirm?.call();
        context.pop();
      },
      showCancelBtn: true,
      confirmBtnText: AppLocale.gotIt.getString(context),
    );
  }

  @override
  void dispose() {
    seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
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
            if (widget.note != null && widget.apiEndpoint == 'image-to-video')
              IconButton(
                onPressed: () {
                  openImageToVideoTutorials();
                },
                icon: const Icon(Icons.help_outline),
              )
            else if (widget.note != null)
              IconButton(
                onPressed: () {
                  openDefaultTutorials();
                },
                icon: const Icon(Icons.help_outline),
              ),
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
                title: AppLocale.originalImage.getString(context),
                height: _calImageSelectorHeight(context),
              ),
            ],
          ),
          if (showAdvancedOptions)
            ColumnBlock(
              innerPanding: 10,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              children: [
                // Cfg Scale
                Column(
                  children: [
                    Row(
                      children: [
                        const Text('Cfg Scale'),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            showBeautyDialog(
                              context,
                              type: QuickAlertType.info,
                              text:
                                  'How strongly the video sticks to the original image. \nUse lower values to allow the model more freedom to make changes and higher values to correct motion distortions',
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
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: cfgScale ?? 0.0,
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label: cfgScaleText(cfgScale),
                            activeColor: customColors.linkColor,
                            onChanged: (value) {
                              setState(() {
                                if (value > 0 && value < 1) {
                                  value = 1;
                                }

                                cfgScale = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          cfgScaleText(cfgScale),
                          style: TextStyle(
                            fontSize: 12,
                            color: customColors.weakTextColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                // Motion Bucket ID
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Motion Bucket ID'),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            showBeautyDialog(
                              context,
                              type: QuickAlertType.info,
                              text:
                                  'Lower values generally result in less motion in the output video, \nwhile higher values generally result in more motion',
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
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: (motionBucketId ?? 0).toDouble(),
                            min: 0,
                            max: 255,
                            divisions: 51,
                            label: motionBucketIdText(motionBucketId),
                            activeColor: customColors.linkColor,
                            onChanged: (value) {
                              setState(() {
                                if (value > 0 && value < 1) {
                                  value = 1;
                                }

                                motionBucketId = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(
                          motionBucketIdText(motionBucketId),
                          style: TextStyle(
                            fontSize: 12,
                            color: customColors.weakTextColor,
                          ),
                        ),
                      ],
                    )
                  ],
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
          if (widget.apiEndpoint == 'image-to-video')
            AdvancedButton(
              showAdvancedOptions: showAdvancedOptions,
              onPressed: (value) {
                setState(() {
                  showAdvancedOptions = value;
                });
              },
            ),
          if (widget.apiEndpoint == 'image-to-video') const SizedBox(height: 10),
          EnhancedButton(
            title: AppLocale.generate.getString(context),
            onPressed: onGenerate,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String cfgScaleText(double? cfgScale) {
    cfgScale ??= 0;
    return cfgScale == 0 ? 'Auto' : cfgScale.toStringAsFixed(1);
  }

  String motionBucketIdText(int? motionBucketId) {
    motionBucketId ??= 0;
    return motionBucketId == 0 ? 'Auto' : motionBucketId.toString();
  }

  void onGenerate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    HapticFeedbackHelper.mediumImpact();

    if (selectedImagePath == null && selectedImageData == null) {
      showErrorMessage('请先选择要处理的图片');
      return;
    }

    var params = <String, dynamic>{};

    if (cfgScale != null && cfgScale! >= 1) {
      params['cfg_scale'] = cfgScale;
    }

    if (motionBucketId != null && motionBucketId! >= 1) {
      params['motion_bucket_id'] = motionBucketId;
    }

    final cancelOutside = BotToast.showCustomLoading(
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
        cancelOutside();

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

        final taskId = await APIServer().creativeIslandImageDirectEdit(
          widget.apiEndpoint,
          params,
        );

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
        cancelOutside();
        // ignore: use_build_context_synchronously
        showErrorMessageEnhanced(context, e);
      }
    }

    try {
      request(widget.initWaitDuration);
    } catch (e) {
      cancelOutside();
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
        if (params != null && resp.width != null) {
          params['width'] = resp.width;
        }
        if (params != null && resp.height != null) {
          params['height'] = resp.height;
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
