import 'dart:io';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/chat/chat_input_button.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/voice_record.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/file_preview.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatInput extends StatefulWidget {
  final Function(String value) onSubmit;
  final ValueNotifier<bool> enableNotifier;
  final bool enableImageUpload;
  final Function(List<FileUpload> files)? onImageSelected;
  final List<FileUpload>? selectedImageFiles;
  final Function()? onNewChat;
  final String hintText;
  final Function()? onVoiceRecordTappedEvent;
  final List<Widget> Function()? toolsBuilder;
  final Function()? onStopGenerate;
  final Function(bool hasFocus)? onFocusChange;

  // Whether to enable file uploading
  final bool enableFileUpload;
  // Selected file for uploading
  final FileUpload? selectedFile;
  final Function(FileUpload? file)? onFileSelected;

  const ChatInput({
    super.key,
    required this.onSubmit,
    required this.enableNotifier,
    this.enableImageUpload = true,
    this.onNewChat,
    this.hintText = '',
    this.onVoiceRecordTappedEvent,
    this.toolsBuilder,
    this.onImageSelected,
    this.selectedImageFiles,
    this.onStopGenerate,
    this.onFocusChange,
    this.enableFileUpload = false,
    this.selectedFile,
    this.onFileSelected,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();

  /// 用于监听键盘事件，实现回车发送消息，Shift+Enter换行
  late final FocusNode _focusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (!HardwareKeyboard.instance.isShiftPressed && event.logicalKey.keyLabel == 'Enter') {
        if (event is KeyDownEvent && widget.enableNotifier.value) {
          _handleSubmited(_textController.text.trim());
        }

        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  final maxLength = 150000;
  var hasCamera = false;
  var showExtensionButtons = false;

  // Whether to display the bottom tool bar
  var showBottomTools = false;
  // Whether the input box is focused
  var inputFocused = false;

  @override
  void initState() {
    super.initState();

    if (!PlatformTool.isDesktopAndWeb()) {
      availableCameras().then((cameras) {
        setState(() {
          hasCamera = cameras.isNotEmpty;
        });
      });
    }

    _textController.addListener(() {
      setState(() {});
    });

    // 机器人回复完成后自动输入框自动获取焦点
    if (!PlatformTool.isAndroid() && !PlatformTool.isIOS()) {
      widget.enableNotifier.addListener(() {
        if (widget.enableNotifier.value) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Whether the user can upload images
  bool get canUploadImage =>
      widget.enableImageUpload &&
      Ability().supportImageUploader &&
      widget.onImageSelected != null &&
      Ability().supportWebSocket;

  // Whether the user can upload files
  bool get canUploadFile => widget.enableFileUpload && Ability().supportWebSocket;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: PlatformTool.isDesktopAndWeb() ? const EdgeInsets.all(8) : null,
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          decoration: BoxDecoration(
            color: customColors.chatInputAreaBackground,
            borderRadius: PlatformTool.isDesktopAndWeb()
                ? BorderRadius.circular(CustomSize.radiusValue)
                : const BorderRadius.only(
                    topLeft: Radius.circular(CustomSize.radiusValue * 2),
                    topRight: Radius.circular(CustomSize.radiusValue * 2),
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(-1, -1),
                blurRadius: CustomSize.radiusValue,
              ),
              if (PlatformTool.isDesktopAndWeb())
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(-1, -1),
                  blurRadius: CustomSize.radiusValue,
                ),
            ],
          ),
          child: Builder(builder: (context) {
            final setting = context.read<SettingRepository>();
            return SafeArea(
              child: Column(
                children: [
                  // 选中的图片预览
                  if (widget.selectedImageFiles != null && widget.selectedImageFiles!.isNotEmpty)
                    buildSelectedImagePreview(customColors),
                  // 选中文件预览
                  if (widget.selectedFile != null) buildSelectedFilePreview(customColors),
                  // 聊天内容输入栏
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            inputFocused = hasFocus;
                          });

                          widget.onFocusChange?.call(hasFocus);
                        },
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: inputFocused ? 10 : 3,
                          minLines: 1,
                          maxLength: maxLength,
                          focusNode: _focusNode,
                          controller: _textController,
                          style: const TextStyle(fontSize: CustomSize.defaultHintTextSize),
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            hintStyle: TextStyle(
                              fontSize: CustomSize.defaultHintTextSize,
                              color: customColors.textfieldHintColor,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (widget.enableNotifier.value && (canUploadImage || canUploadFile))
                                buildUploadButtons(context, setting, customColors),
                              if (widget.toolsBuilder != null) ...widget.toolsBuilder!(),
                            ],
                          ),
                          _buildSendOrVoiceButton(context, customColors),
                        ],
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: showExtensionButtons && widget.enableNotifier.value ? 80 : 0,
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              if (canUploadImage && hasCamera)
                                ChatInputSquareButton(
                                  icon: Icons.camera_alt,
                                  onPressed: () {
                                    onTakePhotoButtonPressed(context, customColors);
                                  },
                                  text: AppLocale.takePhoto.getString(context),
                                ),
                              if (canUploadImage)
                                ChatInputSquareButton(
                                  icon: Icons.photo_library,
                                  onPressed: () {
                                    onImageUploadButtonPressed();
                                  },
                                  text: AppLocale.photoLibrary.getString(context),
                                ),
                              if (canUploadFile)
                                ChatInputSquareButton(
                                  icon: Icons.upload_file_sharp,
                                  onPressed: () {
                                    onFileUploadButtonPressed();
                                  },
                                  text: AppLocale.fileLibrary.getString(context),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: PlatformTool.isMobile() && inputFocused ? 8 : 6),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildSelectedFilePreview(CustomColors customColors) {
    var maxWidth = MediaQuery.of(context).size.width * 0.8;
    if (maxWidth > 300) {
      maxWidth = 300;
    }

    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(5),
            child: Stack(
              children: [
                FilePreview(
                  fileType: widget.selectedFile!.file.extension ?? '',
                  maxWidth: maxWidth,
                  filename: widget.selectedFile!.file.name,
                ),
                if (widget.enableNotifier.value)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          widget.onFileSelected?.call(null);
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
        ],
      ),
    );
  }

  Widget buildSelectedImagePreview(CustomColors customColors) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: widget.selectedImageFiles!
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
                    if (widget.enableNotifier.value)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              widget.selectedImageFiles!.remove(e);
                              widget.onImageSelected?.call(widget.selectedImageFiles!);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: CustomSize.borderRadius * 3,
                              color: customColors.chatRoomBackground,
                              border: Border.all(
                                color: customColors.weakTextColor ?? Colors.white,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
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
    );
  }

  /// 构建发送或者语音按钮
  Widget _buildSendOrVoiceButton(
    BuildContext context,
    CustomColors customColors,
  ) {
    if (!widget.enableNotifier.value) {
      return InkWell(
        onTap: () {
          if (widget.onStopGenerate != null) {
            openConfirmDialog(
              context,
              AppLocale.confirmStopOutput.getString(context),
              () {
                widget.onStopGenerate!();
                HapticFeedbackHelper.heavyImpact();
              },
              danger: true,
            );
          }
        },
        child: LoadingAnimationWidget.beat(
          color: customColors.linkColor ?? Colors.green,
          size: 20,
        ),
      );
    }

    return _textController.text == '' && Ability().supportVoiceChat
        ? IconButton(
            onPressed: () {
              HapticFeedbackHelper.mediumImpact();

              openModalBottomSheet(
                context,
                (context) {
                  return VoiceRecord(
                    onFinished: (text) {
                      _textController.text = text;
                      Navigator.pop(context);
                    },
                    onStart: () {
                      widget.onVoiceRecordTappedEvent?.call();
                    },
                  );
                },
                isScrollControlled: false,
                heightFactor: 0.8,
              );
            },
            icon: Icon(
              Icons.mic_none_outlined,
              color: customColors.chatInputPanelText,
            ),
            splashRadius: 20,
            color: customColors.chatInputPanelText,
          )
        : IconButton(
            onPressed: () => _handleSubmited(_textController.text.trim()),
            icon: Icon(
              Icons.send,
              color: customColors.chatInputPanelText,
            ),
            splashRadius: 20,
            color: customColors.chatInputPanelText,
          );
  }

  // Image upload button event
  void onImageUploadButtonPressed() async {
    HapticFeedbackHelper.mediumImpact();
    if (widget.selectedImageFiles != null && widget.selectedImageFiles!.length >= 4) {
      showSuccessMessage(AppLocale.uploadImageLimit4.getString(context));
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      allowCompression: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final files = widget.selectedImageFiles ?? [];
      files.addAll(result.files.map((e) => FileUpload(file: e)).toList());
      widget.onImageSelected?.call(files.sublist(0, files.length > 4 ? 4 : files.length));
    }
  }

  // File upload button event
  void onFileUploadButtonPressed() async {
    HapticFeedbackHelper.mediumImpact();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'md'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      if (widget.onFileSelected != null) {
        widget.onFileSelected?.call(FileUpload(file: result.files.first));
      }
    }
  }

  /// Build image or file upload button
  Widget buildUploadButtons(
    BuildContext context,
    SettingRepository setting,
    CustomColors customColors,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          showExtensionButtons = !showExtensionButtons;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: customColors.tagsBackground,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedRotation(
          turns: showExtensionButtons ? 0.125 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.add,
            color: customColors.chatInputPanelText,
            size: 18,
          ),
        ),
      ),
    );
  }

  // Take a photo
  void onTakePhotoButtonPressed(BuildContext context, CustomColors customColors) {
    HapticFeedbackHelper.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocale.takePhoto.getString(context)),
            backgroundColor: customColors.backgroundColor,
          ),
          body: CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photo(),
            enablePhysicalButton: true,
            onMediaCaptureEvent: (mediaCapture) async {
              if (mediaCapture.status == MediaCaptureStatus.success) {
                final file = FileUpload(
                    file: PlatformFile(
                  path: mediaCapture.captureRequest.path!,
                  name: mediaCapture.captureRequest.path!.split('/').last,
                  size: await File(mediaCapture.captureRequest.path!).length(),
                ));

                final files = widget.selectedImageFiles ?? [];
                files.add(file);
                widget.onImageSelected?.call(files.sublist(0, files.length > 4 ? 4 : files.length));

                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ),
      ),
    );
  }

  /// 处理输入框提交
  void _handleSubmited(String text, {bool notSend = false}) {
    if (notSend) {
      var cursorPos = _textController.selection.base.offset;
      if (cursorPos < 0) {
        _textController.text = text;
      } else {
        String suffixText = _textController.text.substring(cursorPos);
        String prefixText = _textController.text.substring(0, cursorPos);
        _textController.text = prefixText + text + suffixText;
        _textController.selection = TextSelection(
          baseOffset: cursorPos + text.length,
          extentOffset: cursorPos + text.length,
        );
      }

      _focusNode.requestFocus();

      return;
    }

    if (text != '') {
      widget.onSubmit(text);
      _textController.clear();
    }
  }
}
