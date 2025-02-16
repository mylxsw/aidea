import 'dart:io';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/chat/file_upload.dart';
import 'package:askaide/page/component/chat/markdown.dart';
import 'package:askaide/page/component/enhanced_popup_menu.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/share.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class ChatShareMessage {
  final String? username;
  final String content;
  final String? avatarURL;
  final bool leftSide;
  final List<String>? images;

  const ChatShareMessage({
    this.username,
    required this.content,
    this.avatarURL,
    this.leftSide = true,
    this.images,
  });
}

class ChatShareScreen extends StatefulWidget {
  final List<ChatShareMessage> messages;
  const ChatShareScreen({
    super.key,
    required this.messages,
  });

  @override
  State<ChatShareScreen> createState() => _ChatShareScreenState();
}

class _ChatShareScreenState extends State<ChatShareScreen> {
  final WidgetsToImageController controller = WidgetsToImageController();

  bool showQRCode = true;
  bool usingChatStyle = true;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          actions: [
            if (!PlatformTool.isWeb())
              TextButton(
                onPressed: () async {
                  final cancel = BotToast.showCustomLoading(
                    toastBuilder: (cancel) {
                      return LoadingIndicator(
                        message: AppLocale.processingWait.getString(context),
                      );
                    },
                    allowClick: false,
                    duration: const Duration(seconds: 15),
                  );

                  try {
                    final data = await controller.capture();
                    if (data != null) {
                      final file = await writeTempFile('share-image.png', data);
                      cancel();
                      await shareTo(
                        // ignore: use_build_context_synchronously
                        context,
                        content: 'images',
                        images: [
                          file.path,
                        ],
                      );
                    }
                  } finally {
                    cancel();
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.share, size: 14, color: customColors.weakLinkColor),
                    const SizedBox(width: 5),
                    Text(
                      AppLocale.share.getString(context),
                      style: TextStyle(color: customColors.weakLinkColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            EnhancedPopupMenu(
              items: [
                EnhancedPopupMenuItem(
                  title: AppLocale.saveToLocal.getString(context),
                  icon: Icons.save,
                  onTap: (ctx) async {
                    final cancel = BotToast.showCustomLoading(
                      toastBuilder: (cancel) {
                        return LoadingIndicator(
                          message: AppLocale.processingWait.getString(context),
                        );
                      },
                      allowClick: false,
                      duration: const Duration(seconds: 15),
                    );

                    try {
                      final data = await controller.capture();
                      if (data != null) {
                        cancel();
                        // ignore: use_build_context_synchronously

                        if (PlatformTool.isIOS() || PlatformTool.isAndroid()) {
                          await ImageGallerySaver.saveImage(data, quality: 100);

                          showSuccessMessage(AppLocale.operateSuccess.getString(context));
                        } else {
                          if (PlatformTool.isWindows()) {
                            FileSaver.instance
                                .saveAs(
                              name: randomId(),
                              bytes: data,
                              ext: '.png',
                              mimeType: MimeType.png,
                            )
                                .then((value) async {
                              if (value == null) {
                                return;
                              }

                              await File(value).writeAsBytes(data);

                              Logger.instance.d('File saved successfully: $value');
                              showSuccessMessage(AppLocale.operateSuccess.getString(context));
                            });
                          } else {
                            FileSaver.instance
                                .saveFile(
                              name: randomId(),
                              bytes: data,
                              ext: 'png',
                              mimeType: MimeType.png,
                            )
                                .then((value) {
                              showSuccessMessage(AppLocale.operateSuccess.getString(context));
                            });
                          }
                        }
                      }
                    } finally {
                      cancel();
                    }
                  },
                ),
                EnhancedPopupMenuItem(
                  title: showQRCode
                      ? AppLocale.dontShowInviteCode.getString(context)
                      : AppLocale.showInviteCode.getString(context),
                  icon: showQRCode ? Icons.visibility_off : Icons.visibility,
                  onTap: (ctx) {
                    setState(() {
                      showQRCode = !showQRCode;
                    });
                  },
                ),
                EnhancedPopupMenuItem(
                  title: usingChatStyle ? '使用列表风格' : '使用聊天风格',
                  icon: usingChatStyle ? Icons.list : Icons.chat,
                  onTap: (ctx) {
                    setState(() {
                      usingChatStyle = !usingChatStyle;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: customColors.backgroundContainerColor,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CustomSize.maxWindowSize,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: FutureBuilder(
                    future: APIServer().shareInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(resolveError(context, snapshot.error!)),
                        );
                      }

                      if (snapshot.hasData) {
                        return buildShareWindow(customColors, context, snapshot);
                      }

                      return const Center(
                        child: Text('Loading ...'),
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShareWindow(CustomColors customColors, BuildContext context, AsyncSnapshot<ShareInfo> snapshot) {
    return WidgetsToImage(
      controller: controller,
      child: Container(
        color: customColors.backgroundContainerColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            usingChatStyle ? buildChatPreview(context, customColors) : buildListPreview(context, customColors),
            if (showQRCode) buildQRCodePanel(customColors, snapshot),
          ],
        ),
      ),
    );
  }

  Widget buildQRCodePanel(CustomColors customColors, AsyncSnapshot<ShareInfo> snapshot) {
    return Container(
      color: customColors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 20,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: CustomSize.borderRadius,
              child: CachedNetworkImageEnhanced(
                imageUrl: snapshot.data!.qrCode,
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                snapshot.data!.message,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListPreview(BuildContext context, CustomColors customColors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Column(
        children: widget.messages.map((message) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (message.avatarURL != null && message.leftSide) _buildAvatar(avatarUrl: message.avatarURL),
                      if (message.username != null && message.leftSide)
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 7),
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Text(
                            message.username!,
                            style: TextStyle(
                              color: customColors.weakTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (message.images != null && message.images!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: _chatBoxImagePreviewWidth(context, (message.images ?? []).length)),
                        child: FileUploadPreview(images: message.images ?? []),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _chatBoxMaxWidth(context),
                    ),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 7),
                      decoration: BoxDecoration(
                        borderRadius: CustomSize.borderRadius,
                        color: message.leftSide
                            ? customColors.chatRoomReplyBackground
                            : customColors.chatRoomSenderBackground,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Builder(
                        builder: (context) {
                          return Markdown(data: message.content);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildChatPreview(BuildContext context, CustomColors customColors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Column(
        children: widget.messages.map((message) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Align(
              alignment: message.leftSide ? Alignment.topLeft : Alignment.topRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _chatBoxMaxWidth(context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (message.avatarURL != null && message.leftSide) _buildAvatar(avatarUrl: message.avatarURL),
                        if (message.username != null && message.leftSide)
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 7),
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Text(
                              message.username!,
                              style: TextStyle(
                                color: customColors.weakTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _chatBoxMaxWidth(context) - 30,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: message.leftSide ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          if (message.images != null && message.images!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 10, 7),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: _chatBoxImagePreviewWidth(context, (message.images ?? []).length)),
                                child: FileUploadPreview(images: message.images ?? []),
                              ),
                            ),
                          Container(
                            margin: message.leftSide
                                ? const EdgeInsets.fromLTRB(0, 0, 0, 7)
                                : const EdgeInsets.fromLTRB(0, 0, 10, 7),
                            decoration: BoxDecoration(
                              borderRadius: CustomSize.borderRadius,
                              color: message.leftSide
                                  ? customColors.chatRoomReplyBackground
                                  : customColors.chatRoomSenderBackground,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Builder(
                              builder: (context) {
                                return Markdown(data: message.content);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 获取聊天框的最大宽度
  double _chatBoxMaxWidth(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= CustomSize.maxWindowSize) {
      return CustomSize.maxWindowSize;
    }

    return screenWidth;
  }

  /// 获取图片预览的最大宽度
  double _chatBoxImagePreviewWidth(BuildContext context, int imageCount) {
    final expect = _chatBoxMaxWidth(context) / 1.3;
    final max = imageCount > 1 ? 500.0 : 300.0;
    return expect > max ? max : expect;
  }

  Widget _buildAvatar({String? avatarUrl, int? id, int size = 30}) {
    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return RemoteAvatar(
        avatarUrl: imageURL(avatarUrl, qiniuImageTypeAvatar),
        size: size,
      );
    }

    return RandomAvatar(
      id: id ?? 0,
      size: size,
      usage: Ability().isUserLogon() ? AvatarUsage.room : AvatarUsage.legacy,
    );
  }
}
