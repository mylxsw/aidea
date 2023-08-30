import 'package:askaide/helper/platform.dart';
import 'package:flutter/material.dart';

class CustomSize {
  static const double appBarTitleSize = 16;
  static const double defaultHintTextSize = 14;
  static const double maxWindowSize = 800;
  static const double smallWindowSize = 500;

  static double get toolbarHeight {
    if (PlatformTool.isMacOS()) {
      return kToolbarHeight + 30;
    }

    return kToolbarHeight;
  }
}
