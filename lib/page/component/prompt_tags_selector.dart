import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/weak_text_button.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PromptTagsSelector extends StatefulWidget {
  final List<PromptTag> selectedTags;
  final Function(List<PromptTag> tags) onSubmit;
  const PromptTagsSelector({
    super.key,
    this.selectedTags = const [],
    required this.onSubmit,
  });

  @override
  State<PromptTagsSelector> createState() => _PromptTagsSelectorState();
}

class _PromptTagsSelectorState extends State<PromptTagsSelector> {
  List<PromptCategory> promptCategories = [];
  Map<String, PromptTag> selectedTags = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    for (var element in widget.selectedTags) {
      selectedTags[element.value] = element;
    }

    APIServer().drawPromptTags().then((res) {
      setState(() {
        promptCategories = res;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: customColors.backgroundColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: DefaultTabController(
                length: promptCategories.length,
                child: Column(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context)
                            .colorScheme
                            .copyWith(surfaceVariant: Colors.transparent),
                      ),
                      child: TabBar(
                        tabs: [
                          for (var cat in promptCategories) Tab(text: cat.name)
                        ],
                        isScrollable: true,
                        labelPadding: const EdgeInsets.only(left: 0, right: 20),
                        labelColor: customColors.linkColor,
                        unselectedLabelColor: customColors.weakLinkColor,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        indicator: const BoxDecoration(),
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          for (var cat in promptCategories)
                            buildTabBarView(customColors, cat.children),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.symmetric(vertical: 8),
          //   width: double.infinity,
          //   child: ConstrainedBox(
          //     constraints: const BoxConstraints(maxHeight: 95),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Text(
          //           '已选择（${selectedTags.length}）：',
          //           style: TextStyle(
          //             fontSize: 14,
          //             color: customColors.weakLinkColor,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         const SizedBox(height: 5),
          //         Expanded(
          //           child: SingleChildScrollView(
          //             controller: _scrollController,
          //             child: Wrap(
          //               spacing: 3,
          //               runSpacing: 3,
          //               children: [
          //                 for (var tag in selectedTags.values)
          //                   Tag(
          //                     name: tag.name,
          //                     backgroundColor: customColors.linkColor,
          //                     textColor: Colors.white,
          //                     fontsize: 10,
          //                     onDeleted: () {
          //                       setState(() {
          //                         selectedTags.remove(tag.value);
          //                       });
          //                     },
          //                   ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                WeakTextButton(
                  title: '取消',
                  onPressed: () {
                    context.pop();
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: EnhancedButton(
                    title: '确定',
                    fontSize: 14,
                    onPressed: () {
                      widget.onSubmit(selectedTags.values.toList());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabBarView(
      CustomColors customColors, List<PromptCategory> subCategories) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
      decoration: BoxDecoration(
        color: customColors.backgroundContainerColor?.withAlpha(50),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListView.builder(
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  '# ${subCategories[index].name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: customColors.weakTextColorPlusPlus?.withAlpha(150),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              buildTagView(customColors, subCategories[index].tags),
            ],
          );
        },
      ),
    );
  }

  Widget buildTagView(CustomColors customColors, List<PromptTag> tags) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var tag in tags)
          Tag(
            name: tag.name,
            onTap: () {
              if (selectedTags.containsKey(tag.value)) {
                selectedTags.remove(tag.value);
              } else {
                selectedTags[tag.value] = tag;
              }
              setState(() {});
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            textColor: selectedTags.containsKey(tag.value)
                ? Colors.white
                : customColors.weakTextColorPlusPlus,
            backgroundColor: selectedTags.containsKey(tag.value)
                ? customColors.linkColor
                : customColors.backgroundContainerColor?.withAlpha(200),
          ),
      ],
    );
  }
}

class Tag extends StatelessWidget {
  final String name;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;
  final double? fontsize;

  const Tag({
    super.key,
    required this.name,
    this.backgroundColor,
    this.textColor,
    this.onDeleted,
    this.onTap,
    this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        side: BorderSide.none,
        visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
        padding: const EdgeInsets.all(0),
        labelPadding:
            EdgeInsets.only(left: 5, right: onDeleted == null ? 5 : 0),
        elevation: 0,
        label: Text(
          name,
          style: TextStyle(
            fontSize: fontsize ?? 12,
            color: textColor ?? Colors.white,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.grey,
        deleteIcon: Icon(
          Icons.close,
          color: textColor ?? Colors.white,
          size: fontsize ?? 12,
        ),
        onDeleted: onDeleted,
      ),
    );
  }
}
