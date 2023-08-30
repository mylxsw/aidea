import 'package:flutter/material.dart';

/// 将颜色转换为字符串
String colorToString(Color color) {
  return color.toString().split('(0x')[1].split(')')[0];
}

/// 将字符串转换为颜色
Color stringToColor(String colorString) {
  return Color(int.parse(colorString, radix: 16));
}
