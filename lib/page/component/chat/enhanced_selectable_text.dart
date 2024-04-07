import 'package:flutter/material.dart';

class EnhancedSelectableText extends StatefulWidget {
  final String text;
  const EnhancedSelectableText({super.key, required this.text});

  @override
  State<EnhancedSelectableText> createState() => _EnhancedSelectableTextState();
}

class _EnhancedSelectableTextState extends State<EnhancedSelectableText> {
  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
