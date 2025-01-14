import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AdvancedButton extends StatelessWidget {
  final bool showAdvancedOptions;
  final Function(bool) onPressed;
  const AdvancedButton({super.key, required this.showAdvancedOptions, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Center(
      child: EnhancedButton(
        title:
            showAdvancedOptions ? AppLocale.collapseOptions.getString(context) : AppLocale.advanced.getString(context),
        width: 100,
        backgroundColor: Colors.transparent,
        color: customColors.weakTextColorLess,
        fontSize: 13,
        icon: Icon(
          showAdvancedOptions ? Icons.unfold_less : Icons.unfold_more,
          color: customColors.weakTextColorLess,
          size: 13,
        ),
        onPressed: () {
          onPressed(!showAdvancedOptions);
        },
      ),
    );
  }
}
