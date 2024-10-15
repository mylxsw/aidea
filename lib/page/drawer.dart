import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/account_quota_card.dart';
import 'package:askaide/page/component/icon_box.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/repo/api/user.dart';
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
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DrawerHeader(
                      padding: PlatformTool.isMacOS()
                          ? const EdgeInsets.only(top: kToolbarHeight)
                          : const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: CachedNetworkImageProviderEnhanced(
                            "https://ssl.aicode.cc/ai-server/assets/quota-card-bg.webp-thumb1000",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                                context
                                    .read<AccountBloc>()
                                    .add(AccountLoadEvent(cache: false));
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconBox(
                          icon: const Icon(Icons.group_outlined),
                          title: Text(AppLocale.homeTitle.getString(context)),
                          onTap: () {
                            context.push('/characters');
                          },
                        ),
                        IconBox(
                          icon: const Icon(Icons.auto_awesome_outlined),
                          title: Text(AppLocale.discover.getString(context)),
                          onTap: () {
                            context.push('/creative-gallery');
                          },
                        ),
                        IconBox(
                          icon: const Icon(Icons.palette_outlined),
                          title:
                              Text(AppLocale.creativeIsland.getString(context)),
                          onTap: () {
                            context.push('/creative-draw');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(AppLocale.histories.getString(context)),
                      onTap: () {
                        context.push('/chat-chat/history').whenComplete(() {
                          context
                              .read<ChatChatBloc>()
                              .add(ChatChatLoadRecentHistories());
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('设置'),
                      onTap: () {
                        context.push('/setting');
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 70,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      launchUrlString(
                        'https://weibo.com/code404',
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('关注我们：'),
                        const SizedBox(width: 10),
                        Image.asset('assets/weibo.png', width: 25),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      launchUrlString(
                        'https://ai.aicode.cc/social/github',
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('本项目开源，欢迎贡献：'),
                        const SizedBox(width: 10),
                        Image.asset('assets/github.png', width: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
