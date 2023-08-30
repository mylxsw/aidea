import 'package:askaide/page/component/image_preview.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';

class Markdown extends StatelessWidget {
  final String data;
  final Function(String value)? onUrlTap;
  final bool compact;
  final TextStyle? textStyle;
  final cacheManager = DefaultCacheManager();

  Markdown({
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
            decoration: BoxDecoration(
              color: customColors.markdownPreColor,
              borderRadius: BorderRadius.circular(5),
            ),
            textStyle: const TextStyle(fontSize: 14)),
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
        config: _buildMarkdownConfig(customColors),
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: markdownGenerator.buildWidgets(data),
      );
    }

    return MarkdownWidget(
      data: data,
      shrinkWrap: true,
      config: _buildMarkdownConfig(customColors),
    );
  }
}
