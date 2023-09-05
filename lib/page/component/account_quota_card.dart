import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/coin.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountQuotaCard extends StatelessWidget {
  final UserInfo userInfo;
  final VoidCallback? onPaymentReturn;
  const AccountQuotaCard(
      {super.key, required this.userInfo, this.onPaymentReturn});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: userInfo.control.userCardBg != null
            ? DecorationImage(
                // opacity: 0.83,
                image: CachedNetworkImageProviderEnhanced(
                    userInfo.control.userCardBg!),
                fit: BoxFit.cover,
              )
            : null,
        gradient: userInfo.control.userCardBg == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 90, 218, 196),
                  // Color.fromARGB(255, 230, 153, 38),
                  Color.fromARGB(255, 242, 7, 213),
                ],
                transform: GradientRotation(0.5),
              )
            : null,
      ),
      height: 140,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.usage.getString(context),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        launchUrl(
                          Uri.parse('https://ai.aicode.cc/zhihuiguo.html'),
                        );
                      },
                      child: const Icon(
                        Icons.help,
                        size: 16,
                        color: Color.fromARGB(129, 220, 220, 220),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Coin(count: userInfo.quota.quotaRemain()),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        context.push('/quota-usage-statistics');
                      },
                      child: Text(
                        AppLocale.coinsUsage.getString(context),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(129, 220, 220, 220),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            EnhancedButton(
              onPressed: () {
                // if (PlatformTool.isWeb() || PlatformTool.isMacOS()) {
                //   showBeautyDialog(
                //     context,
                //     type: QuickAlertType.info,
                //     text: 'Web、桌面端购买功能暂未推出，敬请期待',
                //   );
                //   return;
                // }

                context.push('/payment').whenComplete(() {
                  if (onPaymentReturn != null) {
                    onPaymentReturn!();
                  }
                });
              },
              title: AppLocale.buy.getString(context),
              backgroundColor: customColors.linkColor,
              width: 70,
              height: 35,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}
