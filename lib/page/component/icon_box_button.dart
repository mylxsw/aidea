import 'package:flutter/material.dart';

class IconBoxButton extends StatelessWidget {
  final double? width;
  final String title;
  final IconData icon;
  final IconData? smallIcon;
  final Function()? onTap;

  const IconBoxButton({
    super.key,
    this.width,
    required this.title,
    required this.icon,
    this.smallIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onTap?.call(),
      child: Container(
        height: 75,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(20),
          border: Border.all(
            color: Colors.grey.withAlpha(50),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                Icon(smallIcon ?? Icons.keyboard_arrow_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
