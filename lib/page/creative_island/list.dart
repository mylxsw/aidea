import 'package:askaide/page/creative_island/box.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// 创作岛列表
class CreativeIslandList extends StatelessWidget {
  final List<CreativeIslandItem> items;
  final Color? color;
  const CreativeIslandList({super.key, required this.items, this.color});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _calCrossAxisCount(),
      childAspectRatio: 1,
      children: items
          .map((e) => CreativeIslandBox(item: e, backgroundColor: color))
          .toList(),
    );
  }

  int _calCrossAxisCount() {
    if (SizerUtil.deviceType == DeviceType.tablet) {
      if (SizerUtil.orientation == Orientation.landscape) {
        return 4;
      }
      return 3;
    }

    if (SizerUtil.orientation == Orientation.landscape) {
      return 3;
    }
    return 2;
  }
}
