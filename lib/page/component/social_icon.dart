import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SocialItem {
  final String image;
  final String name;
  final Function? onTap;

  const SocialItem({
    required this.image,
    required this.name,
    required this.onTap,
  });
}

class SocialIconGroup extends StatelessWidget {
  final bool isSettingTiles;

  final List<SocialItem> items = [
    SocialItem(
      image: 'assets/app-256-transparent.png',
      name: '官方网站',
      onTap: () {
        launchUrlString(
          'https://ai.aicode.cc/social/home',
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    SocialItem(
      image: 'assets/weibo.png',
      name: '新浪微博',
      onTap: () {
        launchUrlString(
          'https://ai.aicode.cc/social/weibo',
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    SocialItem(
      image: 'assets/wechat.png',
      name: '微信公众号',
      onTap: () {
        launchUrlString(
          'https://ai.aicode.cc/social/wechat-platform',
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    SocialItem(
      image: 'assets/x.png',
      name: 'Twitter(X)',
      onTap: () {
        launchUrlString(
          'https://ai.aicode.cc/social/x',
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    SocialItem(
      image: 'assets/github.png',
      name: 'Github',
      onTap: () {
        launchUrlString(
          'https://ai.aicode.cc/social/github',
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    SocialItem(
      image: 'assets/xiaohongshu.png',
      name: '小红书',
      onTap: () {
        launchUrlString(
          'https://ai.aicode.cc/social/xiaohongshu',
          mode: LaunchMode.externalApplication,
        );
      },
    ),
  ];

  SocialIconGroup({
    super.key,
    this.isSettingTiles = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSettingTiles) {
      return SettingsSection(
        title: const Text('关注我们'),
        tiles: items
            .map(
              (e) => SettingsTile(
                title: Row(children: [
                  Image.asset(e.image, width: 20, height: 20),
                  const SizedBox(width: 10),
                  Text(e.name),
                ]),
                trailing: Icon(
                  CupertinoIcons.chevron_forward,
                  size: MediaQuery.of(context).textScaleFactor * 18,
                  color: Colors.grey,
                ),
                onPressed: (context) {
                  e.onTap?.call();
                },
              ),
            )
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items
          .map((e) => SocialIcon(image: e.image, name: e.name, onTap: e.onTap))
          .toList(),
    );
  }
}

class SocialIcon extends StatelessWidget {
  final String image;
  final String name;
  final Function? onTap;
  const SocialIcon({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Column(
        children: [
          Image.asset(image, width: 25),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(fontSize: 8),
          )
        ],
      ),
    );
  }
}
