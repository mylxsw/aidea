import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class ColumnBlock extends StatelessWidget {
  final List<Widget> children;
  final double? innerPanding;
  final Color? backgroundColor;
  final BoxBorder? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final bool showDivider;

  const ColumnBlock({
    super.key,
    required this.children,
    this.innerPanding,
    this.backgroundColor,
    this.border,
    this.padding,
    this.margin,
    this.borderRadius,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Container();
    }

    final customColors = Theme.of(context).extension<CustomColors>()!;

    var items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1 && showDivider) {
        items.add(Container(
          padding: EdgeInsets.symmetric(vertical: innerPanding ?? 0),
          child: Divider(
            color: customColors.columnBlockDividerColor,
            height: 1,
          ),
        ));
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? customColors.columnBlockBackgroundColor,
        border: border,
        borderRadius:
            BorderRadius.circular(borderRadius ?? customColors.borderRadius!),
        boxShadow: [
          BoxShadow(
            color: customColors.boxShadowColor!,
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
          BoxShadow(
            color: customColors.boxShadowColor!,
            offset: const Offset(-3, 0),
            blurRadius: 5,
          ),
        ],
      ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      margin: margin ?? const EdgeInsets.only(bottom: 10, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }
}
