import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
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

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
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
        body: BackgroundContainer(
          setting: widget.setting,
          backgroundColor: customColors.backgroundColor,
          enabled: false,
          child: Column(
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
                      title: const Text('Usage'),
                      tiles: [
                        SettingsTile(
                          title: const Text('Creation Island History'),
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
                          title: const Text('Chat History'),
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
                      title: const Text('Users & Revenue'),
                      tiles: [
                        SettingsTile(
                          title: const Text('User Management'),
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
                          title: const Text('Payment Order History'),
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
                      title: const Text('Model management'),
                      tiles: [
                        SettingsTile(
                          title: const Text('Channel'),
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
                          title: const Text('Large Language Model'),
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
                      title: const Text('System settings'),
                      tiles: [
                        SettingsTile(
                          title: const Text('Refresh Config Cache'),
                          trailing: const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: (context) {
                            openConfirmDialog(
                              context,
                              'Reload all system configurations.\n Are you sure you want to proceed?',
                              () {
                                APIServer().adminSettingsReload().then((value) {
                                  showSuccessMessage('Update successful');
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
      ),
    );
  }
}
