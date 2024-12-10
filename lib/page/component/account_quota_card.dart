import 'package:askaide/helper/ability.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/credit.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountQuotaCard extends StatelessWidget {
  final UserInfo? userInfo;
  final VoidCallback? onPaymentReturn;
  final bool noBorder;
  const AccountQuotaCard({super.key, this.userInfo, this.onPaymentReturn, this.noBorder = false});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      margin: noBorder ? null : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      height: 120,
      child: Container(
        padding: noBorder
            ? const EdgeInsets.only(
                top: 5,
                left: 20,
                right: 20,
                bottom: 0,
              )
            : const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (userInfo != null)
                      Credit(
                        count: userInfo!.quota.quotaRemain(),
                      )
                    else
                      const Text('-'),
                    const SizedBox(width: 5),
                    if (userInfo != null)
                      InkWell(
                        onTap: () {
                          context.push('/quota-usage-statistics');
                        },
                        child: Text(
                          AppLocale.creditsUsage.getString(context),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(129, 220, 220, 220),
                          ),
                        ),
                      ),
                  ],
                ),
                if (Ability().enablePayment)
                  EnhancedButton(
                    onPressed: () {
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
          ],
        ),
      ),
    );
  }
}
