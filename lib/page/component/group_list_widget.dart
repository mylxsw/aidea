import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class Group<T> {
  final String key;
  final List<T> items;

  Group({required this.key, required this.items});
}

class GroupListWidget<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) groupKey;
  final Widget Function(T item) itemBuilder;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showTitle;
  final ScrollPhysics? physics;
  const GroupListWidget({
    super.key,
    required this.items,
    required this.groupKey,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.margin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.showTitle = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    var groups = <String, List<T>>{};
    for (var item in items) {
      var key = groupKey(item);
      groups[key] = groups[key] ?? [];
      groups[key]!.add(item);
    }

    return ListView.separated(
      physics: physics,
      shrinkWrap: true,
      itemBuilder: (context, i) {
        var group = groups.entries.elementAt(i);
        return Column(
          children: [
            if (showTitle)
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.only(left: 10, right: 10),
                width: double.infinity,
                child: Text(
                  groups.keys.elementAt(i),
                  style: TextStyle(
                    color: customColors.weakTextColor,
                    fontSize: 12,
                  ),
                ),
              ),
            Container(
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: CustomSize.borderRadius,
                color: customColors.backgroundForDialogListItem,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.value.length,
                itemBuilder: (BuildContext context, int index) {
                  return itemBuilder(group.value.elementAt(index));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                    child: Divider(
                      height: 1,
                      color: customColors.columnBlockDividerColor,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Padding(padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5));
      },
      itemCount: groups.length,
    );
  }
}
