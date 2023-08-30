import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class EnhancedButton extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final Color? color;
  final double? height;
  final double? width;
  final double? fontSize;
  final Widget? icon;
  final Function() onPressed;

  const EnhancedButton({
    super.key,
    required this.title,
    this.backgroundColor,
    this.color,
    this.height,
    this.width,
    this.fontSize,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Material(
      color: backgroundColor ?? customColors.linkColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Container(
          height: height ?? 42,
          width: width ?? double.infinity,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) icon!,
              if (icon != null) const SizedBox(width: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: fontSize ?? 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
