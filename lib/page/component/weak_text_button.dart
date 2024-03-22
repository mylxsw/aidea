import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class WeakTextButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? fontSize;
  const WeakTextButton({
    super.key,
    required this.title,
    this.icon,
    this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final item = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(
            icon,
            color: customColors.weakLinkColor,
            size: (fontSize ?? 15.0) + 1,
          ),
        if (icon != null) const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            color: customColors.weakLinkColor,
            fontSize: fontSize ?? 15.0,
          ),
        ),
      ],
    );

    if (onPressed == null) {
      return item;
    }

    return TextButton(
      onPressed: onPressed,
      child: item,
    );
  }
}
