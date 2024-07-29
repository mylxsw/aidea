import 'package:flutter/material.dart';

/// 将颜色转换为字符串
String colorToString(Color color) {
  try {
    return color.toString().split('(0x')[1].split(')')[0];
  } catch (e) {
    return '000000';
  }
}

/// 将字符串转换为颜色
Color stringToColor(String colorString) {
  try {
    return Color(int.parse(colorString, radix: 16));
  } catch (e) {
    return Colors.black;
  }
}
