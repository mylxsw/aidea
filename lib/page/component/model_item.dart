import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/page/component/random_avatar.dart';
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
    return models.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ListView.separated(
              itemCount: models.length,
              itemBuilder: (context, i) {
                var item = models[i];
                return ListTile(
                  title: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAvatar(avatarUrl: item.avatarUrl, size: 40),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Row(children: [
                              Text(
                                item.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.tag != null && item.tag!.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: customColors.tagsBackgroundHover,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.only(left: 5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    item.tag!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: customColors.tagsText,
                                    ),
                                  ),
                                ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                          child: Icon(
                            Icons.check,
                            color:
                                initValue == item.uid() || initValue == item.id
                                    ? customColors.linkColor
                                    : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    onSelected(item);
                  },
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
        : const Center(
            child: Text(
              '没有可用模型\n请先登录或者配置 OpenAI 的 Keys',
              textAlign: TextAlign.center,
            ),
          );
  }

  Widget _buildAvatar({String? avatarUrl, int? id, int size = 30}) {
    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return RemoteAvatar(
        avatarUrl: imageURL(avatarUrl, qiniuImageTypeAvatar),
        size: size,
      );
    }

    return RandomAvatar(
      id: id ?? 0,
      size: size,
      usage:
          Ability().enableAPIServer() ? AvatarUsage.room : AvatarUsage.legacy,
    );
  }
}
