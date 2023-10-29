import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class MultiItemSelector<T> extends StatefulWidget {
  final Widget Function(T item)? itemAvatarBuilder;
  final Widget Function(T item) itemBuilder;
  final List<T> items;
  final Function(List<T> selected)? onSubmit;
  final Function(List<T> selected)? onChanged;
  final List<T>? selectedItems;

  const MultiItemSelector({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.selectedItems,
    this.onSubmit,
    this.onChanged,
    this.itemAvatarBuilder,
  });

  @override
  State<MultiItemSelector<T>> createState() => _MultiItemSelectorState();
}

class _MultiItemSelectorState<T> extends State<MultiItemSelector<T>> {
  var selectedItems = <T>[];

  @override
  void initState() {
    selectedItems = widget.selectedItems ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          if (widget.onSubmit != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                EnhancedButton(
                  width: 100,
                  height: 40,
                  backgroundColor: customColors.weakTextColor,
                  title: AppLocale.cancel.getString(context),
                  onPressed: () {
                    context.pop();
                  },
                ),
                EnhancedButton(
                  width: 100,
                  height: 40,
                  title: AppLocale.ok.getString(context),
                  onPressed: () {
                    widget.onSubmit!(selectedItems);
                  },
                ),
              ],
            ),
          Expanded(
            child: ListView.separated(
              itemCount: widget.items.length,
              itemBuilder: (context, i) {
                var item = widget.items[i];
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  checkboxShape: const CircleBorder(),
                  activeColor: customColors.linkColor,
                  side: BorderSide(
                    color: customColors.weakTextColor!.withAlpha(100),
                  ),
                  title: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.itemAvatarBuilder != null)
                          widget.itemAvatarBuilder!(item),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: widget.itemBuilder(item),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onChanged: (selected) {
                    setState(() {
                      if (selectedItems.contains(item)) {
                        selectedItems.remove(item);
                      } else {
                        selectedItems.add(item);
                      }

                      if (widget.onChanged != null) {
                        widget.onChanged!(selectedItems);
                      }
                    });
                  },
                  value: selectedItems.contains(item),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1,
                  color: customColors.columnBlockDividerColor,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
