import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EnhancedInputSimple extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onPressed;
  final Icon? icon;
  final Widget? description;
  final EdgeInsets? padding;

  const EnhancedInputSimple({
    super.key,
    required this.title,
    required this.onPressed,
    this.value,
    this.icon,
    this.description,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return EnhancedInput(
      padding: padding,
      title: Text(
        title,
        style: TextStyle(
          color: customColors.textfieldLabelColor,
          fontSize: 16,
        ),
      ),
      value: value != null
          ? Text(
              value!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: customColors.textfieldValueColor,
                fontSize: 15,
              ),
            )
          : null,
      onPressed: onPressed,
      icon: icon,
      description: description,
    );
  }
}

class EnhancedInput extends StatelessWidget {
  final Widget title;
  final Widget? value;
  final VoidCallback onPressed;
  final Icon? icon;
  final Widget? description;
  final EdgeInsets? padding;

  const EnhancedInput({
    super.key,
    required this.title,
    required this.onPressed,
    this.value,
    this.icon,
    this.description,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: CustomSize.borderRadiusAll,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 85,
                  child: title,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 160,
                        ),
                        child: value ?? Container(),
                      ),
                      const SizedBox(width: 10),
                      icon ??
                          const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 18,
                            color: Colors.grey,
                          ),
                    ],
                  ),
                ),
              ],
            ),
            if (description != null) const SizedBox(height: 10),
            if (description != null) description!,
          ],
        ),
      ),
    );
  }
}
