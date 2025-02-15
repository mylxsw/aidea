import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class ImageSize extends StatelessWidget {
  final String aspectRatio;
  const ImageSize({super.key, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    final widthFactor = int.parse(aspectRatio.split(':')[0]);
    final heightFactor = int.parse(aspectRatio.split(':')[1]);

    var width = 0.0;
    var height = 0.0;

    if (widthFactor > heightFactor) {
      width = 40;
      height = 40 / widthFactor * heightFactor;
    } else {
      height = 40;
      width = 40 / heightFactor * widthFactor;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: CustomSize.borderRadius,
        color: customColors.backgroundContainerColor,
      ),
      alignment: Alignment.center,
      child: Text(
        aspectRatio,
        style: const TextStyle(fontSize: 12, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
