import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CitationSyntax extends md.InlineSyntax {
  CitationSyntax() : super('\\[citation:(\\d+)\\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final num = match[1]!;
    parser.addNode(md.Text(' ${_getNumberEmoji(num)}'));

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
    final String text = element.textContent;
    if (text.isEmpty) {
      return const SizedBox();
    }

    final href = element.attributes['href'];

    if (citationPattern.hasMatch(text)) {
      final num = text.replaceAll('citation:', '');
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onTap?.call(href!),
          child: Text(_getNumberEmoji(num)),
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => onTap?.call(href!),
        child: Text(text, style: preferredStyle),
      ),
    );
  }
}

String _getNumberEmoji(String num) {
  return switch (num) {
    '1' => '①',
    '2' => '②',
    '3' => '③',
    '4' => '④',
    '5' => '⑤',
    '6' => '⑥',
    '7' => '⑦',
    '8' => '⑧',
    '9' => '⑨',
    _ => num,
  };
}
