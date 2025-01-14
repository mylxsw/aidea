import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class CharacterBox extends StatelessWidget {
  final Room room;
  const CharacterBox({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: AppLocale.configure.getString(context),
              backgroundColor: Colors.green,
              borderRadius: room.category == 'system'
                  ? CustomSize.borderRadiusAll
                  : const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
              icon: Icons.edit,
              onPressed: (_) {
                final chatRoomBloc = context.read<RoomBloc>();
                final redirectUrl = room.roomType == 4 ? '/group-chat/${room.id}/edit' : '/room/${room.id}/setting';

                context.push(redirectUrl).then((value) {
                  chatRoomBloc.add(RoomsLoadEvent());
                });
              },
            ),
            if (room.category != 'system')
              SlidableAction(
                label: AppLocale.delete.getString(context),
                borderRadius: const BorderRadius.only(topRight: CustomSize.radius, bottomRight: CustomSize.radius),
                backgroundColor: Colors.red,
                icon: Icons.delete,
                onPressed: (_) {
                  openConfirmDialog(
                    context,
                    AppLocale.confirmToDeleteRoom.getString(context),
                    () => context.read<RoomBloc>().add(RoomDeleteEvent(room.id!)),
                    danger: true,
                  );
                },
              ),
          ],
        ),
        child: buildItem(customColors, context),
      ),
    );
  }

  Widget buildItem(CustomColors customColors, BuildContext context) {
    return Material(
      borderRadius: CustomSize.borderRadius,
      color: customColors.backgroundContainerColor,
      child: CharacterBoxItem(
        onTap: () {
          HapticFeedbackHelper.lightImpact();
          final chatRoomBloc = context.read<RoomBloc>();
          context.push('/room/${room.id}/chat').then((value) {
            chatRoomBloc.add(RoomsLoadEvent(forceRefresh: true));
          });
        },
        name: room.name,
        desc: room.description ?? room.systemPrompt,
        model: room.model,
        avatarUrl: room.avatarUrl,
      ),
    );
  }
}

class CharacterBoxItem extends StatelessWidget {
  final Function() onTap;
  final String? avatarUrl;
  final String name;
  final String? model;
  final String? desc;
  const CharacterBoxItem({
    super.key,
    required this.onTap,
    required this.name,
    this.avatarUrl,
    this.model,
    this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Material(
      borderRadius: CustomSize.borderRadius,
      color: customColors.backgroundContainerColor,
      child: InkWell(
        borderRadius: CustomSize.borderRadiusAll,
        onTap: onTap,
        child: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAvatar(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        buildRoomDesc(customColors),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (model != null && Ability().usingLocalOpenAIModel(model!))
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: customColors.backgroundContainerColor,
                    borderRadius: const BorderRadius.only(topRight: CustomSize.radius, bottomLeft: CustomSize.radius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    'local',
                    style: TextStyle(
                      color: customColors.weakTextColor,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomDesc(CustomColors customColors) {
    if (desc != null && desc != '') {
      return Text(
        desc!,
        style: TextStyle(
          color: customColors.weakLinkColor?.withAlpha(150),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return const SizedBox();
  }

  Widget buildAvatar() {
    if (avatarUrl != null && avatarUrl!.startsWith('http')) {
      return SizedBox(
        width: 70,
        height: 70,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
          child: CachedNetworkImageEnhanced(
            imageUrl: imageURL(avatarUrl!, qiniuImageTypeAvatar),
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    return Initicon(
      text: name.split('、').join(' '),
      size: 70,
      backgroundColor: Colors.grey.withAlpha(100),
      borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
    );
  }
}
