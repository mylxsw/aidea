import 'dart:math';

import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class HelpTips extends StatelessWidget {
  final Function(String text)? onSubmitMessage;
  final Function()? onNewChat;
  const HelpTips({super.key, this.onSubmitMessage, this.onNewChat});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    List<Builder> children = [
      if (onNewChat != null && onSubmitMessage != null)
        Builder(
          builder: (context) => _buildNewChatActionTip(
              customColors, context, (text) => onSubmitMessage!(text)),
        ),
      if (onSubmitMessage != null)
        Builder(
            builder: (context) => _buildContinueActionTip(
                customColors, context, onSubmitMessage!))
    ];

    // 随机取一个 builder
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: children[Random().nextInt(children.length)],
    );
  }

  RichText _buildNewChatActionTip(CustomColors customColors,
      BuildContext context, Function(String text) onSubmit) {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: '想要开启新的聊天？试试 ',
          style: TextStyle(
            color: customColors.dialogDefaultTextColor,
            fontSize: 12,
          ),
        ),
        TextSpan(
            text: AppLocale.newChat.getString(context),
            style: TextStyle(
              color: customColors.linkColor,
              fontSize: 12,
            ),
            recognizer: TapGestureRecognizer()..onTap = onNewChat),
      ],
    ));
  }

  RichText _buildContinueActionTip(CustomColors customColors,
      BuildContext context, Function(String text) onSubmit) {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: '想要更多内容？试着对我说 ',
          style: TextStyle(
            color: customColors.dialogDefaultTextColor,
            fontSize: 12,
          ),
        ),
        TextSpan(
            text: AppLocale.continueMessage.getString(context),
            style: TextStyle(
              color: customColors.linkColor,
              fontSize: 12,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onSubmit(AppLocale.continueMessage.getString(context));
              }),
      ],
    ));
  }
}
