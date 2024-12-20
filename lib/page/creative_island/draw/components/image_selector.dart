import 'dart:typed_data';

import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ImageSelector extends StatelessWidget {
  final String? title;
  final Widget? titleHelper;
  final Function({String? path, Uint8List? data}) onImageSelected;
  final String? selectedImagePath;
  final Uint8List? selectedImageData;
  final double? height;
  const ImageSelector({
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
          borderRadius: CustomSize.borderRadius,
          color: customColors.backgroundColor,
          child: InkWell(
            borderRadius: CustomSize.borderRadiusAll,
            onTap: () async {
              HapticFeedbackHelper.mediumImpact();
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null && result.files.isNotEmpty) {
                if (PlatformTool.isWeb()) {
                  onImageSelected(data: result.files.first.bytes!);
                } else {
                  onImageSelected(path: result.files.first.path!);
                }
              }
            },
            child: Container(
                decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
                child: ClipRRect(
                  borderRadius: CustomSize.borderRadius,
                  child: Stack(
                    children: [
                      Container(
                        decoration: (selectedImagePath != null && selectedImagePath!.isNotEmpty) ||
                                (selectedImageData != null && selectedImageData!.isNotEmpty)
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: (selectedImagePath != null
                                      ? resolveImageProvider(selectedImagePath!)
                                      : (selectedImageData != null ? MemoryImage(selectedImageData!) : null))!,
                                  fit: BoxFit.cover,
                                ),
                                color: customColors.backgroundContainerColor?.withAlpha(100),
                                borderRadius: CustomSize.borderRadius,
                              )
                            : null,
                        child: SizedBox(
                          width: double.infinity,
                          height: height ?? 200,
                        ),
                      ),
                      selectedImagePath == null || selectedImagePath!.isEmpty
                          ? SizedBox(
                              height: height ?? 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 30,
                                    color: customColors.chatInputPanelText,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppLocale.selectImage.getString(context),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: customColors.chatInputPanelText?.withOpacity(0.8),
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
                                color: const Color.fromARGB(80, 255, 255, 255),
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                      color: Color.fromARGB(147, 255, 255, 255),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppLocale.clickSwitchImage.getString(context),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(147, 255, 255, 255),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
