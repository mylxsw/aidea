import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';

class QuotaUsageDetailScreen extends StatefulWidget {
  final SettingRepository setting;
  final String date;

  const QuotaUsageDetailScreen({
    super.key,
    required this.setting,
    required this.date,
  });

  @override
  State<QuotaUsageDetailScreen> createState() => _QuotaUsageDetailScreenState();
}

class _QuotaUsageDetailScreenState extends State<QuotaUsageDetailScreen> {
  List<QuotaUsageDetailInDay> usages = [];
  bool loaded = false;

  @override
  void initState() {
    APIServer().quotaUsedDetails(date: widget.date).then((value) {
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
            widget.date,
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
            child: _buildQuotaUsagePage(context, customColors),
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

    final usageGt0 = usages.where((e) => e.used > 0).toList();
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
                    color: customColors.listTileBackgroundColor,
                    borderRadius: CustomSize.borderRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.createdAt, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text('使用 ${item.type} 消耗 ${item.used} 个智慧果'),
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
