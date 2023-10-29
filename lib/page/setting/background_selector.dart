import 'dart:ui';

import 'package:askaide/bloc/background_image_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

class BackgroundSelectorScreen extends StatefulWidget {
  final SettingRepository setting;

  const BackgroundSelectorScreen({super.key, required this.setting});

  @override
  State<BackgroundSelectorScreen> createState() =>
      _BackgroundSelectorScreenState();
}

class _BackgroundSelectorScreenState extends State<BackgroundSelectorScreen> {
  final TextEditingController _controller = TextEditingController();
  bool selectDialogOpened = false;
  double blur = 10;
  bool showOriginalImage = false;

  @override
  void initState() {
    super.initState();
    context.read<BackgroundImageBloc>().add(BackgroundImageLoadEvent());

    _controller.text = widget.setting.stringDefault(settingBackgroundImage, '');
    blur = widget.setting.doubleDefault(settingBackgroundImageBlur, 10);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.backgroundSetting.getString(context)),
        centerTitle: true,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('图片选择'),
                const SizedBox(height: 10),
                BlocBuilder<BackgroundImageBloc, BackgroundImageState>(
                  buildWhen: (previous, current) =>
                      current is BackgroundImageLoaded,
                  builder: (context, state) {
                    if (state is BackgroundImageLoaded) {
                      return GridView.count(
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _controller.text = '';
                                blur = 0;
                              });
                            },
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      Image.asset('assets/light-dark-auto.png'),
                                ),
                                Positioned(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '跟随系统',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromARGB(255, 146, 146, 146),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (var img in state.images)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _controller.text = img.url;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImageEnhanced(
                                    imageUrl: img.preview),
                              ),
                            ),
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
                                    _controller.text = result.files.first.path!;
                                  });
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: customColors.textFieldBorderColor!,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                      color: customColors.chatInputPanelText,
                                    ),
                                    Text(
                                      '自定义',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: customColors.chatInputPanelText
                                            ?.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                const Text('图片预览'),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onLongPressStart: (details) {
                      setState(() {
                        showOriginalImage = true;
                      });
                    },
                    onLongPressEnd: (details) {
                      setState(() {
                        showOriginalImage = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: _controller.text != ''
                            ? DecorationImage(
                                image: resolveImageProvider(_controller.text),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: customColors.backgroundContainerColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: customColors.textFieldBorderColor!,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: showOriginalImage ? 0 : blur,
                          sigmaY: showOriginalImage ? 0 : blur,
                        ),
                        child:
                            const SizedBox(width: double.infinity, height: 200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('模糊程度'),
                    Text(blur.toStringAsFixed(0)),
                  ],
                ),
                Slider(
                  value: blur,
                  min: 0,
                  max: 50,
                  divisions: 10,
                  label: blur == 0 ? '无模糊' : '模糊程度：${blur.toStringAsFixed(0)}',
                  activeColor: customColors.linkColor,
                  onChanged: (value) {
                    setState(() {
                      blur = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                EnhancedButton(
                  onPressed: () {
                    widget.setting
                        .set(settingBackgroundImageBlur, blur.toString());

                    final originalFilepath =
                        widget.setting.get(settingBackgroundImage);

                    if (originalFilepath != _controller.text) {
                      // 移除原图
                      if (originalFilepath != null &&
                          originalFilepath != '' &&
                          !originalFilepath.startsWith('http')) {
                        removeExternalFile(originalFilepath);
                      }

                      // 复制新图
                      if (_controller.text != '') {
                        if (!_controller.text.startsWith('http')) {
                          copyExternalFileToAppDocs(_controller.text)
                              .then((value) {
                            widget.setting.set(settingBackgroundImage, value);
                          });
                        } else {
                          widget.setting
                              .set(settingBackgroundImage, _controller.text);
                        }
                      } else {
                        // 恢复为原图
                        widget.setting.set(settingBackgroundImage, '');
                      }
                    }

                    showSuccessMessage(
                        AppLocale.operateSuccess.getString(context));
                    // Navigator.pop(context);
                  },
                  title: AppLocale.save.getString(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
