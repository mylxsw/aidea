import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/chat/markdown.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ThinkingCard extends StatelessWidget {
  final String content;
  final String title;
  final bool isExpanded;
  final Function(bool) onTap;
  final double timeConsumed;
  const ThinkingCard({
    super.key,
    required this.content,
    required this.title,
    this.isExpanded = false,
    required this.onTap,
    this.timeConsumed = 0,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onTap(!isExpanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeConsumed > 0
                      ? '$title (${AppLocale.timeConsume.getString(context)} ${timeConsumed.toStringAsFixed(1)}s)'
                      : title,
                  style: TextStyle(fontSize: 14, color: customColors.weakTextColorLess),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 16,
                    color: customColors.weakTextColorLess,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: isExpanded ? null : 0,
              padding: const EdgeInsets.only(top: 8),
              alignment: Alignment.topLeft,
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.topLeft,
                width: double.infinity,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 3,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: customColors.weakTextColorLess?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                      Expanded(
                        child: Markdown(
                          data: content,
                          onUrlTap: (value) {
                            launchUrlString(value);
                          },
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: customColors.weakTextColorLess,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
