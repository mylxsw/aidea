import 'dart:convert';

import 'package:askaide/helper/platform.dart';
import 'package:askaide/page/component/chat/markdown/latex.dart';
import 'package:askaide/page/component/image_preview.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:markdown/markdown.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';

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
    if (!PlatformTool.isWeb()) {
      return MarkdownPlus(
        data: data,
        onUrlTap: onUrlTap,
        textStyle: textStyle,
        compact: true,
      );
    }

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

        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(uri.toString()),
        );
      },
      extensionSet: ExtensionSet.gitHubFlavored,
      data: data,
    );
  }
}

class MarkdownPlus extends StatelessWidget {
  final String data;
  final Function(String value)? onUrlTap;
  final bool compact;
  final TextStyle? textStyle;
  final cacheManager = DefaultCacheManager();

  MarkdownPlus({
    super.key,
    required this.data,
    this.onUrlTap,
    this.compact = true,
    this.textStyle,
  });

  MarkdownConfig _buildMarkdownConfig(CustomColors customColors) {
    return MarkdownConfig(
      configs: [
        PConfig(textStyle: textStyle ?? const TextStyle(fontSize: 16)),
        // 链接配置
        LinkConfig(
          style: TextStyle(
            color: customColors.markdownLinkColor,
            decoration: TextDecoration.none,
          ),
          onTap: (value) {
            if (onUrlTap != null) onUrlTap!(value);
          },
        ),
        // 代码块配置
        PreConfig(
          theme: monokaiTheme,
          decoration: BoxDecoration(
            color: customColors.markdownPreColor,
            borderRadius: BorderRadius.circular(5),
          ),
          textStyle: const TextStyle(fontSize: 14),
        ),
        // 代码配置
        CodeConfig(
          style: TextStyle(
            fontSize: 14,
            color: customColors.markdownCodeColor,
          ),
        ),
        // 图片配置
        ImgConfig(
          builder: (url, attributes) {
            if (url.isEmpty) {
              return const SizedBox();
            }

            if (url.startsWith('data:')) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.memory(
                  const Base64Decoder().convert(url.split(',')[1]),
                  fit: BoxFit.cover,
                ),
              );
            }

            return NetworkImagePreviewer(
              url: url,
              hidePreviewButton: true,
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    if (compact) {
      final markdownGenerator = MarkdownGenerator(
        generators: [latexGenerator],
        inlineSyntaxList: [LatexSyntax()],
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: markdownGenerator.buildWidgets(
          data,
          config: _buildMarkdownConfig(customColors),
        ),
      );
    }

    return MarkdownWidget(
      data: data,
      shrinkWrap: true,
      config: _buildMarkdownConfig(customColors),
    );
  }
}
