import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:quickalert/models/quickalert_type.dart';

class ModelItem extends StatefulWidget {
  final List<Model> models;
  final Function(Model? selected) onSelected;
  final String? initValue;
  final bool showUsing;

  const ModelItem({
    super.key,
    required this.models,
    required this.onSelected,
    this.initValue,
    this.showUsing = false,
  });

  @override
  State<ModelItem> createState() => _ModelItemState();
}

class _ModelItemState extends State<ModelItem> {
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
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
                  onChanged: (value) => setState(() => keyword = value.toLowerCase()),
                ),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  final models = keyword.isEmpty
                      ? widget.models
                      : widget.models.where((e) {
                          var matchText =
                              e.name + (e.description ?? '') + (e.shortName ?? '') + (e.tag ?? '') + (e.category);
                          if (e.supportVision) {
                            matchText += 'vision视觉看图';
                          }

                          return matchText.toLowerCase().contains(keyword);
                        }).toList();
                  return ListView.separated(
                    itemCount: models.length,
                    itemBuilder: (context, i) {
                      var item = models[i];
                      final modelPrice = item.modelPrice;

                      var tags = <Widget>[];
                      if (modelPrice.isFree) {
                        tags.add(buildTag(
                          customColors,
                          AppLocale.free.getString(context),
                          tagTextColor: 'FFFFFFFF',
                          tagBgColor: '2196F3',
                        ));
                      }
                      if (item.tag != null) {
                        var tt = item.tag!.split(",").where((e) => e.isNotEmpty).toList();
                        for (var i = 0; i < tt.length; i++) {
                          tags.add(buildTag(
                            customColors,
                            tt[i],
                            tagTextColor: i == 0 ? item.tagTextColor : 'FFFFFFFF',
                            tagBgColor: i == 0 ? item.tagBgColor : modelTagColorSeq(i),
                          ));
                        }
                      }

                      if (item.supportVision) {
                        tags.add(buildTag(
                          customColors,
                          AppLocale.visionTag.getString(context),
                          tagTextColor: 'FFFFFFFF',
                          tagBgColor: '4CAF50',
                        ));
                      }

                      if (item.isNew) {
                        tags.add(buildTag(
                          customColors,
                          AppLocale.newTag.getString(context),
                          tagTextColor: 'FFFFFFFF',
                          tagBgColor: 'F44336',
                        ));
                      }

                      List<Widget> separators = [];
                      if (i == 0 && models[i].category != '') {
                        separators.add(buildCategory(customColors, item.category));
                      } else if (i > 0 && models[i].category != models[i - 1].category) {
                        separators.add(buildCategory(
                          customColors,
                          item.category == '' ? AppLocale.others.getString(context) : item.category,
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
                              decoration: BoxDecoration(
                                color: widget.initValue == item.uid() ? customColors.dialogBackgroundColor : null,
                                borderRadius: CustomSize.borderRadius,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.avatarUrl != null) ...[
                                    _buildAvatar(avatarUrl: item.avatarUrl, size: 50),
                                    const SizedBox(width: 10),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment:
                                                    item.avatarUrl != null ? Alignment.centerLeft : Alignment.center,
                                                child: Text(
                                                  item.name,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        widget.initValue == item.uid() ? customColors.linkColor : null,
                                                    fontWeight: widget.initValue == item.uid() ? FontWeight.bold : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (tags.length <= 3) ...formatTags(tags),
                                          ],
                                        ),
                                        if (tags.length > 3)
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(vertical: 5),
                                              child: Row(children: formatTags(tags)),
                                            ),
                                          ),
                                        if (!modelPrice.isFree) buildPriceBlock(customColors, item, modelPrice),

                                        // if (item.description != null && item.description != '')
                                        //   Text(
                                        //     item.description!,
                                        //     maxLines: 2,
                                        //     overflow: TextOverflow.ellipsis,
                                        //     style: TextStyle(
                                        //       fontSize: 12,
                                        //       color: widget.initValue == item.uid()
                                        //           ? customColors.linkColor
                                        //           : customColors.weakTextColor,
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              widget.onSelected(item);
                            },
                            onLongPress: () {
                              if (item.description == null || item.description == '') {
                                return;
                              }

                              showBeautyDialog(
                                context,
                                type: QuickAlertType.info,
                                text: item.description,
                                confirmBtnText: AppLocale.gotIt.getString(context),
                                showCancelBtn: false,
                              );
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

  Widget buildPriceBlock(CustomColors customColors, Model model, ModelPrice item) {
    if (item.isFree) {
      return const SizedBox();
    }

    var priceText = '';
    if (item.input > 0 || item.output > 0) {
      priceText +=
          '${AppLocale.input.getString(context)} ￠${item.input}, ${AppLocale.output.getString(context)} ￠${item.output}';
    }

    if (item.request > 0) {
      priceText += ', ${AppLocale.perRequest.getString(context)} ￠${item.request}';
    }

    return Row(
      children: [
        Text(
          priceText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color:
                widget.initValue == model.uid() ? customColors.linkColor : customColors.weakTextColor?.withAlpha(150),
          ),
        ),
        if (item.hasNote) ...[
          const SizedBox(width: 5),
          InkWell(
            onTap: () {
              showBeautyDialog(
                context,
                type: QuickAlertType.info,
                text: item.note,
                confirmBtnText: AppLocale.gotIt.getString(context),
                showCancelBtn: false,
              );
            },
            child: Icon(
              Icons.help_outline,
              size: 12,
              color: customColors.weakLinkColor?.withAlpha(50),
            ),
          ),
        ],
      ],
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
            ? stringToColor(tagBgColor, defaultColor: customColors.tagsBackgroundHover ?? Colors.grey)
            : customColors.tagsBackgroundHover,
        borderRadius: CustomSize.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 8,
          color: tagTextColor != null
              ? stringToColor(tagTextColor, defaultColor: customColors.tagsText ?? Colors.white)
              : customColors.tagsText,
        ),
      ),
    );
  }
}

String modelTagColorSeq(int index) {
  var colors = <Color>{
    Colors.grey,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.deepPurple,
    Colors.indigo,
    Colors.cyan,
  };
  return colorToString(colors.elementAt(index % colors.length));
}

List<Widget> formatTags(List<Widget> tags) {
  var widgets = <Widget>[];

  for (var i = 0; i < tags.length; i++) {
    widgets.add(tags[i]);
    if (i < tags.length - 1) {
      widgets.add(const SizedBox(width: 5));
    }
  }

  return widgets;
}
