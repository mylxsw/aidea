import 'dart:io';

import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends StatefulWidget {
  final String url;
  final double? aspectRatio;
  final int? width;
  final int? height;

  const VideoPlayer({super.key, required this.url, this.width, this.height, this.aspectRatio});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.setPlaylistMode(PlaylistMode.single);
    player.open(Media(widget.url));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: customColors.columnBlockBackgroundColor,
        borderRadius: CustomSize.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, topRight: CustomSize.radius),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: widget.width != null && widget.height != null
                    ? MediaQuery.of(context).size.width * widget.height! / widget.width!
                    : MediaQuery.of(context).size.width,
                child: Video(
                  controller: controller,
                  width: widget.width?.toDouble(),
                  height: widget.height?.toDouble(),
                  aspectRatio: widget.aspectRatio,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download,
                        size: 14,
                        color: customColors.weakLinkColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AppLocale.download.getString(context),
                        style: TextStyle(
                          fontSize: 12,
                          color: customColors.weakLinkColor,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    final cancel = BotToast.showCustomLoading(
                      toastBuilder: (cancel) {
                        return const LoadingIndicator(
                          message: 'Downloading, please wait...',
                        );
                      },
                      allowClick: false,
                      duration: const Duration(seconds: 120),
                    );

                    try {
                      final saveFile = await DefaultCacheManager().getSingleFile(widget.url);

                      if (PlatformTool.isIOS() || PlatformTool.isAndroid()) {
                        await ImageGallerySaver.saveFile(saveFile.path);

                        showSuccessMessage(AppLocale.operateSuccess.getString(context));
                      } else {
                        var ext = saveFile.path.toLowerCase().split('.').last;

                        if (PlatformTool.isWindows()) {
                          FileSaver.instance
                              .saveAs(
                            name: filenameWithoutExt(saveFile.path.split('/').last),
                            filePath: saveFile.path,
                            ext: '.$ext',
                            mimeType: MimeType.mpeg,
                          )
                              .then((value) async {
                            if (value == null) {
                              return;
                            }

                            await File(value).writeAsBytes(await saveFile.readAsBytes());

                            Logger.instance.d('File saved successfully: $value');
                            showSuccessMessage(AppLocale.operateSuccess.getString(context));
                          });
                        } else {
                          FileSaver.instance
                              .saveFile(
                            name: filenameWithoutExt(saveFile.path.split('/').last),
                            filePath: saveFile.path,
                            ext: ext,
                            mimeType: MimeType.mpeg,
                          )
                              .then((value) {
                            showSuccessMessage(AppLocale.operateSuccess.getString(context));
                          });
                        }
                      }
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      showErrorMessageEnhanced(context, 'Image save failed, please try again later');
                      Logger.instance.e('Download failed', error: e);
                    } finally {
                      cancel();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
