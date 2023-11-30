import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class ModelIndicatorInfo {
  IconData icon;
  Color activeColor;
  String modelId;
  String modelName;
  String description;
  bool supportVision;

  ModelIndicatorInfo({
    required this.modelName,
    required this.modelId,
    required this.description,
    required this.icon,
    required this.activeColor,
    this.supportVision = false,
  });
}

class ModelIndicator extends StatelessWidget {
  final ModelIndicatorInfo model;
  final bool selected;
  final bool showDescription;

  const ModelIndicator({
    super.key,
    required this.model,
    this.selected = false,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(
              model.icon,
              color: selected ? Colors.white : customColors.weakLinkColor,
              size: 20,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model.modelName,
                      style: TextStyle(
                        fontSize: 15,
                        color: selected
                            ? Colors.white
                            : customColors.weakLinkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showDescription)
                      Text(
                        model.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? Colors.white
                              : customColors.weakTextColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
