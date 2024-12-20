import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class GroupEmptyBoard extends StatelessWidget {
  const GroupEmptyBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: customColors.backgroundColor?.withAlpha(200),
              borderRadius: CustomSize.borderRadius,
            ),
            padding: const EdgeInsets.only(top: 20, left: 15, right: 10, bottom: 3),
            width: _resolveTipWidth(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/app-256-transparent.png', width: 20, height: 20),
                    const SizedBox(width: 5),
                    const Text(
                      '小提示',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextLine(
                      customColors,
                      "点击 @ 按钮，快速指定应答成员",
                      Icons.touch_app,
                    ),
                    buildTextLine(
                      customColors,
                      '未选择成员时，系统将随机指派',
                      Icons.shuffle,
                    ),
                    buildTextLine(
                      customColors,
                      '系统会记住上次使用的成员',
                      Icons.memory,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextLine(CustomColors customColors, String text, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: customColors.chatExampleItemText?.withAlpha(120),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              style: TextStyle(
                color: customColors.weakTextColor,
                height: 1.5,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }

  double _resolveTipWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return screenWidth / 1.15;
    }

    return 400;
  }
}
