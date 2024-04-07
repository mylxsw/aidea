import 'package:askaide/helper/ability.dart';
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
        var model = widget.models.removeAt(index);
        widget.models.insert(0, model);
      }
    }

    return widget.models.isNotEmpty
        ? Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
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
                      return ListTile(
                        title: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.avatarUrl != null) ...[
                                _buildAvatar(
                                    avatarUrl: item.avatarUrl, size: 40),
                                const SizedBox(width: 20),
                              ],
                              Expanded(
                                child: Container(
                                  alignment: item.avatarUrl != null
                                      ? Alignment.centerLeft
                                      : Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.tag != null &&
                                          item.tag!.isNotEmpty &&
                                          item.avatarUrl != null)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: customColors
                                                .tagsBackgroundHover,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          margin:
                                              const EdgeInsets.only(left: 5),
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
                                    ],
                                  ),
                                ),
                              ),
                              if (item.avatarUrl != null) ...[
                                if (widget.enableClear)
                                  SizedBox(
                                    width: 60,
                                    child: widget.initValue == item.uid() ||
                                            widget.initValue == item.id
                                        ? WeakTextButton(
                                            title: '取消',
                                            fontSize: 14,
                                            onPressed: () {
                                              widget.onSelected(null);
                                            },
                                          )
                                        : const SizedBox(),
                                  )
                                else
                                  SizedBox(
                                    width: 10,
                                    child: Icon(
                                      Icons.check,
                                      color: widget.initValue == item.uid() ||
                                              widget.initValue == item.id
                                          ? customColors.linkColor
                                          : Colors.transparent,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        onTap: () {
                          widget.onSelected(item);
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1,
                        color: customColors.columnBlockDividerColor,
                      );
                    },
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
}
