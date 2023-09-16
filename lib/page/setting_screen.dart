import 'dart:io';

import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/http.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/account_security.dart';
import 'package:askaide/page/component/account_quota_card.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/invite_card.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/page/theme/theme.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (_, state) {
              return buildSettingsList([
                if (state is AccountLoaded && state.user != null)
                  _buildAccountQuotaCard(context, state),

                SettingsSection(
                  title: Text(AppLocale.accountInfo.getString(context)),
                  tiles: _buildAccountSetting(state, customColors),
                ),

                if (state is AccountLoaded && state.user != null)
                  _buildInviteCard(context, state),

                SettingsSection(
                  title: Text(AppLocale.custom.getString(context)),
                  tiles: [
                    _buildCommonThemeSetting(customColors),
                    _buildCommonLanguageSetting(),
                    if (Ability().enableOpenAI)
                      _buildOpenAISelfHostedSetting(customColors),
                  ],
                ),

                // 系统信息
                SettingsSection(
                  title: Text(AppLocale.systemInfo.getString(context)),
                  tiles: [
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
                          () {
                            HttpClient.cacheManager.clearAll().then((value) {
                              showSuccessMessage(
                                  AppLocale.operateSuccess.getString(context));
                            });
                          },
                          danger: true,
                        );
                      },
                    ),
                    SettingsTile(
                      title: Text(AppLocale.diagnostic.getString(context)),
                      trailing: Icon(
                        CupertinoIcons.chevron_forward,
                        size: MediaQuery.of(context).textScaleFactor * 18,
                        color: Colors.grey,
                      ),
                      onPressed: (context) {
                        context.push('/diagnosis');
                      },
                    ),
                    if (!PlatformTool.isIOS())
                      SettingsTile(
                        title: Text(AppLocale.updateCheck.getString(context)),
                        trailing: Icon(
                          CupertinoIcons.chevron_forward,
                          size: MediaQuery.of(context).textScaleFactor * 18,
                          color: Colors.grey,
                        ),
                        onPressed: (_) {
                          APIServer().versionCheck().then((resp) {
                            if (resp.hasUpdate) {
                              showBeautyDialog(
                                context,
                                type: QuickAlertType.success,
                                text: resp.message,
                                confirmBtnText: '去更新',
                                onConfirmBtnTap: () {
                                  launchUrlString(resp.url);
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
                          applicationLegalese: 'mylxsw©2023 aicode.cc',
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child:
                                  Text(AppLocale.aIdeaApp.getString(context)),
                            ),
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
                      SettingsTile(
                        title: const Text('用户中心'),
                        trailing: Icon(
                          CupertinoIcons.chevron_forward,
                          size: MediaQuery.of(context).textScaleFactor * 18,
                          color: Colors.grey,
                        ),
                        onPressed: (context) {
                          context.push('/lab/user-center');
                        },
                      ),
                    ],
                  ),
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

  // Future<List<SelectorItem<String>>> _futureDataSources(
  //     String modelType) async {
  //   final servers = await APIServer().proxyServers(modelType);
  //   return servers
  //       .map((e) => SelectorItem(
  //           Text(
  //             e,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //           e))
  //       .toList();
  // }

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
          color: customColors.weakTextColor,
          fontSize: 13,
        ),
      ),
      onPressed: (context) {
        context.push('/setting/openai-custom?source=setting');
      },
    );
  }

  SettingsTile _buildDeepAISelfHostedSetting(CustomColors customColors) {
    return SettingsTile.switchTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocale.custom.getString(context)),
          Text(
            '启用后，将使用您配置的 DeepAI 服务',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      activeSwitchColor: customColors.linkColor,
      initialValue: widget.settings.boolDefault(settingDeepAISelfHosted, false),
      onToggle: (value) {
        widget.settings.set(settingDeepAISelfHosted, value ? 'true' : 'false');
        setState(() {});
      },
    );
  }

  SettingsTile _buildStabilityAISelfHostedSetting(CustomColors customColors) {
    return SettingsTile.switchTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocale.custom.getString(context)),
          Text(
            '启用后，将使用您配置的 StabilityAI 服务',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      activeSwitchColor: customColors.linkColor,
      initialValue:
          widget.settings.boolDefault(settingStabilityAISelfHosted, false),
      onToggle: (value) {
        widget.settings
            .set(settingStabilityAISelfHosted, value ? 'true' : 'false');
        setState(() {});
      },
    );
  }

  SettingsTile _buildImageManagerSelfHostedSetting() {
    return SettingsTile.switchTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocale.custom.getString(context)),
          Text(
            '启用后，上传文件将使用您配置的图床',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      initialValue:
          widget.settings.boolDefault(settingImageManagerSelfHosted, false),
      onToggle: (value) {
        widget.settings
            .set(settingImageManagerSelfHosted, value ? 'true' : 'false');
        setState(() {});
      },
    );
  }

  SettingsTile _buildCommonImglocKeySetting(CustomColors customColors) {
    return SettingsTile(
      title: const Text('Imgloc 图床'),
      description: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '使用 Imgloc 图床上传图片，需要先注册账号并获取密钥，地址 ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextSpan(
              text: 'https://imgloc.com',
              style: TextStyle(color: customColors.linkColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('https://imgloc.com'));
                },
            ),
          ],
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        openTextFieldDialog(
          context,
          title: 'Key',
          obscureText: true,
          defaultValue: widget.settings.stringDefault(settingImglocToken, ''),
          onSubmit: (value) {
            widget.settings.set(settingImglocToken, value.trim());
            return true;
          },
        );
      },
    );
  }

  SettingsTile _buildDeepAIAPIURLSetting() {
    return SettingsTile(
      title: const Text('API Server URL'),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        openTextFieldDialog(
          context,
          title: 'API Server URL',
          defaultValue: widget.settings
              .stringDefault(settingDeepAIURL, defaultDeepAIServerURL),
          // withSuffixIcon: true,
          enableSearch: false,
          // futureDataSources: _futureDataSources(modelTypeDeepAI),
          onSubmit: (value) {
            widget.settings.set(settingDeepAIURL, value.trim());
            return true;
          },
        );
      },
    );
  }

  SettingsTile _buildDeepAIAPIKeySetting() {
    return SettingsTile(
      title: const Text('API Key'),
      description: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: 'DeepAI secret API key: ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextSpan(
            text: 'https://deepai.org/dashboard/profile',
            style: Theme.of(context).textTheme.bodySmall,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse('https://deepai.org/dashboard/profile'));
              },
          ),
        ]),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        openTextFieldDialog(
          context,
          title: 'API key',
          obscureText: true,
          defaultValue:
              widget.settings.stringDefault(settingDeepAIAPIToken, ''),
          onSubmit: (value) {
            widget.settings.set(settingDeepAIAPIToken, value.trim());
            return true;
          },
        );
      },
    );
  }

  SettingsTile _buildStabilityAIAPIURLSetting() {
    return SettingsTile(
      title: const Text('API Server URL'),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        openTextFieldDialog(
          context,
          title: 'API Server URL',
          defaultValue: widget.settings
              .stringDefault(settingStabilityAIURL, defaultStabilityAIURL),
          // withSuffixIcon: true,
          enableSearch: false,
          // futureDataSources: _futureDataSources(modelTypeStabilityAI),
          onSubmit: (value) {
            widget.settings.set(settingStabilityAIURL, value.trim());
            return true;
          },
        );
      },
    );
  }

  SettingsTile _buildStabilityAIAPIKeySetting() {
    return SettingsTile(
      title: const Text('API Key'),
      description: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: 'StabilityAI secret API key: ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextSpan(
            text: 'https://beta.dreamstudio.ai/account',
            style: Theme.of(context).textTheme.bodySmall,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse('https://beta.dreamstudio.ai/account'));
              },
          ),
        ]),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        openTextFieldDialog(
          context,
          title: 'API key',
          obscureText: true,
          defaultValue:
              widget.settings.stringDefault(settingStabilityAIAPIToken, ''),
          onSubmit: (value) {
            widget.settings.set(settingStabilityAIAPIToken, value.trim());
            return true;
          },
        );
      },
    );
  }

  SettingsTile _buildStabilityAIOrganizationSetting() {
    return SettingsTile(
      title: const Text('Organization ID'),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      value: Text(
          widget.settings.stringDefault(settingStabilityAIOrganization, '')),
      onPressed: (_) {
        openTextFieldDialog(
          context,
          title: 'Organization ID',
          defaultValue:
              widget.settings.stringDefault(settingStabilityAIOrganization, ''),
          onSubmit: (value) {
            widget.settings.set(settingStabilityAIOrganization, value.trim());
            return true;
          },
        );
      },
    );
  }

  SettingsTile _buildBackgroundImageSetting() {
    return SettingsTile(
      title: Text(AppLocale.backgroundSetting.getString(context)),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: MediaQuery.of(context).textScaleFactor * 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        context.push('/setting/background-selector');
      },
    );
  }
}
