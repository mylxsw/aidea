import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:flutter/material.dart';

class EnhancedPopupMenuItem {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Function(BuildContext)? onTap;

  const EnhancedPopupMenuItem({
    required this.title,
    this.icon,
    this.iconColor,
    this.onTap,
  });
}

class EnhancedPopupMenu extends StatelessWidget {
  final List<EnhancedPopupMenuItem> items;
  final IconData? icon;
  final Color? color;
  final String? tooltip;
  const EnhancedPopupMenu({
    super.key,
    required this.items,
    this.icon,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(icon ?? Icons.more_horiz, color: color),
      tooltip: tooltip,
      splashRadius: 20,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: CustomSize.borderRadius),
      position: PopupMenuPosition.under,
      onSelected: (value) {
        if (value.onTap != null) {
          value.onTap!(context);
        }
      },
      itemBuilder: (context) {
        return [
          for (final item in items)
            PopupMenuItem(
              // onTap: () {
              //   item.onTap!(context);
              // },
              value: item,
              child: Row(
                children: [
                  if (item.icon != null) Icon(item.icon!, size: 15, color: item.iconColor),
                  if (item.icon != null) const SizedBox(width: 10),
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )
        ];
      },
    );
  }
}
