import 'package:askaide/helper/ability.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/credit.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/user.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
            ? const EdgeInsets.only()
            : const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
        child: userInfo != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocale.usage.getString(context),
                              style: TextStyle(
                                fontSize: 16,
                                color: customColors.backgroundInvertedColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                launchUrl(
                                  Uri.parse('https://ai.aicode.cc/zhihuiguo.html'),
                                );
                              },
                              child: Icon(
                                Icons.help,
                                size: 12,
                                color: customColors.weakTextColor?.withAlpha(150),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                context.push('/quota-usage-statistics');
                              },
                              borderRadius: CustomSize.borderRadiusAll,
                              child: Credit(
                                count: userInfo!.quota.quotaRemain(),
                                color: customColors.backgroundInvertedColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 5),
                            if (Ability().enablePayment)
                              TextButton(
                                onPressed: () {
                                  context.push('/payment').whenComplete(() {
                                    if (onPaymentReturn != null) {
                                      onPaymentReturn!();
                                    }
                                  });
                                },
                                child: Text(
                                  AppLocale.buy.getString(context),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    alignment: Alignment.centerLeft,
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_circle),
                        const SizedBox(width: 5),
                        AutoSizeText(AppLocale.signInAccount.getString(context), maxLines: 1),
                      ],
                    ),
                    onPressed: () {
                      context.go('/login');
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
      ),
    );
  }
}
