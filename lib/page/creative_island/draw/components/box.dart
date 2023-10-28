import 'dart:ui';

import 'package:askaide/helper/color.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 创作岛列表项目
class CreativeIslandBox extends StatelessWidget {
  final CreativeIslandItem item;
  final Color? backgroundColor;
  const CreativeIslandBox(
      {super.key, required this.item, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Stack(
        children: [
          Container(
            // width: MediaQuery.of(context).size.width / 2 - 20,
            // height: 80,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              image: item.bgImage != null
                  ? DecorationImage(
                      image: CachedNetworkImageProviderEnhanced(item.bgImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  HapticFeedbackHelper.lightImpact();
                  context.push('/creative-island/${item.id}/create');
                },
                child: item.bgImage != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(60),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 1.0,
                                  sigmaY: 1.0,
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: item.titleColor != null
                                            ? stringToColor(item.titleColor!)
                                            : Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: const Color.fromARGB(
                                                    255, 161, 161, 161)
                                                .withOpacity(0.5),
                                            offset: const Offset(2, 2),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: item.titleColor != null
                                ? stringToColor(item.titleColor!)
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (item.label != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  color: item.labelColor != null
                      ? stringToColor(item.labelColor!)
                      : const Color.fromARGB(255, 230, 173, 58),
                ),
                child: Text(
                  item.label!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
