import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/button.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

Future<dynamic> openImageWorkflowActionDialog(
  BuildContext context,
  CustomColors customColors,
  String imageUrl,
) {
  return openModalBottomSheet(
    context,
    (context) {
      return Column(
        children: [
          Text(
            AppLocale.selectShortcutAction.getString(context),
            style: TextStyle(
              color: customColors.weakTextColorPlus,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: APIServer().creativeIslandItemsV2(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, CreativeIslandItemV2> itemsMap = {};
                  for (var item in snapshot.data!) {
                    itemsMap[item.id] = item;
                  }

                  return actionsBuilder(itemsMap, customColors, context, imageUrl);
                }

                return const LoadingIndicator(
                  message: 'Loading, please wait...',
                );
              },
            ),
          ),
        ],
      );
    },
    heightFactor: 0.5,
  );
}

Widget actionsBuilder(
  Map<String, CreativeIslandItemV2> itemsMap,
  CustomColors customColors,
  BuildContext context,
  String imageUrl,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const SizedBox(height: 20),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (itemsMap.containsKey('image-to-image'))
              Button(
                title: AppLocale.imageToImage.getString(context),
                icon: Icon(
                  Icons.collections_outlined,
                  size: 16,
                  color: customColors.weakLinkColor,
                ),
                onPressed: () {
                  context.pop();

                  context.push(Uri(
                    path: '/creative-draw/create',
                    queryParameters: {
                      'id': 'image-to-image',
                      'mode': 'image-to-image',
                      'note': itemsMap['image-to-image']!.note,
                      'init_image': imageUrl,
                    },
                  ).toString());
                },
                size: const ButtonSize.full(),
                color: customColors.weakLinkColor,
                backgroundColor: const Color.fromARGB(34, 183, 183, 183),
              ),
            if (itemsMap.containsKey('image-to-image')) const SizedBox(height: 10),
            if (itemsMap.containsKey('image-to-video'))
              Button(
                title: AppLocale.imageToVideo.getString(context),
                icon: Icon(
                  Icons.video_camera_back_outlined,
                  size: 16,
                  color: customColors.weakLinkColor,
                ),
                onPressed: () {
                  context.pop();

                  context.push(Uri(
                    path: '/creative-draw/create-video',
                    queryParameters: {
                      'note': itemsMap['image-to-video']!.note,
                      'init_image': imageUrl,
                    },
                  ).toString());
                },
                size: const ButtonSize.full(),
                color: customColors.weakLinkColor,
                backgroundColor: const Color.fromARGB(34, 183, 183, 183),
              ),
            if (itemsMap.containsKey('image-to-video')) const SizedBox(height: 10),
            if (itemsMap.containsKey('image-upscale'))
              Button(
                title: AppLocale.hdRestoration.getString(context),
                icon: Icon(
                  Icons.hd_outlined,
                  size: 16,
                  color: customColors.weakLinkColor,
                ),
                onPressed: () {
                  context.pop();

                  context.push(Uri(
                    path: '/creative-draw/create-upscale',
                    queryParameters: {
                      'note': itemsMap['image-upscale']!.note,
                      'init_image': imageUrl,
                    },
                  ).toString());
                },
                size: const ButtonSize.full(),
                color: customColors.weakLinkColor,
                backgroundColor: const Color.fromARGB(34, 183, 183, 183),
              ),
            if (itemsMap.containsKey('image-upscale')) const SizedBox(height: 10),
            if (itemsMap.containsKey('image-colorize'))
              Button(
                title: AppLocale.colorizeImage.getString(context),
                icon: Icon(
                  Icons.palette_outlined,
                  size: 16,
                  color: customColors.weakLinkColor,
                ),
                onPressed: () {
                  context.pop();
                  context.push(Uri(
                    path: '/creative-draw/create-colorize',
                    queryParameters: {
                      'note': itemsMap['image-colorize']!.note,
                      'init_image': imageUrl,
                    },
                  ).toString());
                },
                size: const ButtonSize.full(),
                color: customColors.weakLinkColor,
                backgroundColor: const Color.fromARGB(34, 183, 183, 183),
              ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Button(
          title: AppLocale.cancel.getString(context),
          backgroundColor: const Color.fromARGB(36, 222, 222, 222),
          color: customColors.dialogDefaultTextColor?.withAlpha(150),
          onPressed: () {
            context.pop();
          },
          size: const ButtonSize.full(),
        ),
      ),
    ],
  );
}
