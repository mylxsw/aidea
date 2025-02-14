import 'package:askaide/helper/platform.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class BottomSheetBox extends StatelessWidget {
  final Widget child;
  const BottomSheetBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: PlatformTool.isDesktop() ? 10 : (MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 0)),
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: CustomSize.radius, bottom: CustomSize.radius),
              color: customColors.backgroundColor,
            ),
            padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
            child: SafeArea(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
