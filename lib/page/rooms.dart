import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              label: '编辑',
              backgroundColor: Colors.green,
              borderRadius: room.category == 'system'
                  ? BorderRadius.all(
                      Radius.circular(customColors.borderRadius ?? 8))
                  : BorderRadius.only(
                      topLeft: Radius.circular(customColors.borderRadius ?? 8),
                      bottomLeft:
                          Radius.circular(customColors.borderRadius ?? 8),
                    ),
              icon: Icons.edit,
              onPressed: (_) {
                final chatRoomBloc = context.read<RoomBloc>();
                context.push('/room/${room.id}/setting').then((value) {
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
              HapticFeedbackHelper.lightImpact();
              final chatRoomBloc = context.read<RoomBloc>();
              context.push('/room/${room.id}/chat').then((value) {
                chatRoomBloc.add(RoomsLoadEvent());
              });
            },
            child: Row(
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
                                color:
                                    customColors.weakLinkColor?.withAlpha(65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (room.systemPrompt != null &&
                                room.systemPrompt != '')
                              Text(
                                room.systemPrompt!,
                                style: TextStyle(
                                  color: customColors.weakLinkColor
                                      ?.withAlpha(150),
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            // if (room.description != null)
                            //   Text(
                            //     room.description!,
                            //     style:
                            //         Theme.of(context).textTheme.bodySmall,
                            //   ),
                            if (room.systemPrompt == null ||
                                room.systemPrompt == '')
                              Text(
                                room
                                    .modelName()
                                    .toUpperCase()
                                    .replaceAll('-TURBO', ''),
                                style: TextStyle(
                                  color: customColors.weakLinkColor
                                      ?.withAlpha(150),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Room room) {
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

    return RandomAvatar(
      id: room.avatar,
      size: 70,
      usage:
          Ability().supportAPIServer() ? AvatarUsage.room : AvatarUsage.legacy,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
    );
  }
}
