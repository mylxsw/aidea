import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/weak_text_button.dart';
import 'package:askaide/repo/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ModelItem extends StatefulWidget {
  final List<Model> models;
  final Function(Model? selected) onSelected;
  final String? initValue;
  final bool enableClear;

  const ModelItem({
    super.key,
    required this.models,
    required this.onSelected,
    this.initValue,
    this.enableClear = false,
  });

  @override
  State<ModelItem> createState() => _ModelItemState();
}

class _ModelItemState extends State<ModelItem> {
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    if (widget.enableClear && widget.initValue != null) {
      // 将当前选中的模型放在第一位
      var index = widget.models.indexWhere(
          (e) => e.uid() == widget.initValue || e.id == widget.initValue);
      if (index != -1) {
        widget.models
            .insert(0, widget.models[index].copyWith(category: '正在使用'));
      }
    }

    return widget.models.isNotEmpty
        ? Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(color: customColors.dialogDefaultTextColor),
                  decoration: InputDecoration(
                    hintText: AppLocale.search.getString(context),
                    hintStyle: TextStyle(
                      color: customColors.dialogDefaultTextColor,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: customColors.dialogDefaultTextColor,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) =>
                      setState(() => keyword = value.toLowerCase()),
                ),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  final models = keyword.isEmpty
                      ? widget.models
                      : widget.models.where((e) {
                          var matchText = e.name +
                              (e.description ?? '') +
                              (e.shortName ?? '') +
                              (e.tag ?? '') +
                              (e.category);
                          if (e.supportVision) {
                            matchText += 'vision视觉看图';
                          }

                          return matchText.toLowerCase().contains(keyword);
                        }).toList();
                  return ListView.separated(
                    itemCount: models.length,
                    itemBuilder: (context, i) {
                      var item = models[i];

                      var tags = <Widget>[];
                      if (item.tag != null) {
                        item.tag!.split(",").forEach((tag) {
                          if (tag.isEmpty) return;

                          tags.add(buildTag(
                            customColors,
                            tag,
                            tagTextColor: item.tagTextColor,
                            tagBgColor: item.tagBgColor,
                          ));
                        });
                      }

                      if (item.supportVision) {
                        tags.add(buildTag(
                          customColors,
                          AppLocale.visionTag.getString(context),
                          tagTextColor: colorToString(Colors.white),
                          tagBgColor: colorToString(
                            customColors.linkColor ?? Colors.green,
                          ),
                        ));
                      }

                      if (item.isNew && widget.initValue != item.uid()) {
                        tags.add(buildTag(
                          customColors,
                          AppLocale.newTag.getString(context),
                          tagTextColor: colorToString(Colors.white),
                          tagBgColor: colorToString(Colors.red),
                        ));
                      }

                      List<Widget> separators = [];
                      if (i == 0 && models[i].category != '') {
                        separators
                            .add(buildCategory(customColors, item.category));
                      } else if (i > 0 &&
                          models[i].category != models[i - 1].category) {
                        separators.add(buildCategory(
                          customColors,
                          item.category == ''
                              ? AppLocale.others.getString(context)
                              : item.category,
                        ));
                      }

                      return Column(
                        children: [
                          if (separators.isNotEmpty) const SizedBox(height: 10),
                          ...separators,
                          ListTile(
                            title: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.avatarUrl != null) ...[
                                    _buildAvatar(
                                        avatarUrl: item.avatarUrl, size: 50),
                                    const SizedBox(width: 10),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment:
                                                    item.avatarUrl != null
                                                        ? Alignment.centerLeft
                                                        : Alignment.center,
                                                child: Text(
                                                  item.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                            ...tags,
                                            if (item.avatarUrl != null) ...[
                                              if (widget.enableClear && i == 0)
                                                SizedBox(
                                                  width: 50,
                                                  child: widget.initValue ==
                                                          item.uid()
                                                      ? WeakTextButton(
                                                          title: '取消',
                                                          fontSize: 10,
                                                          onPressed: () {
                                                            widget.onSelected(
                                                                null);
                                                          },
                                                        )
                                                      : const SizedBox(),
                                                )
                                              else if (widget.initValue ==
                                                  item.uid())
                                                SizedBox(
                                                  width: 20,
                                                  child: Icon(
                                                    Icons.check,
                                                    color:
                                                        customColors.linkColor,
                                                  ),
                                                ),
                                            ],
                                          ],
                                        ),
                                        if (item.description != null &&
                                            item.description != '')
                                          Text(
                                            item.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: customColors.weakTextColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              widget.onSelected(item);
                            },
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(
                          height: 1,
                          color: customColors.columnBlockDividerColor,
                        ),
                      );
                    },
                    padding: const EdgeInsets.only(bottom: 15),
                  );
                }),
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

  Widget buildCategory(CustomColors customColors, String category) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      child: Text(
        category,
        style: TextStyle(
          color: customColors.dialogDefaultTextColor,
          fontSize: 14,
        ),
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
      usage: Ability().isUserLogon() ? AvatarUsage.room : AvatarUsage.legacy,
    );
  }

  Widget buildTag(
    CustomColors customColors,
    String tag, {
    String? tagTextColor,
    String? tagBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: tagBgColor != null
            ? stringToColor(tagBgColor)
            : customColors.tagsBackgroundHover,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(left: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 8,
          color: tagTextColor != null
              ? stringToColor(tagTextColor)
              : customColors.tagsText,
        ),
      ),
    );
  }
}
