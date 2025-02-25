import 'package:markdown/markdown.dart';

final List<Map<String, dynamic>> delimiterList = [
  {'left': r'$$', 'right': r'$$', 'display': true},
  {'left': r'$', 'right': r'$', 'display': false},
  {'left': r'\pu{', 'right': '}', 'display': false},
  {'left': r'\ce{', 'right': '}', 'display': false},
  {'left': r'\(', 'right': r'\)', 'display': false},
  {'left': '( ', 'right': ' )', 'display': false},
  {'left': r'\[', 'right': r'\]', 'display': true},
  {'left': '[ ', 'right': ' ]', 'display': true},
];

List<String> inlinePatterns = [];
List<String> blockPatterns = [];

String escapeRegex(String string) {
  return string.replaceAllMapped(RegExp(r'[-\/\\^$*+?.()|[\]{}]'), (match) {
    return '\\${match.group(0)}';
  });
}

String generateRegexRules(List<Map<String, dynamic>> delimiters) {
  for (var delimiter in delimiters) {
    String left = delimiter['left'];
    String right = delimiter['right'];
    // Ensure regex-safe delimiters
    String escapedLeft = escapeRegex(left);
    String escapedRight = escapeRegex(right);

    // Inline pattern
    inlinePatterns.add('$escapedLeft((?:\\\\.|[^\\\\\\n])*?(?:\\\\.|[^\\\\\\n]|(?!$escapedRight)))$escapedRight');
    // Block pattern
    blockPatterns.add('$escapedLeft\\n((?:\\\\[^]|[^\\\\])+?)\\n$escapedRight');
  }

  return '(${inlinePatterns.join("|")})(?=[\\s?!.,:？！。，：]|\$)';
}

final _latexPattern = generateRegexRules(delimiterList);

class LatexInlineSyntax extends InlineSyntax {
  LatexInlineSyntax() : super(_latexPattern);

  @override
  bool onMatch(InlineParser parser, Match match) {
    String raw = match.group(0) ?? '';

    int delimiterLength = 1;
    String mathStyle = 'text';
    // check delimiter
    for (var delimiter in delimiterList) {
      if (raw.startsWith(delimiter['left']) && raw.endsWith(delimiter['right'])) {
        mathStyle = delimiter['display'] ? 'display' : 'text';
        delimiterLength = delimiter['left'].length;
        break;
      }
    }

    final equation = raw.substring(delimiterLength, raw.length - delimiterLength);

    final element = Element.text('latex', equation);
    element.attributes['MathStyle'] = mathStyle;
    parser.addNode(element);

    return true;
  }
}
