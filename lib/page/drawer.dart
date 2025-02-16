import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/account_quota_card.dart';
import 'package:askaide/page/component/chat/role_avatar.dart';
import 'package:askaide/page/component/social_icon.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/user.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  @override
  void initState() {
    super.initState();

    reload();
  }

  void reload() {
    if (Ability().isUserLogon()) {
      context.read<AccountBloc>().add(AccountLoadEvent(cache: false));
    }

    context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
    context.read<RoomBloc>().add(RoomsRecentLoadEvent());
  }

  double maxDrawerWidth() {
    final width = MediaQuery.of(context).size.width * 0.85;
    return width > 334.0 ? 334.0 : width;
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Drawer(
      width: maxDrawerWidth(),
      shape: RoundedRectangleBorder(
        borderRadius: PlatformTool.isDesktop()
            ? BorderRadius.zero
            : const BorderRadius.only(
                topRight: CustomSize.radius,
                bottomRight: CustomSize.radius,
              ),
      ),
      backgroundColor: customColors.backgroundContainerColor,
      shadowColor: customColors.backgroundInvertedColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SafeArea(child: SizedBox(height: 20)),
                      if (Ability().isUserLogon() && Ability().enableDigitalHuman)
                        ListTile(
                          leading: const Icon(Icons.group_outlined),
                          title: Text(AppLocale.homeTitle.getString(context)),
                          onTap: () {
                            context.push('/characters').whenComplete(reload);
                          },
                        ),
                      if (Ability().isUserLogon() && Ability().enableDigitalHuman)
                        BlocBuilder<RoomBloc, RoomState>(
                          buildWhen: (previous, current) => current is RoomsRecentLoaded,
                          builder: (_, state) {
                            if (state is RoomsRecentLoaded) {
                              return ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(0),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.rooms.length,
                                itemBuilder: (context, index) {
                                  final item = state.rooms[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.only(left: 30),
                                    dense: true,
                                    leading: RoleAvatar(
                                      avatarUrl: item.avatarUrl,
                                      name: item.name,
                                      avatarSize: 25,
                                    ),
                                    title: Text(item.name),
                                    onTap: () {
                                      context.push('/room/${item.id}/chat').whenComplete(reload);
                                    },
                                  );
                                },
                              );
                            }

                            return const SizedBox();
                          },
                        ),
                      if (Ability().enableGallery)
                        ListTile(
                          leading: const Icon(Icons.auto_awesome_outlined),
                          title: Text(AppLocale.discover.getString(context)),
                          onTap: () {
                            context.push('/creative-gallery').whenComplete(reload);
                          },
                        ),
                      // ListTile(
                      //   leading: const Icon(Icons.palette_outlined),
                      //   title: Text(AppLocale.creativeIsland.getString(context)),
                      //   onTap: () {
                      //     context.push('/creative-draw');
                      //   },
                      // ),
                      if (Ability().enableGallery || (Ability().isUserLogon() && Ability().enableDigitalHuman))
                        Divider(
                          color: customColors.weakTextColor?.withAlpha(50),
                          height: 10,
                          indent: 10,
                          endIndent: 10,
                        ),
                      BlocBuilder<ChatChatBloc, ChatChatState>(
                        buildWhen: (previous, current) => current is ChatChatRecentHistoriesLoaded,
                        builder: (_, state) {
                          if (state is ChatChatRecentHistoriesLoaded) {
                            // Group histories by time
                            final now = DateTime.now();
                            final groups = <String, List<ChatHistory>>{};

                            for (var history in state.histories) {
                              final created = DateTime.fromMillisecondsSinceEpoch(
                                  (history.createdAt ?? DateTime.now()).millisecondsSinceEpoch);
                              final difference = now.difference(created);

                              String groupKey;
                              if (difference.inDays < 4) {
                                groupKey = AppLocale.recently.getString(context);
                              } else if (difference.inDays < 7) {
                                groupKey = '4 ${AppLocale.daysAgo.getString(context)}';
                              } else if (difference.inDays < 14) {
                                groupKey = AppLocale.lastWeek.getString(context);
                              } else if (difference.inDays < 30) {
                                final weeks = (difference.inDays / 7).floor();
                                groupKey = '$weeks ${AppLocale.weeksAgo.getString(context)}';
                              } else if (difference.inDays < 365) {
                                if (difference.inDays < 60) {
                                  groupKey = AppLocale.lastMonth.getString(context);
                                }
                                final months = (difference.inDays / 30).floor();
                                groupKey = '$months ${AppLocale.monthsAgo.getString(context)}';
                              } else if (difference.inDays < 730) {
                                groupKey = AppLocale.lastYear.getString(context);
                              } else {
                                groupKey = AppLocale.longTimeAgo.getString(context);
                              }

                              groups.putIfAbsent(groupKey, () => []).add(history);
                            }

                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(0),
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      groups.entries.fold(0, (sum, entry) => (sum ?? 0) + entry.value.length + 1),
                                  itemBuilder: (context, index) {
                                    int itemCount = 0;
                                    for (var entry in groups.entries) {
                                      if (index == itemCount) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                                              child: Text(
                                                entry.key,
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(),
                                            if (index == 0)
                                              IconButton(
                                                onPressed: () {
                                                  context.push('/chat-chat/history').whenComplete(() {
                                                    if (context.mounted) {
                                                      context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.filter_list,
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        );
                                      }

                                      itemCount += 1;

                                      if (index < itemCount + entry.value.length) {
                                        final item = entry.value[index - itemCount];
                                        return ListTile(
                                          contentPadding: const EdgeInsets.only(left: 30),
                                          title: Text(
                                            item.title ?? 'Unknown',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () {
                                            context.push(
                                                '/chat-anywhere?chat_id=${item.id}&model=${item.model}&title=${item.title}');
                                          },
                                        );
                                      }

                                      itemCount += entry.value.length;
                                    }

                                    return const SizedBox();
                                  },
                                ),
                              ],
                            );
                          }

                          return SocialIconGroup(
                            isSettingTiles: true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 100,
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: buildAccountCard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAccountCard(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 6,
          child: IconButton(
            onPressed: () {
              context.push('/setting');
            },
            icon: const Icon(Icons.more_horiz),
            tooltip: AppLocale.settings.getString(context),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (_, state) {
              UserInfo? userInfo;
              if (state is AccountLoaded) {
                userInfo = state.user;
              }

              return AccountQuotaCard(
                userInfo: userInfo,
                noBorder: true,
                onPaymentReturn: () {
                  if (userInfo != null) {
                    context.read<AccountBloc>().add(AccountLoadEvent(cache: false));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSocialMedia(BuildContext context, CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "${AppLocale.socialMedia.getString(context)} ",
              style: TextStyle(
                color: customColors.weakTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Transform.rotate(
              angle: 90 * 3.1415926535897932 / 180,
              child: Icon(
                Icons.turn_right,
                color: customColors.weakTextColor,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                launchUrlString(
                  'https://ai.aicode.cc/social/home',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Image.asset('assets/app-256-transparent.png', width: 25),
            ),
            GestureDetector(
              onTap: () {
                launchUrlString(
                  'https://weibo.com/code404',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Image.asset('assets/weibo.png', width: 25),
            ),
            GestureDetector(
              onTap: () {
                launchUrlString(
                  'https://ai.aicode.cc/social/github',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Image.asset('assets/github.png', width: 25),
            ),
            GestureDetector(
              onTap: () {
                launchUrlString(
                  'https://ai.aicode.cc/social/wechat-platform',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Image.asset('assets/wechat.png', width: 25),
            ),
            GestureDetector(
              onTap: () {
                launchUrlString(
                  'https://ai.aicode.cc/social/x',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Image.asset('assets/x.png', width: 25),
            ),
            GestureDetector(
              onTap: () {
                launchUrlString(
                  'https://ai.aicode.cc/social/xiaohongshu',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Image.asset('assets/xiaohongshu.png', width: 25),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
