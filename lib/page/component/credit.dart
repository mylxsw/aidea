import 'package:askaide/lang/lang.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class Credit extends StatelessWidget {
  final int count;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool withAddPrefix;
  const Credit({
    super.key,
    required this.count,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.withAddPrefix = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: '${withAddPrefix ? "+ " : ""}${formatCount()}',
          style: TextStyle(
            fontSize: fontSize ?? 20,
            color: color ?? Colors.white,
            fontWeight: fontWeight ?? FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextSpan(
          text: '${AppLocale.creditUnit.getString(context)}${count >= maxShowCount ? " +" : ""}',
          style: TextStyle(
            fontSize: fontSize != null ? (fontSize! - 7) : 12,
            color: color ?? Colors.white.withAlpha(200),
            fontWeight: fontWeight ?? FontWeight.bold,
          ),
        ),
      ],
    ));
  }

  final maxShowCount = 1000000;

  String formatCount() {
    if (count >= maxShowCount) {
      return '${(count / maxShowCount).toStringAsFixed(0)} 百万';
    }
    return '$count';
  }
}
