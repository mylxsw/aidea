import 'package:askaide/helper/color.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/share.dart';
import 'package:askaide/repo/api/user.dart';
import 'package:flutter/material.dart';

class InviteCard extends StatelessWidget {
  final UserInfo userInfo;
  const InviteCard({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          // opacity: 0.83,
          image: CachedNetworkImageProviderEnhanced(userInfo
                  .control.inviteCardBg ??
              'https://ssl.aicode.cc/ai-server/assets/invite-card-bg.webp-thumb1000'),
          fit: BoxFit.cover,
        ),
        // gradient: const LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     Color.fromARGB(255, 255, 255, 255),
        //     // Color.fromARGB(255, 230, 153, 38),
        //     Color.fromARGB(255, 250, 213, 246),
        //   ],
        //   transform: GradientRotation(0.5),
        // ),
      ),
      height: 150,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '邀新有礼',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: userInfo.control.inviteCardColor != null
                          ? stringToColor(userInfo.control.inviteCardColor!)
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userInfo.control.inviteCardSlogan ?? '邀请好友注册，双方都可获得奖励',
                    strutStyle: const StrutStyle(height: 1.3),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 13,
                      color: userInfo.control.inviteCardColor != null
                          ? stringToColor(userInfo.control.inviteCardColor!)
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            EnhancedButton(
              title: '立即邀请',
              fontSize: 14,
              height: 35,
              width: 80,
              backgroundColor: const Color.fromARGB(255, 230, 173, 58),
              onPressed: () {
                shareTo(
                  context,
                  content: userInfo.control.inviteMessage ??
                      '邀请码 ${userInfo.user.inviteCode}',
                  title: '邀请码分享',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
