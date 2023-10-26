import 'dart:io';

import 'package:askaide/helper/platform.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareTo(
  BuildContext context, {
  required String content,
  String? title,
  List<String>? images,
}) async {
  Rect? sharePositionOrigin;

  try {
    final box = context.findRenderObject() as RenderBox?;
    Rect? pos = box!.localToGlobal(Offset.zero) & box.size;
    sharePositionOrigin = pos;
    // ignore: empty_catches
  } catch (ignored) {}

  if ((PlatformTool.isIOS() || PlatformTool.isAndroid()) &&
      await isWeChatInstalled) {
    // ignore: use_build_context_synchronously
    openModalBottomSheet(
      context,
      (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  final model = images == null || images.isEmpty
                      ? WeChatShareTextModel(
                          content,
                          title: title,
                          scene: WeChatScene.TIMELINE,
                        )
                      : WeChatShareImageModel(
                          images.first.startsWith('http')
                              ? WeChatImage.network(images.first)
                              : WeChatImage.file(File(images.first)),
                          title: title,
                          description: content,
                          scene: WeChatScene.TIMELINE,
                        );

                  shareToWeChat(model).whenComplete(() => context.pop());
                },
                icon: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/friendroom.png', width: 40),
                    const SizedBox(height: 10),
                    const Text(
                      '分享到朋友圈',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  final model = images == null || images.isEmpty
                      ? WeChatShareTextModel(
                          content,
                          title: title,
                        )
                      : WeChatShareImageModel(
                          images.first.startsWith('http')
                              ? WeChatImage.network(images.first)
                              : WeChatImage.file(File(images.first)),
                          title: title,
                          description: content,
                        );

                  shareToWeChat(model).whenComplete(() => context.pop());
                },
                icon: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/wechat.png', width: 40),
                    const SizedBox(height: 10),
                    const Text(
                      '分享到微信',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (images != null && images.isNotEmpty) {
                    Share.shareXFiles(
                      [XFile(images.first)],
                      subject: title,
                      sharePositionOrigin: sharePositionOrigin,
                    ).whenComplete(() => context.pop());
                  } else {
                    Share.share(
                      content,
                      subject: title,
                      sharePositionOrigin: sharePositionOrigin,
                    ).whenComplete(() => context.pop());
                  }
                },
                icon: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/share.png', width: 40),
                    const SizedBox(height: 10),
                    const Text(
                      '分享到其它应用',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      heightFactor: 0.25,
    );
  } else {
    if (images != null && images.isNotEmpty) {
      Share.shareXFiles(
        [XFile(images.first)],
        subject: title,
        sharePositionOrigin: sharePositionOrigin,
      );
    } else {
      Share.share(
        content,
        subject: title,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }
}
