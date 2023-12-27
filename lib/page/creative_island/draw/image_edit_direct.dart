import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/global_alert.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/creative_island/draw/components/content_preview.dart';
import 'package:askaide/page/creative_island/draw/draw_result.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/creative_island/draw/components/image_selector.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

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

  /// 是否停止周期性查询任务执行状态
  var stopPeriodQuery = false;

  @override
  void initState() {
    if (widget.initImage != null && widget.initImage!.isNotEmpty) {
      selectedImagePath = widget.initImage;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
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
        backgroundColor: customColors.backgroundContainerColor,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: true,
        maxWidth: CustomSize.smallWindowSize,
        child: Column(
          children: [
            if (Ability().showGlobalAlert)
              const GlobalAlert(pageKey: 'creative_create'),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: double.infinity,
                child: SingleChildScrollView(
                  child: buildEditPanel(context, customColors),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditPanel(BuildContext context, CustomColors customColors) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.note != null && widget.note != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:
                  MessageBox(message: widget.note!, type: MessageBoxType.info),
            ),
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
          // 生成按钮
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: EnhancedButton(
                  title: AppLocale.generate.getString(context),
                  onPressed: onGenerate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void onGenerate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    HapticFeedbackHelper.mediumImpact();

    if (selectedImagePath == null && selectedImageData == null) {
      showErrorMessage('请先选择要处理的图片');
      return;
    }

    var params = <String, dynamic>{};

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
            return const LoadingIndicator(
              message: '正在上传图片，请稍后...',
            );
          },
          allowClick: false,
        );

        if (selectedImagePath != null &&
            (selectedImagePath!.startsWith('http://') ||
                selectedImagePath!.startsWith('https://'))) {
          params['image'] = selectedImagePath;
          cancel();
        } else {
          if (selectedImagePath != null && selectedImagePath!.isNotEmpty) {
            final uploadRes = await ImageUploader(widget.setting)
                .upload(selectedImagePath!)
                .whenComplete(() => cancel());
            params['image'] = uploadRes.url;
          } else if (selectedImageData != null &&
              selectedImageData!.isNotEmpty) {
            final uploadRes = await ImageUploader(widget.setting)
                .uploadData(selectedImageData!)
                .whenComplete(() => cancel());
            params['image'] = uploadRes.url;
          }
        }

        final taskId = await APIServer().creativeIslandImageDirectEdit(
          widget.apiEndpoint,
          params,
        );

        stopPeriodQuery = false;

        // ignore: use_build_context_synchronously
        Navigator.push(
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
        if (params != null &&
            resp.originImage != null &&
            resp.originImage != '') {
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
