import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MessageBoxSyntax extends md.InlineSyntax {
  MessageBoxSyntax() : super(r'\[::(info|warn|error|success)::\]>>(.*?)$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final type = match[1]!;
    final message = match[2]!;

    final node = md.Text(message);
    final el = md.Element('message-box', [node]);
    el.attributes['type'] = type;
    parser.addNode(el);

    return true;
  }
}

class MessageBoxBuilder extends MarkdownElementBuilder {
  MessageBoxBuilder();

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

    final type = element.attributes['type'] ?? 'info';
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: MessageBox(type: type, text: text),
          )
        ],
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  final String type;
  final String text;

  MessageBox({super.key, required this.type, required this.text});

  final Map<String, Color> typeColors = {
    'info': Colors.blue,
    'warn': const Color.fromARGB(255, 255, 165, 0),
    'error': Colors.red,
    'success': Colors.green,
  };

  final Map<String, IconData> typeIcons = {
    'info': Icons.info,
    'warn': Icons.report,
    'error': Icons.error,
    'success': Icons.check_circle,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: CustomSize.borderRadiusAll,
        color: typeColors[type],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeIcons[type],
            color: Colors.white,
            size: CustomSize.markdownTextSize,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: AutoSizeText(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: CustomSize.markdownTextSize,
              ),
              maxFontSize: CustomSize.markdownTextSize,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
