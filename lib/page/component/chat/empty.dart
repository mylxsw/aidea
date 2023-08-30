import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:flutter/material.dart';

class EmptyPreview extends StatefulWidget {
  final List<ChatExample> examples;
  final Function(String message) onSubmit;

  EmptyPreview({
    super.key,
    required this.examples,
    required this.onSubmit,
  }) {
    // 示例问题随机排序
    if (examples.isNotEmpty) {
      examples.shuffle();
    }
  }

  @override
  State<EmptyPreview> createState() => _EmptyPreviewState();
}

class _EmptyPreviewState extends State<EmptyPreview> {
  @override
  Widget build(BuildContext context) {
    if (widget.examples.isEmpty) {
      return Container();
    }

    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          // 示例内容区域
          Container(
            decoration: BoxDecoration(
              color: customColors.backgroundColor?.withAlpha(200),
              borderRadius: BorderRadius.circular(10),
            ),
            padding:
                const EdgeInsets.only(top: 20, left: 15, right: 10, bottom: 3),
            height: _resolveTipHeight(context),
            width: _resolveTipWidth(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/app-256-transparent.png',
                        width: 20, height: 20),
                    const SizedBox(width: 5),
                    const Text(
                      '可以这样问我：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount:
                        widget.examples.length > 4 ? 4 : widget.examples.length,
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
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
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
                          '换一换',
                          style: TextStyle(
                            color: customColors.chatExampleItemText,
                          ),
                          textScaleFactor: 0.9,
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

    return 400;
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
