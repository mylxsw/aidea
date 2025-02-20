import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/group_list_widget.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/model.dart';
import 'package:auto_size_text/auto_size_text.dart';
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

    var tags = <Widget>[];

    // Collect all unique tags from models
    var uniqueTags = <String>{};
    for (var model in widget.models) {
      if (model.tag != null) {
        uniqueTags.addAll(model.tag!.split(',').where((e) => e.isNotEmpty));
      }

      if (model.isRecommend) {
        uniqueTags.add(AppLocale.recommendTag.getString(context));
      }

      if (model.isNew) {
        uniqueTags.add(AppLocale.newTag.getString(context));
      }

      if (model.supportVision) {
        uniqueTags.add(AppLocale.visionTag.getString(context));
      }

      if (model.supportReasoning) {
        uniqueTags.add(AppLocale.reasoning.getString(context));
      }

      if (model.supportSearch) {
        uniqueTags.add(AppLocale.search.getString(context));
      }

      if (model.modelPrice.isFree) {
        uniqueTags.add(AppLocale.free.getString(context));
      }
    }

    // Create tag widgets
    tags = uniqueTags.map((tag) {
      return InkWell(
        onTap: () {
          setState(() {
            selectedTag = selectedTag == tag ? '' : tag;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: buildTag(
            customColors,
            tag,
            tagTextColor: selectedTag == tag ? customColors.linkColor : null,
          ),
        ),
      );
    }).toList();

    return widget.models.isNotEmpty
        ? Column(
            children: [
              // Search
              Container(
                margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                decoration: BoxDecoration(
                  color: customColors.textfieldBackgroundColor,
                  borderRadius: CustomSize.borderRadius,
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(color: customColors.dialogDefaultTextColor),
                  decoration: InputDecoration(
                    hintText: AppLocale.search.getString(context),
                    hintStyle: TextStyle(color: customColors.textfieldHintColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: customColors.weakTextColor?.withAlpha(150),
                    ),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => setState(() => keyword = value.toLowerCase()),
                ),
              ),

              // Tags
              if (tags.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: tags),
                  ),
                ),

              Expanded(
                child: Builder(builder: (context) {
                  final models = searchModels();
                  return Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: GroupListWidget(
                      items: models,
                      showTitle: true,
                      groupKey: (item) {
                        return item.category;
                      },
                      itemBuilder: (item) {
                        return buildItem(context, item, customColors);
                      },
                    ),
                  );
                }),
              ),
            ],
          )
        : const Center(
            child: Text(
              'No model available\nPlease login first!',
              textAlign: TextAlign.center,
            ),
          );
  }

  Widget buildItem(BuildContext context, Model item, CustomColors customColors) {
    final modelPrice = item.modelPrice;

    var tags = <Widget>[];
    if (modelPrice.isFree) {
      tags.add(buildTag(
        customColors,
        AppLocale.free.getString(context),
        tagTextColor: widget.initValue == item.uid() ? customColors.linkColor : null,
      ));
    }
    if (item.tag != null) {
      var tt = item.tag!.split(",").where((e) => e.isNotEmpty).toList();
      for (var i = 0; i < tt.length; i++) {
        tags.add(buildTag(
          customColors,
          tt[i],
          tagTextColor: widget.initValue == item.uid() ? customColors.linkColor : null,
        ));
      }
    }

    if (item.supportVision) {
      tags.add(buildTag(
        customColors,
        AppLocale.visionTag.getString(context),
        tagTextColor: widget.initValue == item.uid() ? customColors.linkColor : null,
      ));
    }

    if (item.supportReasoning) {
      tags.add(buildTag(
        customColors,
        AppLocale.reasoning.getString(context),
        tagTextColor: widget.initValue == item.uid() ? customColors.linkColor : null,
      ));
    }

    if (item.supportSearch) {
      tags.add(buildTag(
        customColors,
        AppLocale.search.getString(context),
        tagTextColor: widget.initValue == item.uid() ? customColors.linkColor : null,
      ));
    }

    if (item.isNew) {
      tags.add(buildTag(
        customColors,
        AppLocale.newTag.getString(context),
        tagTextColor: widget.initValue == item.uid() ? customColors.linkColor : null,
      ));
    }

    return ListTile(
      leading: Stack(
        children: [
          buildAvatar(avatarUrl: item.avatarUrl, size: 48),
          if (item.userNoPermission)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: CustomSize.borderRadiusAll,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      title: AutoSizeText(
        item.name,
        minFontSize: 10,
        maxFontSize: 15,
        maxLines: 1,
        style: TextStyle(
          color: widget.initValue == item.uid()
              ? customColors.linkColor
              : (item.userNoPermission ? customColors.weakTextColorLess : null),
          fontWeight: widget.initValue == item.uid() ? FontWeight.bold : null,
        ),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: formatTags(tags)),
            ),
          ),
          buildPriceBlock(customColors, item, modelPrice),
        ],
      ),
      onTap: () {
        if (item.userNoPermission) {
          showErrorMessage(AppLocale.modelNeedSignIn.getString(context));
          return;
        }

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
    );
  }

  String selectedTag = '';

  List<Model> searchModels() {
    var models = keyword.isEmpty
        ? widget.models
        : widget.models.where((e) {
            var matchText = e.name + (e.description ?? '') + (e.shortName ?? '') + (e.tag ?? '') + (e.category);
            if (e.supportVision) {
              matchText += 'vision视觉看图';
            }
            if (e.isNew) {
              matchText += 'new新';
            }

            if (e.isRecommend) {
              matchText += 'recommend推荐';
            }

            if (e.supportReasoning) {
              matchText += 'reasoning推理';
            }

            if (e.supportSearch) {
              matchText += 'search搜索';
            }

            if (e.modelPrice.isFree) {
              matchText += 'free免费';
            }

            return matchText.toLowerCase().contains(keyword);
          }).toList();

    if (selectedTag.isNotEmpty) {
      models = models.where((e) {
        var tags = [];
        if (e.tag != null) {
          tags = e.tag!.split(',').where((e) => e.isNotEmpty).toList();
        }

        if (e.isRecommend) {
          tags.add(AppLocale.recommendTag.getString(context));
        }

        if (e.isNew) {
          tags.add(AppLocale.newTag.getString(context));
        }

        if (e.supportVision) {
          tags.add(AppLocale.visionTag.getString(context));
        }

        if (e.supportReasoning) {
          tags.add(AppLocale.reasoning.getString(context));
        }

        if (e.supportSearch) {
          tags.add(AppLocale.search.getString(context));
        }

        if (e.modelPrice.isFree) {
          tags.add(AppLocale.free.getString(context));
        }

        if (e.id.startsWith('v2@rooms')) {
          tags.add(AppLocale.character.getString(context));
        } else {
          tags.add(AppLocale.model.getString(context));
        }

        return tags.contains(selectedTag);
      }).toList();
    }

    return models;
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
      priceText += '${priceText == '' ? '' : ', '}${AppLocale.perRequest.getString(context)} ￠${item.request}';
    }

    if (item.search > 0) {
      priceText += '${priceText == '' ? '' : ', '}${AppLocale.perSearch.getString(context)} ￠${item.search}';
    }

    return Row(
      children: [
        Text(
          priceText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
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

  Widget buildAvatar({String? avatarUrl, int? id, int size = 30}) {
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
    double? tagFontSize,
    Color? tagTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.only(right: 5),
      child: Text(
        "#$tag",
        style: TextStyle(
          fontSize: tagFontSize ?? 11,
          color: tagTextColor ?? customColors.weakTextColor?.withAlpha(150),
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
  }

  return widgets;
}
