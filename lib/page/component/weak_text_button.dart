import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class WeakTextButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  const WeakTextButton({
    super.key,
    required this.title,
    this.icon,
    this.onPressed,
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
          ),
        if (icon != null) const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            color: customColors.weakLinkColor,
            fontSize: 15,
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
