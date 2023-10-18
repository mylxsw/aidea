import 'package:askaide/helper/helper.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:askaide/repo/model/misc.dart';

class QuotaUsageStatisticsScreen extends StatefulWidget {
  final SettingRepository setting;
  const QuotaUsageStatisticsScreen({super.key, required this.setting});

  @override
  State<QuotaUsageStatisticsScreen> createState() =>
      _QuotaUsageStatisticsScreenState();
}

class _QuotaUsageStatisticsScreenState
    extends State<QuotaUsageStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: const Text(
          '使用明细',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder(
            future: APIServer().quotaUsedStatistics(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        resolveError(context, snapshot.error!),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  const MessageBox(
                    message: '使用明细将在次日更新，显示近 30 天的使用量。',
                    type: MessageBoxType.info,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildQuotaUsagePage(
                        context, snapshot.data!, customColors),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaUsagePage(
    BuildContext context,
    List<QuotaUsageInDay> usages,
    CustomColors customColors,
  ) {
    final usageGt0 = usages.where((e) => e.used > 0).toList();
    if (usageGt0.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.error_outline,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              '暂无使用记录',
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
                    color: customColors.paymentItemBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.date),
                      Row(
                        children: [
                          if (item.used > 0) const Text('-'),
                          Text(
                            '${item.used}',
                            style: TextStyle(
                              fontWeight:
                                  item.used > 0 ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
