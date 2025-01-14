import 'package:askaide/helper/platform.dart';
import 'package:flutter/material.dart';

class CustomSize {
  static const double appBarTitleSize = 16;
  static const double defaultHintTextSize = 14;
  static const double maxWindowSize = 1000;
  static const double smallWindowSize = 500;

  static const double radiusValue = 8.0;

  static BorderRadiusGeometry borderRadius = BorderRadius.circular(radiusValue);
  static const Radius radius = Radius.circular(radiusValue);
  static const BorderRadius borderRadiusAll = BorderRadius.all(radius);

  static double get markdownTextSize {
    if (PlatformTool.isMacOS() || PlatformTool.isWindows()) {
      return 15;
    }

    return 16;
  }

  static double get markdownCodeSize {
    return 13;
  }

  static double get toolbarHeight {
    if (PlatformTool.isMacOS()) {
      return kToolbarHeight + 30;
    }

    return kToolbarHeight;
  }

  static double adaptiveMaxWindowWidth(BuildContext context) {
    final windowSize = MediaQuery.of(context).size.width;
    return windowSize > CustomSize.maxWindowSize ? CustomSize.maxWindowSize : windowSize;
  }
}
