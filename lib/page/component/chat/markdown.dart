// import 'dart:convert';
// import 'package:askaide/helper/platform.dart';
// import 'package:askaide/page/component/chat/markdown/latex.dart';
// import 'package:askaide/page/component/dialog.dart';
// import 'package:clipboard/clipboard.dart';
// import 'package:markdown_widget/config/all.dart';
// import 'package:markdown_widget/widget/all.dart';

import 'package:askaide/page/component/chat/markdown/citation.dart';
import 'package:askaide/page/component/chat/markdown/code.dart';
import 'package:askaide/page/component/image_preview.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as mm;

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
    // if (!PlatformTool.isWeb()) {
    //   return MarkdownPlus(
    //     data: data,
    //     onUrlTap: onUrlTap,
    //     textStyle: textStyle,
    //     compact: true,
    //   );
    // }

    final customColors = Theme.of(context).extension<CustomColors>()!;
    return md.MarkdownBody(
      shrinkWrap: true,
      selectable: false,
      styleSheetTheme: md.MarkdownStyleSheetBaseTheme.material,
      styleSheet: md.MarkdownStyleSheet(
        p: textStyle ?? TextStyle(fontSize: CustomSize.markdownTextSize, height: 1.5),
        listBullet: textStyle ?? TextStyle(fontSize: CustomSize.markdownTextSize, height: 1.5),
        code: TextStyle(
          fontSize: CustomSize.markdownCodeSize,
          color: customColors.markdownCodeColor,
          backgroundColor: Colors.transparent,
        ),
        codeblockPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        codeblockDecoration: const BoxDecoration(borderRadius: CustomSize.borderRadiusAll),
        tableBorder: TableBorder.all(
          color: customColors.weakTextColor!.withOpacity(0.5),
          width: 1,
        ),
        tableColumnWidth: const FlexColumnWidth(),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: customColors.weakTextColor!.withOpacity(0.4),
              width: 4,
            ),
          ),
        ),
        a: TextStyle(
          color: customColors.linkColor,
          decoration: TextDecoration.none,
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

        return ClipRRect(borderRadius: CustomSize.borderRadiusAll, child: Image.network(uri.toString()));
      },
      extensionSet: mm.ExtensionSet(
        [
          ...mm.ExtensionSet.gitHubFlavored.blockSyntaxes,
          LatexBlockSyntax(),
        ],
        <mm.InlineSyntax>[
          mm.EmojiSyntax(),
          ...mm.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          LatexInlineSyntax(),
          CitationSyntax(),
        ],
      ),
      data: data,
      builders: {
        'code': CodeElementBuilder(customColors),
        'latex': LatexElementBuilder(),
      },
    );
  }
}

// class MarkdownPlus extends StatelessWidget {
//   final String data;
//   final Function(String value)? onUrlTap;
//   final bool compact;
//   final TextStyle? textStyle;
//   final cacheManager = DefaultCacheManager();

//   MarkdownPlus({
//     super.key,
//     required this.data,
//     this.onUrlTap,
//     this.compact = true,
//     this.textStyle,
//   });

//   MarkdownConfig _buildMarkdownConfig(CustomColors customColors) {
//     return MarkdownConfig(
//       configs: [
//         PConfig(textStyle: textStyle ?? TextStyle(fontSize: CustomSize.markdownTextSize)),
//         // 链接配置
//         LinkConfig(
//           style: TextStyle(
//             color: customColors.markdownLinkColor,
//             decoration: TextDecoration.none,
//           ),
//           onTap: (value) {
//             if (onUrlTap != null) onUrlTap!(value);
//           },
//         ),
//         // 代码块配置
//         PreConfig(
//           theme: codeTheme(),
//           decoration: const BoxDecoration(borderRadius: CustomSize.borderRadiusAll),
//           margin: const EdgeInsets.symmetric(vertical: 0.0),
//           padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10),
//           textStyle: TextStyle(fontSize: CustomSize.markdownCodeSize),
//           wrapper: (child, code, language) {
//             return Card(
//               elevation: 0,
//               color: customColors.markdownPreColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: CustomSize.borderRadius,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     decoration: BoxDecoration(
//                       color: customColors.listTileBackgroundColor,
//                       borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, topRight: CustomSize.radius),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           language,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: customColors.weakTextColor,
//                           ),
//                         ),
//                         TextButton.icon(
//                           icon: Icon(
//                             Icons.copy,
//                             size: 14,
//                             color: customColors.weakTextColorLess,
//                           ),
//                           label: Text(
//                             'Copy',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: customColors.weakTextColorLess,
//                             ),
//                           ),
//                           onPressed: () {
//                             FlutterClipboard.copy(code).then((value) {
//                               showSuccessMessage('Copied to clipboard');
//                             });
//                           },
//                           style: ButtonStyle(
//                             overlayColor: WidgetStateProperty.all(Colors.transparent),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   child,
//                 ],
//               ),
//             );
//           },
//         ),
//         // 代码配置
//         CodeConfig(
//           style: TextStyle(
//             fontSize: CustomSize.markdownCodeSize,
//             color: customColors.markdownCodeColor,
//           ),
//         ),
//         // 图片配置
//         ImgConfig(
//           builder: (url, attributes) {
//             if (url.isEmpty) {
//               return const SizedBox();
//             }

//             if (url.startsWith('data:')) {
//               return ClipRRect(
//                 borderRadius: CustomSize.borderRadiusAll,
//                 child: Image.memory(
//                   const Base64Decoder().convert(url.split(',')[1]),
//                   fit: BoxFit.cover,
//                 ),
//               );
//             }

//             return NetworkImagePreviewer(
//               url: url,
//               hidePreviewButton: true,
//             );
//           },
//         ),
//         HrConfig(height: 1, color: customColors.weakTextColorLess?.withAlpha(100) ?? Colors.transparent),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final customColors = Theme.of(context).extension<CustomColors>()!;
//     final markdownGenerator = MarkdownGenerator(
//       generators: [latexGenerator],
//       inlineSyntaxList: [LatexSyntax()],
//     );

//     if (compact) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.start,
//         textDirection: TextDirection.ltr,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: markdownGenerator.buildWidgets(
//           data,
//           config: _buildMarkdownConfig(customColors),
//         ),
//       );
//     }

//     return MarkdownWidget(
//       data: data,
//       shrinkWrap: true,
//       config: _buildMarkdownConfig(customColors),
//       markdownGenerator: markdownGenerator,
//     );
//   }
// }
