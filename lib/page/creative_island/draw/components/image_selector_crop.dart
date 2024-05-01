import 'dart:typed_data';

import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../helper/image_picker_helper.dart';

class ImageSelectorCrop extends StatelessWidget {
  final String? title;
  final Widget? titleHelper;
  final Function({String? path, Uint8List? data}) onImageSelected;
  final String? selectedImagePath;
  final Uint8List? selectedImageData;
  final double? height;

  const ImageSelectorCrop({
    super.key,
    this.title,
    required this.onImageSelected,
    this.selectedImagePath,
    this.selectedImageData,
    this.height,
    this.titleHelper,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 16,
                      color: customColors.textfieldLabelColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (titleHelper != null) titleHelper!,
                ],
              ),
            ],
          ),
        if (title != null) const SizedBox(height: 10),
        Material(
          borderRadius: BorderRadius.circular(8),
          color: customColors.backgroundColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    //ImageSource.camera 照相机 或 ImageSource.gallery 相册
                    ImagePickerHelper(context)
                        .pickWithCropImage(ImageSource.gallery, (croppedFile) {
                      onImageSelected(path: croppedFile.path);
                      //获取到剪切的文件路径，进行相关的操作
                      debugPrint("croppedFile:${croppedFile.path}");
                    });
                    // HapticFeedbackHelper.mediumImpact();
                    // FilePickerResult? result =
                    //     await FilePicker.platform.pickFiles(type: FileType.image);
                    // if (result != null && result.files.isNotEmpty) {
                    //   if (PlatformTool.isWeb()) {
                    //     onImageSelected(data: result.files.first.bytes!);
                    //   } else {
                    //     onImageSelected(path: result.files.first.path!);
                    //   }
                    // }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: (selectedImagePath != null &&
                                              selectedImagePath!.isNotEmpty) ||
                                          (selectedImageData != null &&
                                              selectedImageData!.isNotEmpty)
                                      ? BoxDecoration(
                                          image: DecorationImage(
                                            image: (selectedImagePath != null
                                                ? resolveImageProvider(
                                                    selectedImagePath!)
                                                : (selectedImageData != null
                                                    ? MemoryImage(
                                                        selectedImageData!)
                                                    : null))!,
                                            fit: BoxFit.cover,
                                          ),
                                          color: customColors
                                              .backgroundContainerColor
                                              ?.withAlpha(100),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )
                                      : null,
                                  child: SizedBox(
                                    width: 160,
                                    height: height ?? 200,
                                  ),
                                ),
                                selectedImagePath == null ||
                                        selectedImagePath!.isEmpty
                                    ? SizedBox(
                                        width: 160,
                                        height: height ?? 200,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 30,
                                              color: customColors
                                                  .chatInputPanelText,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              AppLocale.selectImage
                                                  .getString(context),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: customColors
                                                    .chatInputPanelText
                                                    ?.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          color: const Color.fromARGB(
                                              80, 255, 255, 255),
                                          height: 50,
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                size: 30,
                                                color: Color.fromARGB(
                                                    147, 255, 255, 255),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                '点击此处更换图片',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      147, 255, 255, 255),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          ],
                        ),
                      )),
                ),
                Container(
                  width: 200,
                  height: height ?? 200,
                  child: Text("data"),
                  // height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),

                  ),
                ),
                Container(
                  height: height ?? 200,
                  child: Text("data"),
                  // height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),

                  ),
                ),
                Container(
                  height: height ?? 200,
                  child: Text("data"),
                  // height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),

                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
