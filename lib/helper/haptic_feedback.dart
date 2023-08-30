import 'package:flutter/services.dart';

class HapticFeedbackHelper {
  static Future<void> lightImpact() async {
    return HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() async {
    return HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() async {
    return HapticFeedback.heavyImpact();
  }
}
