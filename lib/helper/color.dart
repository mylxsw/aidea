import 'package:flutter/material.dart';

/// 将颜色转换为字符串
String colorToString(Color color, {String defaultColor = 'FF000000'}) {
  try {
    return color.toString().split('(0x')[1].split(')')[0];
  } catch (e) {
    return defaultColor;
  }
}

/// 将字符串转换为颜色
Color stringToColor(String colorString, {Color defaultColor = Colors.black}) {
  try {
    if (colorString.length == 6) {
      colorString = 'FF$colorString';
    }

    return Color(int.parse(colorString, radix: 16));
  } catch (e) {
    return defaultColor;
  }
}
