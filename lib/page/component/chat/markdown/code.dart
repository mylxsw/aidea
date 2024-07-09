import 'package:askaide/helper/ability.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/default.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    final multiLine = element.textContent.trim().split("\n").length > 1;

    final child = SizedBox(
      child: HighlightView(
        // The original code to be highlighted
        element.textContent,

        // Specify language
        // It is recommended to give it a value for performance
        language: language,

        // Specify highlight theme
        // All available themes are listed in `themes` folder
        theme: Ability().themeMode != 'dark' ? defaultTheme : monokaiTheme,

        // Specify padding
        padding: multiLine
            ? const EdgeInsets.only(
                top: 30,
                bottom: 10,
                left: 10,
                right: 10,
              )
            : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),

        textStyle: const TextStyle(
          fontSize: 14,
          height: 1.5,
          wordSpacing: 3,
        ),
      ),
    );

    if (multiLine) {
      return Stack(
        children: [
          child,
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              tooltip: '复制代码',
              icon: const Icon(Icons.copy, size: 12),
              onPressed: () {
                FlutterClipboard.copy(element.textContent).then((value) {
                  showSuccessMessage('已复制到剪贴板');
                });
              },
            ),
          ),
        ],
      );
    }

    return child;
  }
}
