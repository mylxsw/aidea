import 'package:askaide/bloc/admin_room_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/component/group_avatar.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class AdminRoomsPage extends StatefulWidget {
  final SettingRepository setting;
  final int userId;
  const AdminRoomsPage({
    super.key,
    required this.setting,
    required this.userId,
  });

  @override
  State<AdminRoomsPage> createState() => _AdminRoomsPageState();
}

class _AdminRoomsPageState extends State<AdminRoomsPage> {
  @override
  void initState() {
    context.read<AdminRoomBloc>().add(AdminRoomsLoadEvent(userId: widget.userId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'Characters',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: RefreshIndicator(
            color: customColors.linkColor,
            onRefresh: () async {
              context.read<AdminRoomBloc>().add(AdminRoomsLoadEvent(userId: widget.userId));
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
              buildWhen: (previous, current) => current is AdminRoomsLoaded,
              builder: (context, state) {
                if (state is AdminRoomsLoaded) {
                  return SafeArea(
                    top: false,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: state.rooms.length,
                      itemBuilder: (context, index) {
                        final room = state.rooms[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
                          child: Material(
                            borderRadius: CustomSize.borderRadius,
                            color: customColors.columnBlockBackgroundColor,
                            child: InkWell(
                              borderRadius: CustomSize.borderRadiusAll,
                              onTap: () {
                                context.push(
                                    '/admin/users/${widget.userId}/rooms/${room.id}/messages?room_type=${room.roomType ?? 1}');
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
                                                      color: customColors.weakLinkColor?.withAlpha(65),
                                                      fontSize: 10,
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
                                  if (room.roomType == 4)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: customColors.backgroundContainerColor,
                                          borderRadius: const BorderRadius.only(
                                            topRight: CustomSize.radius,
                                            bottomLeft: CustomSize.radius,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        child: Text(
                                          AppLocale.groupChat.getString(context),
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
                          ),
                        );
                      },
                    ),
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

  Widget _buildAvatar(RoomInServer room) {
    if (room.members.length == 1 && (room.avatarUrl == null || room.avatarUrl == '')) {
      room.avatarUrl = room.members[0];
    }

    if (room.avatarUrl != null && room.avatarUrl!.startsWith('http')) {
      return SizedBox(
        width: 70,
        height: 70,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
          child: CachedNetworkImageEnhanced(
            imageUrl: imageURL(room.avatarUrl!, qiniuImageTypeAvatar),
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    if (room.members.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
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
      borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
    );
  }
}
