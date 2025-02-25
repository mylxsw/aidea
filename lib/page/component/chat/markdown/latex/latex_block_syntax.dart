import 'package:markdown/markdown.dart';

class LatexBlockSyntax extends BlockSyntax {
  @override
  RegExp get pattern => RegExp(
        r'^(?:(\${1,2})(?:\n|$))|(?:(?:\\\[(.+)\\\])(?:\n|$))',
        multiLine: true,
      );

  LatexBlockSyntax() : super();

  @override
  List<Line> parseChildLines(BlockParser parser) {
    final m = pattern.firstMatch(parser.current.content);
    if (m?[2] != null) {
      parser.advance();
      return [Line(m?[2] ?? '')];
    }

    final childLines = <Line>[];
    parser.advance();

    while (!parser.isDone) {
      final match = pattern.hasMatch(parser.current.content);
      if (!match) {
        childLines.add(parser.current);
        parser.advance();
      } else {
        parser.advance();
        break;
      }
    }

    return childLines;
  }

  @override
  Node parse(BlockParser parser) {
    final lines = parseChildLines(parser);
    final content = lines.map((e) => e.content).join('\n').trim();
    final textElement = Element.text('latex', content);
    textElement.attributes['MathStyle'] = 'display';

    return Element('p', [textElement]);
  }
}
