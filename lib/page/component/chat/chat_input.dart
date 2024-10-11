import 'dart:io';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/voice_record.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_popup_menu.dart';
import 'package:askaide/page/component/file_preview.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatInput extends StatefulWidget {
  final Function(String value) onSubmit;
  final ValueNotifier<bool> enableNotifier;
  final Widget? toolbar;
  final bool enableImageUpload;
  final Function(List<FileUpload> files)? onImageSelected;
  final List<FileUpload>? selectedImageFiles;
  final Function()? onNewChat;
  final String hintText;
  final Function()? onVoiceRecordTappedEvent;
  final List<Widget> Function()? leftSideToolsBuilder;
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
    this.toolbar,
    this.onNewChat,
    this.hintText = '',
    this.onVoiceRecordTappedEvent,
    this.leftSideToolsBuilder,
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
      if (!HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey.keyLabel == 'Enter') {
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

  /// Maximum height of the chat input box
  var maxLines = 5;

  @override
  void initState() {
    super.initState();

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
  bool get canUploadFile =>
      widget.enableFileUpload && Ability().supportWebSocket;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: customColors.backgroundColor,
      ),
      child: Builder(builder: (context) {
        final setting = context.read<SettingRepository>();
        return SafeArea(
          child: Column(
            children: [
              // 选中的图片预览
              if (widget.selectedImageFiles != null &&
                  widget.selectedImageFiles!.isNotEmpty)
                buildSelectedImagePreview(customColors),
              // 选中文件预览
              if (widget.selectedFile != null)
                buildSelectedFilePreview(customColors),
              // 工具栏
              if (widget.toolbar != null) widget.toolbar!,
              // if (widget.toolbar != null)
              const SizedBox(height: 8),
              // 聊天内容输入栏
              SingleChildScrollView(
                child: Slidable(
                  startActionPane: widget.onNewChat != null
                      ? ActionPane(
                          extentRatio: 0.3,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              autoClose: true,
                              label: AppLocale.newChat.getString(context),
                              backgroundColor: Colors.blue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              onPressed: (_) {
                                widget.onNewChat!();
                              },
                            ),
                            const SizedBox(width: 10),
                          ],
                        )
                      : null,
                  child: Row(
                    children: [
                      // 聊天功能按钮
                      Row(
                        children: [
                          if (widget.leftSideToolsBuilder != null)
                            ...widget.leftSideToolsBuilder!(),
                          if (widget.enableNotifier.value &&
                              (canUploadImage || canUploadFile))
                            buildUploadButtons(context, setting, customColors),
                        ],
                      ),
                      // 聊天输入框
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: customColors.chatInputAreaBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      if (hasFocus) {
                                        maxLines = 10;
                                      } else {
                                        maxLines = 5;
                                      }
                                    });

                                    widget.onFocusChange?.call(hasFocus);
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    maxLines: maxLines,
                                    minLines: 1,
                                    maxLength: maxLength,
                                    focusNode: _focusNode,
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText: widget.hintText,
                                      hintStyle: const TextStyle(
                                        fontSize:
                                            CustomSize.defaultHintTextSize,
                                      ),
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                  ),
                                ),
                              ),
                              // 聊天发送按钮
                              _buildSendOrVoiceButton(context, customColors),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
                          borderRadius: BorderRadius.circular(10),
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
                      borderRadius: BorderRadius.circular(5),
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
                              widget.onImageSelected
                                  ?.call(widget.selectedImageFiles!);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
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

    return _textController.text == ''
        ? InkWell(
            onTap: () {
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
            child: Icon(
              Icons.mic,
              color: customColors.chatInputPanelText,
            ),
          )
        : IconButton(
            onPressed: () => _handleSubmited(_textController.text.trim()),
            icon: Icon(
              Icons.send,
              color: _textController.text.trim().isNotEmpty
                  ? const Color.fromARGB(255, 70, 165, 73)
                  : null,
            ),
            splashRadius: 20,
            tooltip: AppLocale.send.getString(context),
            color: customColors.chatInputPanelText,
          );
  }

  // Image upload button event
  void onImageUploadButtonPressed() async {
    HapticFeedbackHelper.mediumImpact();
    if (widget.selectedImageFiles != null &&
        widget.selectedImageFiles!.length >= 4) {
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
      widget.onImageSelected
          ?.call(files.sublist(0, files.length > 4 ? 4 : files.length));
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
    if (canUploadImage && !canUploadFile) {
      return IconButton(
        onPressed: onImageUploadButtonPressed,
        icon: const Icon(Icons.camera_alt),
        color: customColors.chatInputPanelText,
        splashRadius: 20,
        tooltip: AppLocale.uploadImage.getString(context),
      );
    }

    if (!canUploadImage && canUploadFile) {
      return IconButton(
        onPressed: onFileUploadButtonPressed,
        icon: const Icon(Icons.upload_file),
        color: customColors.chatInputPanelText,
        splashRadius: 20,
        tooltip: AppLocale.uploadDocument.getString(context),
      );
    }

    return EnhancedPopupMenu(
      icon: Icons.upload_file,
      color: customColors.chatInputPanelText,
      tooltip: AppLocale.upload.getString(context),
      items: [
        EnhancedPopupMenuItem(
          title: AppLocale.uploadImage.getString(context),
          icon: Icons.camera_alt,
          onTap: (ctx) async {
            onImageUploadButtonPressed();
          },
        ),
        EnhancedPopupMenuItem(
          title: AppLocale.uploadDocument.getString(context),
          icon: Icons.attach_file,
          onTap: (ctx) {
            onFileUploadButtonPressed();
          },
        ),
      ],
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
