import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/page/chat/room_create.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:askaide/repo/model/model.dart' as mm;
import 'package:flutter_initicon/flutter_initicon.dart';

class ModelSwitcher extends StatelessWidget {
  final mm.Model? value;
  final Function(mm.Model? selected) onSelected;

  const ModelSwitcher({
    super.key,
    required this.onSelected,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return IconButton(
      onPressed: () async {
        HapticFeedbackHelper.mediumImpact();
        openSelectModelDialog(
          context,
          (selected) {
            onSelected(selected);
          },
          initValue: value?.uid(),
          enableClear: true,
          title: '选择要切换的对话模型',
        );
      },
      icon: value == null
          ? const Icon(Icons.smart_toy_outlined)
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
      tooltip: '切换对话模型',
    );
  }
}
