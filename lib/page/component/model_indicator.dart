import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class ModelIndicatorInfo {
  final IconData icon;
  final Color activeColor;
  final String modelId;
  final String modelName;
  final String description;

  ModelIndicatorInfo({
    required this.modelName,
    required this.modelId,
    required this.description,
    required this.icon,
    required this.activeColor,
  });
}

class ModelIndicator extends StatelessWidget {
  final ModelIndicatorInfo model;
  final bool selected;

  const ModelIndicator({
    super.key,
    required this.model,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(
            model.icon,
            color: selected ? Colors.white : customColors.weakLinkColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.modelName,
              style: TextStyle(
                fontSize: 16,
                color: selected ? Colors.white : customColors.weakLinkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              model.description,
              style: TextStyle(
                fontSize: 10,
                color: selected ? Colors.white : customColors.weakTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
