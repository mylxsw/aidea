import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/model.dart';
import 'package:flutter/material.dart';

class ModelItem extends StatelessWidget {
  final List<Model> models;
  final Function(Model selected) onSelected;
  final String? initValue;

  const ModelItem({
    super.key,
    required this.models,
    required this.onSelected,
    this.initValue,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    Map<String, List<Model>> modelGroups = {};
    for (var model in models) {
      if (modelGroups.containsKey(model.category)) {
        modelGroups[model.category]!.add(model);
      } else {
        modelGroups[model.category] = [model];
      }
    }

    return models.isNotEmpty
        ? ListView(
            children: [
              for (var group in modelGroups.entries)
                ExpansionTile(
                  title: Row(children: [
                    Text(
                      group.key.toUpperCase(),
                      style: TextStyle(
                        color: customColors.weakLinkColor,
                      ),
                    ),
                    if (group.value.where((e) => !e.disabled).isEmpty)
                      Text(
                        '（敬请期待）',
                        style: TextStyle(
                          color: customColors.weakTextColor,
                        ),
                        textScaleFactor: 0.7,
                      ),
                  ]),
                  iconColor: customColors.weakLinkColor,
                  childrenPadding: const EdgeInsets.only(bottom: 10),
                  initiallyExpanded: group.value
                      .where((e) => e.uid() == initValue || e.id == initValue)
                      .isNotEmpty,
                  children: [
                    for (var model in group.value)
                      _buildListTile(model, customColors, context),
                  ],
                ),
            ],
          )
        : const Center(
            child: Text(
              '没有可用模型\n请先登录或者配置 OpenAI 的 Keys',
              textAlign: TextAlign.center,
            ),
          );
  }

  ListTile _buildListTile(
    Model model,
    CustomColors customColors,
    BuildContext context,
  ) {
    return ListTile(
      title: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: initValue == model.uid() || initValue == model.id
                  ? customColors.linkColor
                  : (model.disabled
                      ? customColors.tagsBackground
                      : customColors.tagsBackgroundHover),
              boxShadow: [
                BoxShadow(
                  color: customColors.boxShadowColor!,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  // 模型 ID
                  model.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: initValue == model.uid() || initValue == model.id
                        ? Colors.white
                        : (model.disabled
                            ? customColors.weakTextColor!.withAlpha(150)
                            : customColors.chatExampleItemText),
                  ),
                ),
                // 模型描述
                if (model.description != null) const SizedBox(height: 5),
                if (model.description != null)
                  Text(
                    model.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: initValue == model.uid() ||
                                  initValue == model.id
                              ? Colors.white
                              : (model.disabled
                                  ? customColors.weakTextColor!.withAlpha(150)
                                  : customColors.chatExampleItemText),
                        ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
              ],
            ),
          ),
          if (model.disabled)
            _buildBadge(const Color.fromARGB(150, 122, 122, 122), '敬请期待'),
          if (!model.disabled && model.tag != null)
            _buildBadge(const Color.fromARGB(150, 122, 122, 122), model.tag!),
        ],
      ),
      onTap: () {
        if (model.disabled) {
          showImportantMessage(context, '该模型即将推出，敬请期待！');
          return;
        }
        onSelected(model);
      },
    );
  }

  Widget _buildBadge(Color color, String text) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          color: color,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
