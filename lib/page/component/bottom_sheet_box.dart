import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class BottomSheetBox extends StatelessWidget {
  final Widget child;
  const BottomSheetBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
              bottom: Radius.circular(10),
            ),
            color: customColors.backgroundColor,
          ),
          padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
          child: child,
        ),
      ),
    );
  }
}
