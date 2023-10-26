import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/component/group_avatar.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class RoomItem extends StatelessWidget {
  final Room room;
  const RoomItem({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(customColors.borderRadius ?? 8),
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: '设置',
              backgroundColor: Colors.green,
              borderRadius: room.category == 'system'
                  ? BorderRadius.all(
                      Radius.circular(customColors.borderRadius ?? 8))
                  : BorderRadius.only(
                      topLeft: Radius.circular(customColors.borderRadius ?? 8),
                      bottomLeft:
                          Radius.circular(customColors.borderRadius ?? 8),
                    ),
              icon: Icons.settings,
              onPressed: (_) {
                final chatRoomBloc = context.read<RoomBloc>();
                final redirectUrl = room.roomType == 4
                    ? '/group-chat/${room.id}/edit'
                    : '/room/${room.id}/setting';

                context.push(redirectUrl).then((value) {
                  chatRoomBloc.add(RoomsLoadEvent());
                });
              },
            ),
            if (room.category != 'system')
              SlidableAction(
                label: AppLocale.delete.getString(context),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(customColors.borderRadius ?? 8),
                  bottomRight: Radius.circular(customColors.borderRadius ?? 8),
                ),
                backgroundColor: Colors.red,
                icon: Icons.delete,
                onPressed: (_) {
                  openConfirmDialog(
                    context,
                    AppLocale.confirmToDeleteRoom.getString(context),
                    () =>
                        context.read<RoomBloc>().add(RoomDeleteEvent(room.id!)),
                    danger: true,
                  );
                },
              ),
          ],
        ),
        child: Material(
          borderRadius:
              BorderRadius.all(Radius.circular(customColors.borderRadius ?? 8)),
          color: customColors.columnBlockBackgroundColor,
          child: InkWell(
            borderRadius: BorderRadius.all(
                Radius.circular(customColors.borderRadius ?? 8)),
            onTap: () {
              final redirectRoute = room.roomType == 4
                  ? '/group-chat/${room.id}/chat'
                  : '/room/${room.id}/chat';
              HapticFeedbackHelper.lightImpact();
              final chatRoomBloc = context.read<RoomBloc>();
              context.push(redirectRoute).then((value) {
                chatRoomBloc.add(RoomsLoadEvent(forceRefresh: true));
              });
            },
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatar(room),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    room.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  humanTime(room.lastActiveTime),
                                  style: TextStyle(
                                    color: customColors.weakLinkColor
                                        ?.withAlpha(65),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            buildRoomDesc(customColors),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (room.roomType == 4)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: customColors.backgroundContainerColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Text(
                        '群聊',
                        style: TextStyle(
                          color: customColors.weakTextColor,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRoomDesc(CustomColors customColors) {
    if (room.description != null && room.description != '') {
      return Text(
        room.description!,
        style: TextStyle(
          color: customColors.weakLinkColor?.withAlpha(150),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (room.systemPrompt != null && room.systemPrompt != '') {
      return Text(
        room.systemPrompt!,
        style: TextStyle(
          color: customColors.weakLinkColor?.withAlpha(150),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (room.systemPrompt == null || room.systemPrompt == '') {
      Text(
        room.modelName().toUpperCase().replaceAll('-TURBO', ''),
        style: TextStyle(
          color: customColors.weakLinkColor?.withAlpha(150),
          fontSize: 13,
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildAvatar(Room room) {
    if (room.members.length == 1 &&
        (room.avatarUrl == null || room.avatarUrl == '')) {
      room.avatarUrl = room.members[0];
    }

    if (room.avatarUrl != null && room.avatarUrl!.startsWith('http')) {
      return SizedBox(
        width: 70,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          child: CachedNetworkImageEnhanced(
            imageUrl: imageURL(room.avatarUrl!, qiniuImageTypeAvatar),
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    if (room.members.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        child: GroupAvatar(
          size: 70,
          avatars: room.members,
        ),
      );
    }

    return Initicon(
      text: room.name.split('、').join(' '),
      size: 70,
      backgroundColor: Colors.grey.withAlpha(100),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
    );
  }
}
