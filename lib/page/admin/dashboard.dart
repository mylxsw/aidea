import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

class AdminDashboardPage extends StatefulWidget {
  final SettingRepository setting;
  const AdminDashboardPage({super.key, required this.setting});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'Dashboard',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: SettingsList(
                platform: DevicePlatform.iOS,
                lightTheme: const SettingsThemeData(
                  settingsListBackground: Colors.transparent,
                  settingsSectionBackground: Color.fromARGB(255, 255, 255, 255),
                ),
                darkTheme: const SettingsThemeData(
                  settingsListBackground: Colors.transparent,
                  settingsSectionBackground: Color.fromARGB(255, 44, 44, 46),
                  titleTextColor: Color.fromARGB(255, 239, 239, 239),
                ),
                sections: [
                  SettingsSection(
                    title: const Text('使用记录'),
                    tiles: [
                      SettingsTile(
                        title: const Text('创作岛历史记录'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/creative-island/models');
                        },
                      ),
                      SettingsTile(
                        title: const Text('普通聊天历史记录'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/admin/recently-messages');
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('用户 & 收入'),
                    tiles: [
                      SettingsTile(
                        title: const Text('用户管理'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/admin/users');
                        },
                      ),
                      SettingsTile(
                        title: const Text('支付订单历史'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/admin/payment/histories');
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('模型管理'),
                    tiles: [
                      SettingsTile(
                        title: const Text('渠道'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/admin/channels');
                        },
                      ),
                      SettingsTile(
                        title: const Text('大语言模型'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/admin/models');
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('系统设置'),
                    tiles: [
                      SettingsTile(
                        title: const Text('更新配置缓存'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          openConfirmDialog(
                            context,
                            '该操作将重新加载全部系统配置，确定继续？',
                            () {
                              APIServer().adminSettingsReload().then((value) {
                                showSuccessMessage('更新成功');
                              }).onError((error, stackTrace) {
                                showErrorMessageEnhanced(context, error!);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
                contentPadding: const EdgeInsets.all(0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
