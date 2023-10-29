import 'package:flutter/material.dart';

import 'package:askaide/page/component/theme/custom_theme.dart';

class ChatToolsButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final void Function()? onTap;

  const ChatToolsButton({
    super.key,
    required this.text,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  State<ChatToolsButton> createState() => _ChatToolsButtonState();
}

class _ChatToolsButtonState extends State<ChatToolsButton> {
  bool _mouseHover = false;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            _mouseHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            _mouseHover = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _mouseHover
                ? customColors.tagsBackgroundHover
                : customColors.tagsBackground,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 11,
                color: widget.iconColor,
              ),
              const SizedBox(width: 2),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 11,
                  color: customColors.tagsText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
