import 'package:askaide/bloc/admin_room_bloc.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/chat_preview.dart';
import 'package:askaide/page/component/chat/message_state_manager.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/model/model.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';

class AdminRoomMessagesPage extends StatefulWidget {
  final SettingRepository setting;
  final int userId;
  final int roomId;
  final int roomType;
  const AdminRoomMessagesPage({
    super.key,
    required this.setting,
    required this.userId,
    required this.roomId,
    required this.roomType,
  });

  @override
  State<AdminRoomMessagesPage> createState() => _AdminRoomMessagesPageState();
}

class _AdminRoomMessagesPageState extends State<AdminRoomMessagesPage> {
  final ChatPreviewController controller = ChatPreviewController();
  Map<String, Model> models = {};

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<AdminRoomBloc>().add(AdminRoomLoadEvent(
          userId: widget.userId,
          roomId: widget.roomId,
        ));
    context.read<AdminRoomBloc>().add(AdminRoomRecentlyMessagesLoadEvent(
          userId: widget.userId,
          roomId: widget.roomId,
          roomType: widget.roomType,
        ));

    ModelAggregate.models().then((value) {
      setState(() {
        for (var element in value) {
          models[element.id] = element;
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: BlocBuilder<AdminRoomBloc, AdminRoomState>(
            buildWhen: (previous, current) => current is AdminRoomLoaded,
            builder: (context, state) {
              if (state is AdminRoomLoaded) {
                return Text(
                  state.room.name,
                  style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
                );
              }

              return const Text(
                'Character',
                style: TextStyle(fontSize: CustomSize.appBarTitleSize),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: customColors.backgroundContainerColor,
        ),
        body: BackgroundContainer(
          setting: widget.setting,
          child: RefreshIndicator(
            color: customColors.linkColor,
            onRefresh: () async {
              context.read<AdminRoomBloc>().add(AdminRoomRecentlyMessagesLoadEvent(
                    userId: widget.userId,
                    roomId: widget.roomId,
                    roomType: widget.roomType,
                  ));
            },
            displacement: 20,
            child: BlocConsumer<AdminRoomBloc, AdminRoomState>(
              listener: (context, state) {
                if (state is AdminRoomOperationResult) {
                  if (state.success) {
                    showSuccessMessage(AppLocale.operateSuccess.getString(context));
                  } else {
                    showErrorMessage(AppLocale.operateFailed.getString(context));
                  }
                }
              },
              buildWhen: (previous, current) => current is AdminRoomRecentlyMessagesLoaded,
              builder: (context, state) {
                if (state is AdminRoomRecentlyMessagesLoaded) {
                  return SafeArea(
                    top: false,
                    child: state.messages.isNotEmpty
                        ? ChatPreview(
                            padding: const EdgeInsets.only(top: 15, bottom: 15),
                            messages: state.messages.reversed.map((e) {
                              if (e.model != null) {
                                final model = models[e.model];
                                if (model != null) {
                                  if (e.avatarUrl == null && model.avatarUrl != null) {
                                    e.avatarUrl = model.avatarUrl;
                                  }

                                  e.senderName ??= model.name;
                                }
                              }

                              return MessageWithState(e, MessageState());
                            }).toList(),
                            controller: controller,
                            supportBloc: false,
                            senderNameBuilder: (message) {
                              if (message.role == Role.sender || message.senderName == null) {
                                return null;
                              }

                              return Container(
                                margin: const EdgeInsets.only(
                                  left: 10,
                                  bottom: 5,
                                  right: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      message.senderName!,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (message.ts != null)
                                      Text(
                                        '  ${DateFormat('yyyy/MM/dd HH:mm').format(message.ts!.toLocal())}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                            avatarBuilder: (message) {
                              if (message.role == Role.sender) {
                                return null;
                              }

                              if (message.avatarUrl != null) {
                                return RemoteAvatar(
                                  avatarUrl: message.avatarUrl!,
                                  size: 30,
                                );
                              }

                              if (message.model != null) {
                                final model = models[message.model];
                                if (model != null && model.avatarUrl != null) {
                                  return RemoteAvatar(
                                    avatarUrl: model.avatarUrl!,
                                    size: 30,
                                  );
                                }
                              }

                              return null;
                            },
                          )
                        : const Center(child: Text('No messages')),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
