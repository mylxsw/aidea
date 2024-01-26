import 'dart:io';

import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_popup_menu.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/image_preview.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/share.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/creative_island/gallery/gallery_item.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class GalleryItemShareScreen extends StatefulWidget {
  final List<String> images;
  final String? prompt;
  final String? negativePrompt;

  const GalleryItemShareScreen({
    super.key,
    required this.images,
    this.prompt,
    this.negativePrompt,
  });

  @override
  State<GalleryItemShareScreen> createState() => _GalleryItemShareScreenState();
}

class _GalleryItemShareScreenState extends State<GalleryItemShareScreen> {
  final WidgetsToImageController controller = WidgetsToImageController();

  bool showQRCode = true;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
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
                    // ignore: use_build_context_synchronously
                    await shareTo(
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
                  Icon(Icons.share,
                      size: 14, color: customColors.weakLinkColor),
                  const SizedBox(width: 5),
                  Text(
                    '分享',
                    style: TextStyle(
                        color: customColors.weakLinkColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          EnhancedPopupMenu(
            items: [
              EnhancedPopupMenuItem(
                title: '保存到本地',
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

                        showSuccessMessage('图片保存成功');
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
                              return ;
                            }

                            await File(value).writeAsBytes(data);

                            Logger.instance.d('文件保存成功: $value');
                            showSuccessMessage('文件保存成功');
                          });
                        }  else {
                          FileSaver.instance
                              .saveFile(
                            name: randomId(),
                            bytes: data,
                            ext: 'png',
                            mimeType: MimeType.png,
                          )
                              .then((value) {
                            Logger.instance.d('文件保存成功: $value');
                            showSuccessMessage('文件保存成功');
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
                title: showQRCode ? '不显示邀请信息' : '显示邀请信息',
                icon: showQRCode ? Icons.visibility_off : Icons.visibility,
                onTap: (ctx) {
                  setState(() {
                    showQRCode = !showQRCode;
                  });
                },
              ),
            ],
          )
        ],
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CustomSize.smallWindowSize,
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
                      return Column(
                        children: [
                          WidgetsToImage(
                            controller: controller,
                            child: Container(
                              color: customColors.backgroundContainerColor,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  for (var img in widget.images)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: customColors.backgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: NetworkImagePreviewer(
                                        url: img,
                                        preview:
                                            imageURL(img, qiniuImageTypeThumb),
                                        hidePreviewButton: true,
                                        notClickable: true,
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                  ColumnBlock(
                                    innerPanding: 10,
                                    padding: const EdgeInsets.all(15),
                                    margin: const EdgeInsets.all(0),
                                    borderRadius: 0,
                                    children: [
                                      if (widget.prompt != null &&
                                          widget.prompt!.isNotEmpty)
                                        TextItem(
                                          title: 'Prompt',
                                          value: widget.prompt!,
                                        ),
                                      if (widget.negativePrompt != null &&
                                          widget.negativePrompt!.isNotEmpty)
                                        TextItem(
                                          title: 'Negative Prompt',
                                          value: widget.negativePrompt!,
                                        ),
                                    ],
                                  ),
                                  if (showQRCode)
                                    Container(
                                      color: customColors.backgroundColor,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(
                      child: Text('Loading ...'),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
