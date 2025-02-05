import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/group_list_widget.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

/// 带搜索框的列表选择器
class ItemSearchSelector extends StatefulWidget {
  final List<SelectorItem> items;
  final bool Function(SelectorItem item) onSelected;
  final bool enableSearch;
  final bool horizontal;
  final int horizontalCount;
  final Object? value;
  final EdgeInsets? innerPadding;

  const ItemSearchSelector({
    super.key,
    required this.items,
    required this.onSelected,
    this.enableSearch = true,
    this.horizontal = false,
    this.value,
    this.horizontalCount = 4,
    this.innerPadding,
  });

  @override
  State<ItemSearchSelector> createState() => _ItemSearchSelectorState();
}

class _ItemSearchSelectorState extends State<ItemSearchSelector> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final items = widget.items.where((item) {
      if (_searchController.text.isEmpty) return true;
      if (item.search != null) {
        return item.search!(_searchController.text.trim());
      }

      return false;
    }).toList();

    if (widget.horizontal) {
      return GridView.count(
        crossAxisCount: widget.horizontalCount,
        children: items
            .map(
              (item) => ListTile(
                title: Container(
                  alignment: Alignment.center,
                  padding: widget.innerPadding ?? const EdgeInsets.symmetric(vertical: 5),
                  child: widget.value != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 5),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 50,
                                maxHeight: 50,
                              ),
                              child: item.title,
                            ),
                            SizedBox(
                              height: 10,
                              child: Icon(
                                Icons.check,
                                color: (widget.value != null && widget.value == item.value)
                                    ? customColors.linkColor
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        )
                      : item.title,
                ),
                onTap: () {
                  if (widget.onSelected(item)) context.pop();
                },
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        // 搜索框
        if (widget.enableSearch)
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
            decoration: BoxDecoration(
              color: customColors.textfieldBackgroundColor,
              borderRadius: CustomSize.borderRadius,
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(color: customColors.textfieldHintColor),
              decoration: InputDecoration(
                hintText: AppLocale.search.getString(context),
                hintStyle: TextStyle(
                  color: customColors.weakTextColor?.withAlpha(150),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: customColors.weakTextColor?.withAlpha(150),
                ),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
        // 列表部分
        Expanded(
          child: GroupListWidget(
            items: items,
            groupKey: (item) => '',
            itemBuilder: (item) {
              return ListTile(
                title: Container(
                  alignment: Alignment.center,
                  padding: widget.innerPadding ??
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                  child: widget.value != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                                child: Container(
                              alignment: Alignment.center,
                              child: item.title,
                            )),
                            SizedBox(
                              width: 10,
                              child: Icon(
                                Icons.check,
                                color: (widget.value != null && widget.value == item.value)
                                    ? customColors.linkColor
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        )
                      : item.title,
                ),
                onTap: () {
                  if (widget.onSelected(item)) context.pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SelectorItem<T> {
  Widget title;
  T value;
  bool Function(String keywrod)? search;

  SelectorItem(this.title, this.value, {this.search});
}
