import 'package:askaide/helper/constant.dart';
import 'package:flutter/material.dart';

class AvatarStyle extends StatelessWidget {
  final Widget child;
  const AvatarStyle({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 2.0.0 版本开始，使用圆角头像
    if (clientVersion.startsWith('2.')) {
      return ClipOval(child: child);
    }

    return child;
  }
}
