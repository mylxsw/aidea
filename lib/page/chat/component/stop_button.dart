import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class StopButton extends StatelessWidget {
  final Function()? onPressed;
  final String label;
  const StopButton({super.key, this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return TextButton.icon(
      style: ButtonStyle(
        // minimumSize: MaterialStateProperty.all(const Size(0, 0)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        iconColor: const MaterialStatePropertyAll(Colors.red),
        backgroundColor:
            MaterialStatePropertyAll(customColors.chatInputPanelBackground),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: customColors.textfieldLabelColor,
        ),
      ),
      icon: const Icon(
        Icons.stop_circle_outlined,
        size: 13,
      ),
      onPressed: onPressed,
    );
  }
}
