import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:flutter/material.dart';

class IconBox extends StatelessWidget {
  final Icon icon;
  final Widget title;
  final Function()? onTap;
  const IconBox({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: CustomSize.borderRadius),
      onPressed: onTap,
      child: Column(
        children: [
          icon,
          const SizedBox(height: 10),
          title,
        ],
      ),
    );
  }
}
