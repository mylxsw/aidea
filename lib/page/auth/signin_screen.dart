import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:askaide/bloc/version_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/env.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluwx/fluwx.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:askaide/helper/http.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  final SettingRepository settings;
  final String? username;

  const SignInScreen({super.key, required this.settings, this.username});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();

  final phoneNumberValidator = RegExp(r"^1[3456789]\d{9}$");
  final emailValidator = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  var agreeProtocol = false;

  StreamSubscription<BaseWeChatResponse>? _weChatResponse;

  /// 微信登录 token，用于自动绑定微信
  String? wechatBindToken;

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      _usernameController.text = widget.username!;
    }

    if (Ability().enableWechatSignin) {
      _weChatResponse =
          weChatResponseEventHandler.distinct((a, b) => a == b).listen((event) {
        if (event is WeChatAuthResponse) {
          if (event.errCode != 0) {
            showErrorMessage(event.errStr!);
            return;
          }

          if (event.code == null) {
            showErrorMessage(AppLocale.signInFailed.getString(context));
            return;
          }

          processing = true;

          APIServer()
              .trySignInWithWechat(code: event.code!)
              .then((tryRes) async {
            if (tryRes.exist) {
              await confirmWeChatSignin(tryRes.token);
            } else {
              await showBeautyDialog(
                context,
                type: QuickAlertType.confirm,
                title: '提示',
                text: '该微信未绑定任何账号，是否直接登录？\n（自动创建账号）',
                confirmBtnText: '直接登录',
                onConfirmBtnTap: () async {
                  await confirmWeChatSignin(tryRes.token);
                  // ignore: use_build_context_synchronously
                  context.pop();
                },
                showCancelBtn: true,
                cancelBtnText: '绑定已有账号',
                onCancelBtnTap: () {
                  setState(() {
                    wechatBindToken = tryRes.token;
                  });
                  context.pop();
                },
              );
            }
          }).whenComplete(() => processing = false);
        }
      });
    }

    context.read<VersionBloc>().add(VersionCheckEvent());
  }

  confirmWeChatSignin(String token) async {
    try {
      final value = await APIServer().signInWithWechat(token: token);

      await widget.settings.set(settingAPIServerToken, value.token);
      await widget.settings.set(settingUserInfo, jsonEncode(value));

      await HttpClient.cleanCache();

      if (value.needBindPhone) {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          context.push('/bind-phone').then((value) async {
            if (value == 'logout') {
              await widget.settings.set(settingAPIServerToken, '');
              await widget.settings.set(settingUserInfo, '');
            }
          });
        }
      } else {
        // ignore: use_build_context_synchronously
        context.go(
            '${Ability().homeRoute}?show_initial_dialog=${value.isNewUser ? "true" : "false"}&reward=${value.reward}');
      }
    } catch (e) {
      Logger.instance.e(e);
      // ignore: use_build_context_synchronously
      showErrorMessage(AppLocale.signInFailed.getString(context));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _weChatResponse?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: customColors.weakLinkColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Ability().homeRoute);
            }
          },
        ),
      ),
      backgroundColor: customColors.backgroundColor,
      body: BackgroundContainer(
        setting: widget.settings,
        enabled: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.asset('assets/app.png'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'AIdea',
                        textStyle: const TextStyle(fontSize: 30.0),
                        colors: [
                          Colors.purple,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: TextFormField(
                      controller: _usernameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(200, 192, 192, 192)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: customColors.linkColor ?? Colors.green),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: customColors.linkColor ?? Colors.green,
                        ),
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: AppLocale.account.getString(context),
                        labelStyle: const TextStyle(fontSize: 17),
                        hintText: AppLocale.accountInputTips.getString(context),
                        hintStyle: TextStyle(
                          color: customColors.textfieldHintColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      '未注册的账号验证成功后将自动注册',
                      style: TextStyle(
                        color: customColors.weakTextColor?.withAlpha(80),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // 登录按钮
                  Container(
                    height: 45,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: customColors.linkColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: TextButton(
                      onPressed: onSigninSubmit,
                      child: const Text(
                        '验证',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 15),
                  //   child: Column(
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           // 找回密码
                  //           TextButton(
                  //             onPressed: () {
                  //               context.push(
                  //                   '/retrieve-password?username=${_usernameController.text.trim()}');
                  //             },
                  //             child: Text(
                  //               AppLocale.forgotPassword.getString(context),
                  //               style: TextStyle(
                  //                 color: customColors.weakLinkColor,
                  //                 fontSize: 14,
                  //               ),
                  //             ),
                  //           ),
                  //           // 创建账号
                  //           TextButton(
                  //               onPressed: () {
                  //                 context
                  //                     .push(
                  //                         '/signup?username=${_usernameController.text.trim()}')
                  //                     .then((value) {
                  //                   if (value != null) {
                  //                     _usernameController.text = value as String;
                  //                   }
                  //                 });
                  //               },
                  //               child: Text(
                  //                 AppLocale.createAccount.getString(context),
                  //                 style: TextStyle(
                  //                   color: customColors.linkColor,
                  //                   fontSize: 14,
                  //                 ),
                  //               )),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  _buildUserTermsAndPrivicy(customColors, context),
                  const SizedBox(height: 50),
                  // 三方登录
                  BlocBuilder<VersionBloc, VersionState>(
                    builder: (context, state) {
                      return _buildThirdPartySignInButtons(
                          context, customColors);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row _buildUserTermsAndPrivicy(
      CustomColors customColors, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.75,
          child: Theme(
            data: ThemeData(
              unselectedWidgetColor: customColors.weakTextColor?.withAlpha(180),
            ),
            child: Checkbox(
              activeColor: customColors.linkColor,
              value: agreeProtocol,
              onChanged: (agree) {
                setState(() {
                  agreeProtocol = !agreeProtocol;
                });
              },
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: AppLocale.readAndAgree.getString(context),
                style: TextStyle(
                  color: customColors.weakTextColor?.withAlpha(80),
                  fontSize: 12,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      agreeProtocol = !agreeProtocol;
                    });
                  },
              ),
              TextSpan(
                text: '《${AppLocale.userTerms.getString(context)}》',
                style: TextStyle(
                  color: customColors.linkColor?.withAlpha(150),
                  fontSize: 12,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(
                        Uri.parse('$apiServerURL/public/info/terms-of-user'));
                  },
              ),
              TextSpan(
                text: AppLocale.andWord.getString(context),
                style: TextStyle(
                  color: customColors.weakTextColor?.withAlpha(80),
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: '《${AppLocale.privacyPolicy.getString(context)}》',
                style: TextStyle(
                  color: customColors.linkColor?.withAlpha(150),
                  fontSize: 12,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(
                        Uri.parse('$apiServerURL/public/info/privacy-policy'));
                  },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildThirdPartySignInButtons(
      BuildContext context, CustomColors customColors) {
    return FutureBuilder(
      future: isWeChatInstalled,
      builder: (context, installed) {
        final signInItems = <Widget>[];

        if (Ability().enableAppleSignin) {
          signInItems.add(SignInButton(
            Buttons.appleDark,
            mini: true,
            shape: const CircleBorder(),
            onPressed: onAppleSigninSubmit,
          ));
        }

        // 微信登录功能
        if (Ability().enableWechatSignin) {
          if (PlatformTool.isAndroid() || installed.data == true) {
            signInItems.add(SignInButtonBuilder(
              mini: true,
              shape: const CircleBorder(),
              onPressed: () async {
                if (processing) {
                  return;
                }

                if (!agreeProtocol) {
                  showErrorMessage(
                      AppLocale.pleaseReadAgreeProtocol.getString(context));
                  return;
                }

                final ok = await sendWeChatAuth(
                    scope: "snsapi_userinfo", state: "wechat_sdk_demo_test");
                if (!ok) {
                  showErrorMessage('请先安装微信后再使用该功能');
                }
              },
              backgroundColor: Colors.green,
              text: '微信',
              icon: Icons.wechat,
            ));
          }
        }

        if (signInItems.isEmpty) {
          return Container();
        }

        return Column(
          children: [
            Text(
              '其它登录方式',
              style: TextStyle(
                fontSize: 13,
                color: customColors.weakTextColor?.withAlpha(80),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: signInItems
                  .map((e) =>
                      Padding(padding: const EdgeInsets.all(10), child: e))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  bool processing = false;

  onAppleSigninSubmit() async {
    if (processing) {
      return;
    }

    if (!agreeProtocol) {
      showErrorMessage(AppLocale.pleaseReadAgreeProtocol.getString(context));
      return;
    }

    processing = true;

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'cc.aicode.askaide',
          redirectUri: Uri.parse(
              'https://ai-api.aicode.cc/v1/callback/auth/sign_in_with_apple'),
        ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      APIServer()
          .signInWithApple(
        userIdentifier: credential.userIdentifier ?? '',
        authorizationCode: credential.authorizationCode,
        identityToken: credential.identityToken,
        familyName: credential.familyName,
        givenName: credential.givenName,
        email: credential.email,
        wechatBindToken: wechatBindToken,
      )
          .then((value) async {
        await widget.settings.set(settingAPIServerToken, value.token);
        await widget.settings.set(settingUserInfo, jsonEncode(value));

        () {
          if (value.needBindPhone) {
            if (context.mounted) {
              context.push('/bind-phone').then((value) async {
                if (value == 'logout') {
                  await widget.settings.set(settingAPIServerToken, '');
                  await widget.settings.set(settingUserInfo, '');
                }
              });
            }
            return;
          } else {
            context.go(
                '${Ability().homeRoute}?show_initial_dialog=${value.isNewUser ? "true" : "false"}&reward=${value.reward}');
          }
        }();

        // HttpClient.cacheManager.clearAll().then((_) {
        //   if (value.needBindPhone) {
        //     if (context.mounted) {
        //       context.push('/bind-phone').then((value) async {
        //         if (value == 'logout') {
        //           await widget.settings.set(settingAPIServerToken, '');
        //           await widget.settings.set(settingUserInfo, '');
        //         }
        //       });
        //     }
        //     return;
        //   } else {
        //     context.go(
        //         '${Ability().homeRoute}?show_initial_dialog=${value.isNewUser ? "true" : "false"}&reward=${value.reward}');
        //   }
        // });
      }).catchError((e) {
        Logger.instance.e(e);
        showErrorMessage(AppLocale.signInFailed.getString(context));
      }).onError((error, stackTrace) {
        Logger.instance.e(error);
        showErrorMessage(AppLocale.signInFailed.getString(context));
      });
    } finally {
      processing = false;
    }
  }

  onSigninSubmit() {
    FocusScope.of(context).requestFocus(FocusNode());

    if (processing) {
      return;
    }

    final username = _usernameController.text.trim();
    if (username == '') {
      showErrorMessage(AppLocale.accountRequired.getString(context));
      return;
    }

    if (!phoneNumberValidator.hasMatch(username) &&
        !emailValidator.hasMatch(username)) {
      showErrorMessage(AppLocale.accountFormatError.getString(context));
      return;
    }

    if (!agreeProtocol) {
      showErrorMessage(AppLocale.pleaseReadAgreeProtocol.getString(context));
      return;
    }

    processing = true;

    APIServer().checkPhoneExists(username).then((resp) async {
      context.push(
          '/signin-or-signup?username=$username&is_signup=${resp.exist ? "false" : "true"}&sign_in_method=${resp.signInMethod}${wechatBindToken != null ? '&wechat_bind_token=$wechatBindToken' : ''}');
    }).catchError((e) {
      showErrorMessage(resolveError(context, e));
    }).whenComplete(() => processing = false);
  }
}
