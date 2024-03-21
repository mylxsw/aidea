import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
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
    // final customColors = Theme.of(context).extension<CustomColors>()!;

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
        backgroundColor: Colors.transparent,
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
                  settingsSectionBackground: Color.fromARGB(255, 27, 27, 27),
                  titleTextColor: Color.fromARGB(255, 239, 239, 239),
                ),
                sections: [
                  SettingsSection(
                    title: const Text('创作岛'),
                    tiles: [
                      SettingsTile(
                        title: const Text('Gallery'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/creative-island/models');
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('用户管理'),
                    tiles: [
                      SettingsTile(
                        title: const Text('用户列表'),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/admin/users');
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text('系统设置'),
                    tiles: [
                      SettingsTile(
                        title: const Text('渠道管理'),
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
                        title: const Text('大语言模型管理'),
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
