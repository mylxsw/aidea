import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/chat/chat_preview.dart';
import 'package:askaide/page/component/chat/chat_share.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class SelectModeToolbar extends StatefulWidget {
  final ChatPreviewController chatPreviewController;
  const SelectModeToolbar({super.key, required this.chatPreviewController});

  @override
  State<SelectModeToolbar> createState() => _SelectModeToolbarState();
}

class _SelectModeToolbarState extends State<SelectModeToolbar> {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, topRight: CustomSize.radius),
        color: customColors.backgroundColor,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: () {
                var messages = widget.chatPreviewController.selectedMessages();
                if (messages.isEmpty) {
                  showErrorMessageEnhanced(context, AppLocale.noMessageSelected.getString(context));
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => ChatShareScreen(
                      messages: messages
                          .map((e) => ChatShareMessage(
                                content: e.message.text,
                                username: e.message.senderName,
                                avatarURL: e.message.avatarUrl,
                                leftSide: e.message.role == Role.receiver,
                                images: e.message.images,
                              ))
                          .toList(),
                    ),
                  ),
                );
                // var messages = chatPreviewController.selectedMessages();
                // if (messages.isEmpty) {
                //   showErrorMessageEnhanced(
                //       context, AppLocale.noMessageSelected.getString(context));
                //   return;
                // }
                // var shareText = messages.map((e) {
                //   if (e.message.role == Role.sender) {
                //     return '我：\n${e.message.text}';
                //   }

                //   return '助理：\n${e.message.text}';
                // }).join('\n\n');

                // shareTo(
                //   context,
                //   content: shareText,
                //   title: AppLocale.chatHistory.getString(context),
                // );
              },
              icon: Icon(Icons.share, color: customColors.linkColor),
              label: Text(
                AppLocale.share.getString(context),
                style: TextStyle(color: customColors.linkColor),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                widget.chatPreviewController.selectAllMessage();
              },
              icon: Icon(Icons.select_all_outlined, color: customColors.linkColor),
              label: Text(
                AppLocale.selectAll.getString(context),
                style: TextStyle(color: customColors.linkColor),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                if (widget.chatPreviewController.selectedMessageIds.isEmpty) {
                  showErrorMessageEnhanced(context, AppLocale.noMessageSelected.getString(context));
                  return;
                }

                openConfirmDialog(
                  context,
                  AppLocale.confirmDelete.getString(context),
                  () {
                    final ids = widget.chatPreviewController.selectedMessageIds.toList();
                    if (ids.isNotEmpty) {
                      context.read<ChatMessageBloc>().add(ChatMessageDeleteEvent(ids));

                      showErrorMessageEnhanced(context, AppLocale.operateSuccess.getString(context));

                      widget.chatPreviewController.exitSelectMode();
                    }
                  },
                  danger: true,
                );
              },
              icon: Icon(Icons.delete, color: customColors.linkColor),
              label: Text(
                AppLocale.delete.getString(context),
                style: TextStyle(color: customColors.linkColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
