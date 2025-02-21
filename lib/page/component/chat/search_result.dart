import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/chat/chat_preview.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SearchResult extends StatelessWidget {
  final List<ReferenceDocument> searchResults;
  const SearchResult({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          openModalBottomSheet(
            context,
            (context) {
              return ItemSearchSelector(
                innerPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                items: searchResults
                    .map(
                      (e) => SelectorItem<String>(
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Icon
                                    if (e.icon.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: CustomSize.borderRadius,
                                        child: CachedNetworkImageEnhanced(
                                          imageUrl: e.icon,
                                          fit: BoxFit.fill,
                                          width: 15,
                                          height: 15,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 15),
                                    const SizedBox(width: 10),
                                    // 媒体名称
                                    Text(
                                      e.media,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: customColors.weakTextColorLess,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                // 索引
                                Container(
                                  decoration: BoxDecoration(
                                    color: customColors.weakTextColorLess,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    e.index,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.title,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: customColors.weakTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.content,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: customColors.weakTextColorLess,
                              ),
                              textScaler: const TextScaler.linear(0.8),
                            ),
                          ],
                        ),
                        e.source,
                        search: (keyword) =>
                            e.title.toLowerCase().contains(keyword.toLowerCase()) ||
                            e.content.contains(keyword.toLowerCase()),
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  launchUrlString(value.value);
                  return false;
                },
              );
            },
            heightFactor: 0.9,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocale.searchedXWebPages.getString(context).replaceAll('%s', searchResults.length.toString()),
              style: TextStyle(fontSize: 14, color: customColors.weakTextColorLess),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              size: 16,
              color: customColors.weakTextColorLess,
            ),
          ],
        ),
      ),
    );
  }
}
