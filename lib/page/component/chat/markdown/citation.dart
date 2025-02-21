import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CitationSyntax extends md.InlineSyntax {
  final List<String> citations;

  CitationSyntax({required this.citations}) : super('(?:\\[|【)\\s*citation\\s*:\\s*(\\d+)\\s*(?:\\]|】)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final num = match[1]!;
    final node = md.Text(num);

    try {
      final el = md.Element('citation', [node]);
      el.attributes['href'] = citations[int.parse(num) - 1];
      parser.addNode(el);
    } catch (e) {
      parser.addNode(md.Element('citation', [node]));
    }

    return true;
  }
}

class CitationBuilder extends MarkdownElementBuilder {
  final citationPattern = RegExp(r'^citation:\d+$');

  final Function(String href)? onTap;

  CitationBuilder({this.onTap});

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final String text = element.textContent;
    if (text.isEmpty) {
      return const SizedBox();
    }

    final href = element.attributes['href'];
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (href != null) {
                    onTap?.call(href);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: customColors.weakTextColorLess,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
