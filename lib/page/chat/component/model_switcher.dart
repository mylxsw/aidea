import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/room_create.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:askaide/repo/model/model.dart' as mm;
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ModelSwitcher extends StatelessWidget {
  final mm.Model? value;
  final Function(mm.Model? selected) onSelected;

  const ModelSwitcher({
    super.key,
    required this.onSelected,
    this.value,
  });

  static void openActionDialog({
    required BuildContext context,
    required Function(mm.Model? selected) onSelected,
    mm.Model? initValue,
  }) {
    HapticFeedbackHelper.mediumImpact();
    openSelectModelDialog(
      context,
      (selected) {
        onSelected(selected);
      },
      initValue: initValue?.uid(),
      title: AppLocale.switchModelTitle.getString(context),
      withCustom: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return IconButton(
      onPressed: () async {
        openActionDialog(
          context: context,
          onSelected: onSelected,
          initValue: value,
        );
      },
      icon: value == null
          ? const Icon(Icons.alternate_email_outlined)
          // Icons.theater_comedy_outlined
          // Icons.model_training_outlined
          // Icons.switch_access_shortcut_outlined
          // Icons.assistant_outlined
          : value!.avatarUrl == null
              ? Initicon(
                  text: value!.name.split('、').join(' '),
                  size: 25,
                  backgroundColor: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(100),
                )
              : RemoteAvatar(
                  avatarUrl: value!.avatarUrl!,
                  size: 25,
                  radius: 100,
                ),
      color: customColors.chatInputPanelText,
      splashRadius: 20,
      tooltip: AppLocale.switchModel.getString(context),
    );
  }
}
