import 'dart:async';

import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/enhanced_popup_menu.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluwx/fluwx.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

class AccountSecurityScreen extends StatefulWidget {
  final SettingRepository settings;
  const AccountSecurityScreen({super.key, required this.settings});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  StreamSubscription<BaseWeChatResponse>? _weChatResponse;

  @override
  void dispose() {
    _weChatResponse?.cancel();
    super.dispose();
  }

  var wechatInstalled = false;

  @override
  void initState() {
    context.read<AccountBloc>().add(AccountLoadEvent());

    if (Ability().enableWechatSignin) {
      isWeChatInstalled.then((installed) {
        setState(() {
          wechatInstalled = installed;
        });

        if (!installed) {
          return;
        }

        _weChatResponse = weChatResponseEventHandler
            .distinct((a, b) => a == b)
            .listen((event) {
          if (event is WeChatAuthResponse) {
            if (event.errCode != 0) {
              showErrorMessage(event.errStr!);
              return;
            }

            if (event.code == null) {
              showErrorMessage(AppLocale.signInFailed.getString(context));
              return;
            }

            APIServer().bindWechat(code: event.code!).then((_) {
              context.read<AccountBloc>().add(AccountLoadEvent());
              showSuccessMessage('绑定成功');
            }).onError((error, stackTrace) {
              showErrorMessageEnhanced(context, error!);
            });
          }
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return BackgroundContainer(
      setting: widget.settings,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            '账号设置',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          actions: [
            EnhancedPopupMenu(
              items: [
                EnhancedPopupMenuItem(
                  title: '注销账号',
                  icon: Icons.delete_forever,
                  iconColor: Colors.red,
                  onTap: (ctx) {
                    context.push('/user/destroy');
                  },
                ),
              ],
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocConsumer<AccountBloc, AccountState>(
            listenWhen: (previous, current) => current is AccountLoaded,
            listener: (context, state) {
              if (state is AccountLoaded) {
                if (state.error != null) {
                  showErrorMessageEnhanced(context, state.error!);
                }
              }
            },
            buildWhen: (previous, current) => current is AccountLoaded,
            builder: (_, state) {
              if (state is AccountLoaded) {
                return buildSettingsList(
                  context,
                  [
                    SettingsSection(
                      title: const Text('基础信息'),
                      tiles: [
                        SettingsTile(
                          title: const Text('昵称'),
                          trailing: Row(
                            children: [
                              Text(
                                state.user!.user.name == null ||
                                        state.user!.user.name == ''
                                    ? '未设置'
                                    : state.user!.user.name!,
                                style: TextStyle(
                                  color: customColors.weakTextColor
                                      ?.withAlpha(200),
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_forward,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          onPressed: (context) {
                            openTextFieldDialog(
                              context,
                              title: '设置昵称',
                              hint: '请输入你的昵称',
                              maxLine: 1,
                              maxLength: 30,
                              defaultValue: state.user?.user.name,
                              onSubmit: (value) {
                                context
                                    .read<AccountBloc>()
                                    .add(AccountUpdateEvent(realname: value));
                                return true;
                              },
                            );
                          },
                        ),
                        SettingsTile(
                          title: const Text('手机号'),
                          trailing: Row(
                            children: [
                              Text(
                                state.user!.user.phone == null ||
                                        state.user!.user.phone == ''
                                    ? '绑定'
                                    : state.user!.user.phone!,
                                style: TextStyle(
                                  color: customColors.weakTextColor
                                      ?.withAlpha(200),
                                  fontSize: 13,
                                ),
                              ),
                              if (state.user!.user.phone == null ||
                                  state.user!.user.phone == '')
                                const SizedBox(width: 5),
                              if (state.user!.user.phone == null ||
                                  state.user!.user.phone == '')
                                const Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                          onPressed: (context) {
                            if (state.user!.user.phone == null ||
                                state.user!.user.phone == '') {
                              context
                                  .push('/bind-phone?is_signin=false')
                                  .then((value) => Logger.instance.d(value));
                            }
                          },
                        ),
                        if (Ability().enableWechatSignin && wechatInstalled)
                          SettingsTile(
                            title: const Text('微信账号'),
                            trailing: Row(
                              children: [
                                Text(
                                  state.user!.user.unionId == null ||
                                          state.user!.user.unionId == ''
                                      ? '绑定'
                                      : '已绑定',
                                  style: TextStyle(
                                    color: customColors.weakTextColor
                                        ?.withAlpha(200),
                                    fontSize: 13,
                                  ),
                                ),
                                if (state.user!.user.unionId == null ||
                                    state.user!.user.unionId == '')
                                  const SizedBox(width: 5),
                                if (state.user!.user.unionId == null ||
                                    state.user!.user.unionId == '')
                                  const Icon(
                                    CupertinoIcons.chevron_forward,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                            onPressed: (context) async {
                              if (state.user!.user.unionId == null ||
                                  state.user!.user.unionId == '') {
                                final ok = await sendWeChatAuth(
                                    scope: "snsapi_userinfo",
                                    state: "wechat_sdk_demo_test");
                                if (!ok) {
                                  showErrorMessage('请先安装微信后再使用该功能');
                                }
                              }
                            },
                          ),
                        SettingsTile(
                          title: Text(state.user!.control.isSetPassword
                              ? '修改密码'
                              : '设置密码'),
                          trailing: const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: (context) {
                            context.push('/user/change-password');
                          },
                        ),
                      ],
                    ),
                    SettingsSection(
                      tiles: [
                        SettingsTile(
                          title: Text(AppLocale.signOut.getString(context)),
                          trailing: const Icon(
                            Icons.logout,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: (_) {
                            openConfirmDialog(
                              context,
                              AppLocale.confirmSignOut.getString(context),
                              () {
                                context
                                    .read<AccountBloc>()
                                    .add(AccountSignOutEvent());
                                context.go('/login');
                              },
                              danger: true,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

Widget buildSettingsList(
  BuildContext context,
  List<AbstractSettingsSection> sections,
) {
  final customColors = Theme.of(context).extension<CustomColors>()!;
  return RefreshIndicator(
    color: customColors.linkColor,
    displacement: 20,
    onRefresh: () async {
      context.read<AccountBloc>().add(AccountLoadEvent());
    },
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
      sections: sections,
      contentPadding: const EdgeInsets.all(0),
    ),
  );
}
