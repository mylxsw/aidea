import 'package:askaide/page/component/enhanced_button.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final ButtonSize size;

  final Color? backgroundColor;
  final Color? color;
  final Widget? icon;

  const Button({
    super.key,
    required this.title,
    required this.onPressed,
    this.size = const ButtonSize.small(),
    this.backgroundColor,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedButton(
      width: size.width,
      height: size.height,
      fontSize: size.fontSize,
      title: title,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      color: color,
      icon: icon,
    );
  }
}

class ButtonSize {
  final double width;
  final double height;
  final double fontSize;

  const ButtonSize({
    required this.width,
    required this.height,
    required this.fontSize,
  });

  const ButtonSize.full()
      : width = double.infinity,
        height = 42,
        fontSize = 16;

  const ButtonSize.small()
      : width = 80,
        height = 35,
        fontSize = 14;
}
