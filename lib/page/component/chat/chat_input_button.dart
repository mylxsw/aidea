import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class ChatInputButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  const ChatInputButton(
      {super.key, required this.text, required this.icon, required this.onPressed, this.isActive = false});

  @override
  State<ChatInputButton> createState() => _ChatInputButtonState();
}

class _ChatInputButtonState extends State<ChatInputButton> {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return IconButton(
      onPressed: widget.onPressed,
      icon: Container(
        decoration: BoxDecoration(
          color: widget.isActive ? customColors.linkColor?.withAlpha(100) : null,
          borderRadius: BorderRadius.circular(CustomSize.radiusValue * 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: widget.isActive ? customColors.linkColor : customColors.chatInputPanelText,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.isActive ? customColors.linkColor : customColors.chatInputPanelText,
              ),
            ),
          ],
        ),
      ),
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

class ChatInputSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final String text;

  const ChatInputSquareButton(
      {super.key, required this.icon, required this.onPressed, this.isActive = false, required this.text});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: onPressed,
        icon: Container(
          decoration: BoxDecoration(
            color: isActive ? customColors.linkColor?.withAlpha(100) : null,
            borderRadius: BorderRadius.circular(CustomSize.radiusValue * 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? customColors.linkColor : customColors.chatInputPanelText,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? customColors.linkColor : customColors.chatInputPanelText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
