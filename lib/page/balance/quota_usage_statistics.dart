import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class QuotaUsageStatisticsScreen extends StatefulWidget {
  final SettingRepository setting;
  const QuotaUsageStatisticsScreen({super.key, required this.setting});

  @override
  State<QuotaUsageStatisticsScreen> createState() => _QuotaUsageStatisticsScreenState();
}

class _QuotaUsageStatisticsScreenState extends State<QuotaUsageStatisticsScreen> {
  List<QuotaUsageInDay> usages = [];
  bool loaded = false;

  @override
  void initState() {
    APIServer().quotaUsedStatistics().then((value) {
      setState(() {
        usages = value;
        loaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: Text(
            AppLocale.creditsUsage.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MessageBox(
                  message: AppLocale.creditUsageTips.getString(context),
                  type: MessageBoxType.info,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildQuotaUsagePage(context, customColors),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaUsagePage(
    BuildContext context,
    CustomColors customColors,
  ) {
    if (!loaded) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    final usageGt0 = usages.where((e) => e.used > 0 || e.used == -1).toList();
    if (usageGt0.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'No records yet',
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var item in usageGt0)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customColors.listTileBackgroundColor,
                    borderRadius: CustomSize.borderRadius,
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/quota-usage-daily-details?date=${item.date}');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.used == -1)
                          Text(AppLocale.unbilled.getString(context))
                        else
                          Text('${item.used > 0 ? "-" : ""}${AppLocale.creditUnit.getString(context)}${item.used}'),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
