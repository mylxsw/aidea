import 'package:flutter/material.dart';

class CustomSize {
  static const double appBarTitleSize = 16;
  static const double defaultHintTextSize = 16;
  static const double maxWindowSize = 1000;
  static const double smallWindowSize = 500;

  static const double radiusValue = 8.0;

  static BorderRadiusGeometry borderRadius = BorderRadius.circular(radiusValue);
  static const Radius radius = Radius.circular(radiusValue);
  static const BorderRadius borderRadiusAll = BorderRadius.all(radius);

  static double get markdownTextSize {
    return 16;
  }

  static double get markdownCodeSize {
    return 14;
  }

  static double get toolbarHeight {
    return kToolbarHeight;
  }

  static double adaptiveMaxWindowWidth(BuildContext context) {
    final windowSize = MediaQuery.of(context).size.width;
    return windowSize > CustomSize.maxWindowSize ? CustomSize.maxWindowSize : windowSize;
  }
}
