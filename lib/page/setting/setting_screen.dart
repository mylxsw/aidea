import 'dart:io';

import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/cache.dart';
import 'package:askaide/helper/env.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/http.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/setting/account_security.dart';
import 'package:askaide/page/component/account_quota_card.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/invite_card.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/component/social_icon.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/theme/theme.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingScreen extends StatefulWidget {
  final SettingRepository settings;
  const SettingScreen({super.key, required this.settings});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    context.read<AccountBloc>().add(AccountLoadEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return BackgroundContainer(
      setting: widget.settings,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SliverComponent(
          title: Text(
            AppLocale.me.getString(context),
            style: TextStyle(
              fontSize: CustomSize.appBarTitleSize,
              color: customColors.backgroundInvertedColor,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.push('/notifications');
              },
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (_, state) {
              return buildSettingsList([
                // 智慧果信息、充值入口
                if (state is AccountLoaded && state.user != null)
                  _buildAccountQuotaCard(context, state),

                // 账号信息
                SettingsSection(
                  title: Text(AppLocale.accountInfo.getString(context)),
                  tiles: _buildAccountSetting(state, customColors),
                ),

                // 邀请卡片
                if (state is AccountLoaded && state.user != null)
                  _buildInviteCard(context, state),

                // 自定义设置
                SettingsSection(
                  title: Text(AppLocale.custom.getString(context)),
                  tiles: [
                    // 主题设置
                    _buildCommonThemeSetting(customColors),
                    // 语言设置
                    _buildCommonLanguageSetting(),
                    // 常用模型
                    if (Ability().enableAPIServer())
                      _buildCustomHomeModelsSetting(customColors),
                    // OpenAI 自定义配置
                    if (Ability().enableOpenAI)
                      _buildOpenAISelfHostedSetting(customColors),
                    // 用户 API Keys 配置
                    if (Ability().supportAPIKeys)
                      _buildUserAPIKeySetting(customColors),
                  ],
                ),

                // 系统信息
                SettingsSection(
                  title: Text(AppLocale.systemInfo.getString(context)),
                  tiles: [
                    // 服务状态
                    if (Ability().serviceStatusPage != '')
                      SettingsTile(
                        title: const Text('服务状态'),
                        trailing: Icon(
                          CupertinoIcons.chevron_forward,
                          size: MediaQuery.of(context).textScaleFactor * 18,
                          color: Colors.grey,
                        ),
                        onPressed: (_) {
                          launchUrlString(Ability().serviceStatusPage);
                        },
                      ),
                    // 清空缓存
                    SettingsTile(
                      title: Text(AppLocale.clearCache.getString(context)),
                      trailing: Icon(
                        CupertinoIcons.refresh,
                        size: MediaQuery.of(context).textScaleFactor * 18,
                        color: Colors.grey,
                      ),
                      onPressed: (_) {
                        openConfirmDialog(
                          context,
                          AppLocale.confirmClearCache.getString(context),
                          () async {
                            await Cache().clearAll();
                            await HttpClient.cacheManager.clearAll();
                            showSuccessMessage(
                              // ignore: use_build_context_synchronously
                              AppLocale.operateSuccess.getString(context),
                            );
                          },
                          danger: true,
                        );
                      },
                    ),
                    // 诊断
                    // SettingsTile(
                    //   title: Text(AppLocale.diagnostic.getString(context)),
                    //   trailing: Icon(
                    //     CupertinoIcons.chevron_forward,
                    //     size: MediaQuery.of(context).textScaleFactor * 18,
                    //     color: Colors.grey,
                    //   ),
                    //   onPressed: (context) {
                    //     context.push('/diagnosis');
                    //   },
                    // ),
                    // 检查更新
                    if (!PlatformTool.isIOS())
                      SettingsTile(
                        title: Text(AppLocale.updateCheck.getString(context)),
                        trailing: Icon(
                          CupertinoIcons.chevron_forward,
                          size: MediaQuery.of(context).textScaleFactor * 18,
                          color: Colors.grey,
                        ),
                        onPressed: (_) {
                          APIServer().versionCheck(cache: false).then((resp) {
                            if (resp.hasUpdate) {
                              showBeautyDialog(
                                context,
                                type: QuickAlertType.success,
                                text: resp.message,
                                confirmBtnText: '去更新',
                                onConfirmBtnTap: () {
                                  launchUrlString(
                                    resp.url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                cancelBtnText: '暂不更新',
                                showCancelBtn: true,
                              );
                            } else {
                              showSuccessMessage(
                                  AppLocale.latestVersion.getString(context));
                            }
                          });
                        },
                      ),
                    // 用户协议
                    SettingsTile(
                      title: Text(AppLocale.userTerms.getString(context)),
                      trailing: Icon(
                        CupertinoIcons.chevron_forward,
                        size: MediaQuery.of(context).textScaleFactor * 18,
                        color: Colors.grey,
                      ),
                      onPressed: (_) {
                        launchUrl(
                            Uri.parse('https://ai.aicode.cc/terms-user.html'));
                      },
                    ),
                    // 隐私政策
                    SettingsTile(
                      title: Text(AppLocale.privacyPolicy.getString(context)),
                      trailing: Icon(
                        CupertinoIcons.chevron_forward,
                        size: MediaQuery.of(context).textScaleFactor * 18,
                        color: Colors.grey,
                      ),
                      onPressed: (_) {
                        launchUrl(Uri.parse(
                            'https://ai.aicode.cc/privacy-policy.html'));
                      },
                    ),

                    // 关于
                    SettingsTile(
                      title: Text(AppLocale.about.getString(context)),
                      trailing: Icon(
                        CupertinoIcons.chevron_forward,
                        size: MediaQuery.of(context).textScaleFactor * 18,
                        color: Colors.grey,
                      ),
                      onPressed: (_) {
                        showAboutDialog(
                          context: context,
                          applicationName: 'AIdea',
                          applicationIcon:
                              Image.asset('assets/app.png', width: 40),
                          applicationVersion: clientVersion,
                          children: [
                            Text(AppLocale.aIdeaApp.getString(context)),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                if (state is AccountLoaded &&
                    state.error == null &&
                    state.user != null &&
                    state.user!.control.withLab)
                  SettingsSection(
                    title: const Text('实验室'),
                    tiles: [
                      SettingsTile(
                        title: const Text('模型 Gallery'),
                        trailing: Icon(
                          CupertinoIcons.chevron_forward,
                          size: MediaQuery.of(context).textScaleFactor * 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/creative-island/models');
                        },
                      ),
                      SettingsTile(
                        title: const Text('画板'),
                        trailing: Icon(
                          CupertinoIcons.chevron_forward,
                          size: MediaQuery.of(context).textScaleFactor * 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/lab/draw-board');
                        },
                      ),

                      // SettingsTile(
                      //   title: const Text('用户中心'),
                      //   trailing: Icon(
                      //     CupertinoIcons.chevron_forward,
                      //     size: MediaQuery.of(context).textScaleFactor * 18,
                      //     color: Colors.grey,
                      //   ),
                      //   onPressed: (context) {
                      //     context.push('/lab/user-center');
                      //   },
                      // ),

                      // 自定义服务器
                      _buildServerSelfHostedSetting(customColors),
                    ],
                  ),
                // 社交媒体图标
                _buildSocialIcons(context),
              ]);
            },
          ),
        ),
      ),
    );
  }

  CustomSettingsSection _buildAccountQuotaCard(
      BuildContext context, AccountLoaded state) {
    if (state.user == null) {
      return CustomSettingsSection(
        child: Container(),
      );
    }
    return CustomSettingsSection(
      child: AccountQuotaCard(
        userInfo: state.user!,
        onPaymentReturn: () {
          context.read<AccountBloc>().add(AccountLoadEvent(cache: false));
        },
      ),
    );
  }

  CustomSettingsSection _buildInviteCard(
      BuildContext context, AccountLoaded state) {
    if (state.error != null || !state.user!.showInviteMessage) {
      return CustomSettingsSection(
        child: Container(),
      );
    }

    return CustomSettingsSection(
      child: InviteCard(userInfo: state.user!),
    );
  }

  SettingsTile _buildCommonLanguageSetting() {
    return SettingsTile(
      title: Text(AppLocale.language.getString(context)),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        final current = widget.settings.stringDefault(settingLanguage, 'zh');
        openModalBottomSheet(
          context,
          (context) {
            return ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.followSystem.getString(context)),
                      current == ''
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingLanguage, '');
                    FlutterLocalization.instance
                        .translate(resolveSystemLanguage(Platform.localeName));
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('简体中文'),
                      current == 'zh-CHS'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingLanguage, 'zh-CHS');
                    FlutterLocalization.instance.translate('zh-CHS');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('English'),
                      current == 'en'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingLanguage, 'en');
                    FlutterLocalization.instance.translate('en');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ],
            );
          },
          heightFactor: 0.3,
        );
      },
    );
  }

  Future<List<SelectorItem<String>>> _defaultServerList() async {
    return [
      SelectorItem(const Text('官方正式服务器'), apiServerURL),
      SelectorItem(const Text('本地开发机'), 'http://localhost:8080'),
    ];
  }

  List<SettingsTile> _buildAccountSetting(
      AccountState state, CustomColors customColors) {
    if (state is AccountLoaded) {
      if (state.error != null && state.user == null) {
        return [
          SettingsTile(
            title: Text(resolveError(context, state.error!)),
            trailing: Icon(
              CupertinoIcons.chevron_forward,
              size: MediaQuery.of(context).textScaleFactor * 18,
              color: Colors.grey,
            ),
            onPressed: (_) {
              context.read<AccountBloc>().add(AccountSignOutEvent());
              context.go('/login');
            },
          ),
        ];
      }
      return [
        SettingsTile(
          title: Text(
            state.user!.user.displayName(),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(children: [
            Text(
              AppLocale.accountSettings.getString(context),
              style: TextStyle(
                color: customColors.weakTextColor?.withAlpha(200),
                fontSize: 13,
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: MediaQuery.of(context).textScaleFactor * 18,
              color: Colors.grey,
            ),
          ]),
          onPressed: (context) {
            context.push('/setting/account-security');
          },
        ),
        SettingsTile(
          title: const Text('免费畅享额度'),
          trailing: Icon(
            CupertinoIcons.chevron_forward,
            size: MediaQuery.of(context).textScaleFactor * 18,
            color: Colors.grey,
          ),
          onPressed: (context) {
            context.push('/free-statistics');
          },
        ),
      ];
    } else if (state is AccountLoading) {
      return [
        SettingsTile(
          title: const Text('Loading...'),
        ),
      ];
    }

    return [
      SettingsTile(
        leading: const Icon(Icons.account_circle),
        title: Text(AppLocale.signIn.getString(context)),
        trailing: Icon(
          CupertinoIcons.chevron_forward,
          size: MediaQuery.of(context).textScaleFactor * 18,
          color: Colors.grey,
        ),
        onPressed: (_) {
          context.go('/login');
        },
      ),
    ];
  }

  SettingsTile _buildCommonThemeSetting(CustomColors customColors) {
    return SettingsTile.navigation(
      title: Text(AppLocale.themeMode.getString(context)),
      onPressed: (context) {
        final current =
            widget.settings.stringDefault(settingThemeMode, 'system');

        openModalBottomSheet(
          context,
          (context) {
            return ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.followSystem.getString(context)),
                      current == 'system'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingThemeMode, 'system');
                    AppTheme.instance.mode =
                        AppTheme.themeModeFormString('system');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.lightThemeMode.getString(context)),
                      current == 'light'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingThemeMode, 'light');
                    AppTheme.instance.mode =
                        AppTheme.themeModeFormString('light');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.darkThemeMode.getString(context)),
                      current == 'dark'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingThemeMode, 'dark');
                    AppTheme.instance.mode =
                        AppTheme.themeModeFormString('dark');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ],
            );
          },
          heightFactor: 0.3,
        );
      },
    );
  }

  SettingsTile _buildOpenAISelfHostedSetting(CustomColors customColors) {
    return SettingsTile.navigation(
      title: const Text('OpenAI'),
      value: Text(
        widget.settings.boolDefault(settingOpenAISelfHosted, false)
            ? AppLocale.enable.getString(context)
            : AppLocale.disable.getString(context),
        style: TextStyle(
          color: customColors.weakTextColor?.withAlpha(200),
          fontSize: 13,
        ),
      ),
      onPressed: (context) {
        context.push('/setting/openai-custom?source=setting');
      },
    );
  }

  /// 常用模型
  SettingsTile _buildCustomHomeModelsSetting(CustomColors customColors) {
    return SettingsTile.navigation(
      title: Text(AppLocale.customHomeModels.getString(context)),
      onPressed: (context) {
        context.push('/setting/custom-home-models');
      },
    );
  }

  /// 用户 API Key 配置
  SettingsTile _buildUserAPIKeySetting(CustomColors customColors) {
    return SettingsTile.navigation(
      title: Text(AppLocale.userApiKeys.getString(context)),
      onPressed: (context) {
        context.push('/setting/user-api-keys');
      },
    );
  }

  SettingsTile _buildServerSelfHostedSetting(CustomColors customColors) {
    return SettingsTile(
      title: const Text('自定义服务器'),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        openTextFieldDialog(
          context,
          title: '服务器地址',
          defaultValue:
              widget.settings.stringDefault(settingServerURL, apiServerURL),
          withSuffixIcon: true,
          enableSearch: false,
          futureDataSources: _defaultServerList(),
          onSubmit: (value) {
            widget.settings.set(settingServerURL, value.trim()).then((value) {
              openConfirmDialog(
                context,
                '设置成功，应用重启后生效',
                () {
                  try {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  } catch (e) {
                    Logger.instance.e(e);
                    showErrorMessage('应用重启失败，请手动重启');
                  }
                },
                danger: true,
                confirmText: '立即重启',
                cancelText: '稍后我自己重启',
              );
            });
            return true;
          },
        );
      },
    );
  }

  CustomSettingsSection _buildSocialIcons(BuildContext context) {
    return CustomSettingsSection(
      child: SocialIconGroup(
        isSettingTiles: true,
      ),
    );
  }
}
