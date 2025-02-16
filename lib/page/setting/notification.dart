import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/data/notification_datasource.dart';
import 'package:askaide/repo/api/notification.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';

class NotificationScreen extends StatefulWidget {
  final SettingRepository setting;
  const NotificationScreen({super.key, required this.setting});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationDatasource datasource = NotificationDatasource();

  @override
  void dispose() {
    datasource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocale.notification.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          toolbarHeight: CustomSize.toolbarHeight,
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          backgroundColor: customColors.backgroundColor,
          enabled: false,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: RefreshIndicator(
              color: customColors.linkColor,
              displacement: 20,
              onRefresh: () {
                return datasource.refresh();
              },
              child: LoadingMoreList(
                ListConfig<NotifyMessage>(
                  itemBuilder: (context, item, index) {
                    return NotifyMessageItem(
                      message: item,
                      customColors: customColors,
                      onTap: () {
                        context
                            .push(Uri(path: '/article', queryParameters: {'id': item.articleId.toString()}).toString());
                      },
                    );
                  },
                  sourceList: datasource,
                  indicatorBuilder: (context, status) {
                    String msg = '';
                    switch (status) {
                      case IndicatorStatus.noMoreLoad:
                        msg = '';
                        break;
                      case IndicatorStatus.loadingMoreBusying:
                        msg = 'Loading...';
                        break;
                      case IndicatorStatus.error:
                        msg = 'Failed to load, please try again later.';
                        break;
                      case IndicatorStatus.empty:
                        msg = 'No data';
                        break;
                      default:
                        return const Center(child: LoadingIndicator());
                    }
                    return Container(
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        msg,
                        style: TextStyle(
                          color: customColors.weakTextColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotifyMessageItem extends StatelessWidget {
  const NotifyMessageItem({
    super.key,
    required this.message,
    required this.customColors,
    required this.onTap,
  });

  final NotifyMessage message;
  final CustomColors customColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: 'Details',
              borderRadius: CustomSize.borderRadiusAll,
              backgroundColor: Colors.green,
              icon: Icons.info_outline,
              onPressed: (_) {
                HapticFeedbackHelper.lightImpact();
                onTap();
              },
            ),
          ],
        ),
        child: Material(
          color: customColors.listTileBackgroundColor,
          borderRadius: CustomSize.borderRadius,
          child: InkWell(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: CustomSize.borderRadius),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      message.title.trim(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: customColors.weakTextColor,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    humanTime(message.createdAt),
                    style: TextStyle(
                      color: customColors.weakTextColor?.withAlpha(65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              dense: true,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  message.content.trim().replaceAll("\n", " "),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: customColors.weakTextColor?.withAlpha(150),
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              onTap: () {
                HapticFeedbackHelper.lightImpact();
                onTap();
              },
            ),
          ),
        ),
      ),
    );
  }
}
