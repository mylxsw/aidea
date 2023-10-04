import 'package:askaide/page/component/image_preview.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:markdown/markdown.dart';

class Markdown extends StatelessWidget {
  final String data;
  final Function(String value)? onUrlTap;
  final TextStyle? textStyle;
  final cacheManager = DefaultCacheManager();

  Markdown({
    super.key,
    required this.data,
    this.onUrlTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return md.MarkdownBody(
      shrinkWrap: true,
      selectable: false,
      styleSheetTheme: md.MarkdownStyleSheetBaseTheme.material,
      styleSheet: md.MarkdownStyleSheet(
        p: textStyle ?? const TextStyle(fontSize: 16, height: 1.5),
        listBullet: textStyle ?? const TextStyle(fontSize: 16, height: 1.5),
        code: TextStyle(
          fontSize: 14,
          color: customColors.markdownCodeColor,
          backgroundColor: Colors.transparent,
        ),
        codeblockPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        codeblockDecoration: BoxDecoration(
          color: customColors.markdownPreColor,
          borderRadius: BorderRadius.circular(5),
        ),
        tableBorder: TableBorder.all(
          color: customColors.weakTextColor!.withOpacity(0.5),
          width: 1,
        ),
        tableColumnWidth: const FlexColumnWidth(),
        blockquotePadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: customColors.weakTextColor!.withOpacity(0.4),
              width: 4,
            ),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        if (onUrlTap != null && href != null) onUrlTap!(href);
      },
      imageBuilder: (uri, title, alt) {
        if (uri.scheme == 'http' || uri.scheme == 'https') {
          return NetworkImagePreviewer(
            url: uri.toString(),
            hidePreviewButton: true,
          );
        }

        return Image.network(uri.toString());
      },
      extensionSet: ExtensionSet.gitHubFlavored,
      data: data,
    );
  }
}
