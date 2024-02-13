import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/model.dart';
import 'package:flutter/material.dart';

class IconAndColor {
  final IconData icon;
  final Color color;

  IconAndColor(this.icon, this.color);
}

final iconAndColors = [
  IconAndColor(Icons.bolt, Colors.green),
  IconAndColor(Icons.auto_awesome, const Color.fromARGB(255, 120, 73, 223)),
  IconAndColor(Icons.extension, const Color.fromARGB(255, 255, 122, 13)),
];

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
  final HomeModelV2 model;
  final IconAndColor iconAndColor;
  final bool selected;
  final int itemCount;

  const ModelIndicator({
    super.key,
    required this.model,
    required this.iconAndColor,
    this.selected = false,
    this.itemCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: itemCount > 2 ? 10 : 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconAndColor.icon,
            color: selected ? Colors.white : customColors.weakLinkColor,
            size: itemCount > 2 ? 16 : 20,
          ),
          SizedBox(width: itemCount > 2 ? 5 : 10),
          Expanded(
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        model.name,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: itemCount > 2 ? 14 : 15,
                          color: selected
                              ? Colors.white
                              : customColors.weakLinkColor,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: itemCount > 2 ? 16 : 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
