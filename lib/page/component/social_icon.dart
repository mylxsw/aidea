import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SocialIconGroup extends StatelessWidget {
  const SocialIconGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SocialIcon(
          image: 'assets/weibo.png',
          name: '官方微博',
          onTap: () {
            launchUrlString(
              'https://weibo.com/code404',
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        SocialIcon(
          image: 'assets/wechat.png',
          name: '微信公众号',
          onTap: () {
            launchUrlString(
              'https://mp.weixin.qq.com/s/4CHh_rKxBqi-npDEnmLWmA',
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        SocialIcon(
          image: 'assets/x.png',
          name: 'Twitter(X)',
          onTap: () {
            launchUrlString(
              'https://twitter.com/mylxsw',
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        SocialIcon(
          image: 'assets/github.png',
          name: 'Github',
          onTap: () {
            launchUrlString(
              'http://github.com/mylxsw/aidea',
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        SocialIcon(
          image: 'assets/xiaohongshu.png',
          name: '小红书',
          onTap: () {
            launchUrlString(
              'https://www.xiaohongshu.com/user/profile/63c65968000000002702abcd?xhsshare=CopyLink&appuid=63c65968000000002702abcd&apptime=1696648278',
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ],
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
