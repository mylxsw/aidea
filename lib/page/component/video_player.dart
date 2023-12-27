import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends StatefulWidget {
  final String url;
  const VideoPlayer({super.key, required this.url});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                child: Video(controller: controller),
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
                        '下载',
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
                          message: '下载中，请稍候...',
                        );
                      },
                      allowClick: false,
                      duration: const Duration(seconds: 120),
                    );

                    try {
                      final saveFile =
                          await DefaultCacheManager().getSingleFile(widget.url);

                      if (PlatformTool.isIOS() || PlatformTool.isAndroid()) {
                        await ImageGallerySaver.saveFile(saveFile.path);

                        showSuccessMessage('保存成功');
                      } else {
                        var ext = saveFile.path.toLowerCase().split('.').last;

                        FileSaver.instance
                            .saveFile(
                          name:
                              filenameWithoutExt(saveFile.path.split('/').last),
                          filePath: saveFile.path,
                          ext: ext,
                          mimeType: MimeType.mpeg,
                        )
                            .then((value) {
                          showSuccessMessage('文件保存成功');
                        });
                      }
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      showErrorMessageEnhanced(context, '保存失败，请稍后再试');
                      Logger.instance.e('下载失败', error: e);
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
