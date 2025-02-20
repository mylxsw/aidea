import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:lottie/lottie.dart';

class EmptyPreview extends StatefulWidget {
  final List<ChatExample> examples;
  final Function(String message) onSubmit;
  final bool cardMode;

  const EmptyPreview({
    super.key,
    required this.examples,
    required this.onSubmit,
    this.cardMode = false,
  });

  @override
  State<EmptyPreview> createState() => _EmptyPreviewState();
}

class _EmptyPreviewState extends State<EmptyPreview> {
  final ScrollController _scrollController = ScrollController();

  final displayCount = 6;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.examples.isEmpty) {
      return Container();
    }

    final customColors = Theme.of(context).extension<CustomColors>()!;

    if (widget.cardMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: Lottie.asset('assets/lottie/empty_status.json', height: 150),
                  ),
                  // Text(
                  //   AppLocale.welcomeToAskMe.getString(context),
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: customColors.weakTextColor?.withOpacity(0.4),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Container(
            height: 60,
            alignment: Alignment.center,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: (widget.examples.length > displayCount ? displayCount : widget.examples.length) + 1,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == (widget.examples.length > displayCount ? displayCount : widget.examples.length)) {
                  return Container(
                    width: 60,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(left: 10, right: 15),
                    alignment: Alignment.center,
                    child: InkWell(
                      borderRadius: CustomSize.borderRadiusAll,
                      onTap: () {
                        setState(() {
                          widget.examples.shuffle();
                        });
                        _scrollController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Icon(Icons.refresh, color: customColors.chatInputPanelText),
                      ),
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(left: 10, right: 5),
                  child: InkWell(
                    borderRadius: CustomSize.borderRadiusAll,
                    onTap: () {
                      widget.onSubmit(widget.examples[index].text);
                    },
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: customColors.backgroundColor,
                        borderRadius: CustomSize.borderRadius,
                      ),
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        widget.examples[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: customColors.chatInputPanelText,
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  color: customColors.chatExampleItemText?.withAlpha(20),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          // 示例内容区域
          Container(
            decoration: BoxDecoration(
              // color: customColors.backgroundColor?.withAlpha(200),
              borderRadius: CustomSize.borderRadius,
            ),
            padding: const EdgeInsets.only(top: 20, left: 15, right: 10, bottom: 3),
            height: _resolveTipHeight(context),
            width: _resolveTipWidth(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/app-256-transparent.png', width: 20, height: 20),
                    const SizedBox(width: 5),
                    Text(
                      AppLocale.askMeLikeThis.getString(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.examples.length > displayCount ? displayCount : widget.examples.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTextItem(
                        title: widget.examples[index].title,
                        onTap: () {
                          widget.onSubmit(widget.examples[index].text);
                        },
                        customColors: customColors,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: customColors.chatExampleItemText?.withAlpha(20),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      setState(() {
                        widget.examples.shuffle();
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: customColors.chatExampleItemText,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          AppLocale.refresh.getString(context),
                          style: TextStyle(
                            color: customColors.chatExampleItemText,
                          ),
                          textScaler: const TextScaler.linear(0.9),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _resolveTipWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return screenWidth / 1.15;
    }

    return 348;
  }

  double _resolveTipHeight(BuildContext context) {
    final halfScreenHeight = MediaQuery.of(context).size.height / 2;
    if (halfScreenHeight > 260) {
      return 260;
    }

    return halfScreenHeight;
  }
}

class ListTextItem extends StatefulWidget {
  final String title;
  final Function() onTap;
  final CustomColors customColors;

  const ListTextItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.customColors,
  });

  @override
  State<ListTextItem> createState() => _ListTextItemState();
}

class _ListTextItemState extends State<ListTextItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_right,
              color: widget.customColors.chatExampleItemText?.withAlpha(120),
            ),
            Expanded(
              child: Text(
                widget.title,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.customColors.weakTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
