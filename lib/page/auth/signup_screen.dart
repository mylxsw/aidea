import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/env.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/password_field.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  final SettingRepository settings;
  final String? username;

  const SignupScreen({super.key, required this.settings, this.username});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String verifyCodeId = '';

  final emailValidator = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final phoneNumberValidator = RegExp(r"^1[3456789]\d{9}$");

  var agreeProtocol = false;

  //  下次发送验证码等待时间
  int verifyCodeWaitSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    if (widget.username != null) {
      _usernameController.text = widget.username!;
    }

    // Clipboard.getData(Clipboard.kTextPlain).then((value) {
    //   if (value == null || value.text == null || value.text == '') {
    //     return;
    //   }

    //   if (value.text!.trim().contains(RegExp(r'\$AIDEA\.INV\.\w+\$'))) {
    //     final match = RegExp(r'\$AIDEA\.INV\.(\w+)\$').firstMatch(value.text!);
    //     if (match != null) {
    //       final val = match.group(1);
    //       if (val != null) {
    //         _inviteCodeController.text = val;
    //       }
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    _usernameController.dispose();
    _inviteCodeController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop(_usernameController.text.trim());
            } else {
              context.go('/login?username=${_usernameController.text.trim()}');
            }
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BackgroundContainer(
        setting: widget.settings,
        enabled: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset('assets/app.png'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'AIdea',
                        textStyle: const TextStyle(fontSize: 20.0),
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
                  // 用户名
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
                              color: Color.fromARGB(255, 192, 192, 192)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: customColors.linkColor!),
                        ),
                        floatingLabelStyle:
                            TextStyle(color: customColors.linkColor!),
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: AppLocale.account.getString(context),
                        hintText: AppLocale.accountInputTips.getString(context),
                        hintStyle: TextStyle(
                          color: customColors.textfieldHintColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  // 密码
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: PasswordField(
                      controller: _passwordController,
                      labelText: AppLocale.password.getString(context),
                      hintText: AppLocale.passwordInputTips.getString(context),
                    ),
                  ),
                  // 邀请码
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: TextFormField(
                      controller: _inviteCodeController,
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 192, 192, 192)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: customColors.linkColor!),
                        ),
                        floatingLabelStyle:
                            TextStyle(color: customColors.linkColor!),
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: AppLocale.inviteCode.getString(context),
                        hintText:
                            AppLocale.inviteCodeInputTips.getString(context),
                        hintStyle: TextStyle(
                          color: customColors.textfieldHintColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  // 验证码
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _verificationCodeController,
                          inputFormatters: [
                            FilteringTextInputFormatter.singleLineFormatter,
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 6,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            counterText: '',
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 192, 192, 192)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: customColors.linkColor!),
                            ),
                            floatingLabelStyle:
                                TextStyle(color: customColors.linkColor!),
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: AppLocale.verifyCode.getString(context),
                            hintText: AppLocale.verifyCodeInputTips
                                .getString(context),
                            hintStyle: TextStyle(
                              color: customColors.textfieldHintColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 100,
                        child: verifyCodeWaitSeconds > 0
                            ? TextButton(
                                onPressed: null,
                                child: Text(
                                  '$verifyCodeWaitSeconds ${AppLocale.retryInSeconds.getString(context)}',
                                  style: TextStyle(
                                    color: customColors.weakTextColor,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: () {
                                  final username =
                                      _usernameController.text.trim();

                                  final isEmail =
                                      emailValidator.hasMatch(username);

                                  final isPhoneNumber =
                                      phoneNumberValidator.hasMatch(username);

                                  if (_usernameController.text.trim() == '') {
                                    showErrorMessage(AppLocale.accountRequired
                                        .getString(context));
                                    return;
                                  }

                                  if (!isEmail && !isPhoneNumber) {
                                    showErrorMessage(AppLocale
                                        .accountFormatError
                                        .getString(context));
                                    return;
                                  }

                                  APIServer()
                                      .sendSignupVerifyCode(
                                    username,
                                    verifyType: isEmail ? 'email' : 'sms',
                                  )
                                      .then((id) {
                                    verifyCodeId = id;
                                    setState(() {
                                      verifyCodeWaitSeconds = 60;
                                    });

                                    if (timer != null) {
                                      timer?.cancel();
                                      timer = null;
                                    }

                                    timer = Timer.periodic(
                                        const Duration(seconds: 1), (timer) {
                                      if (verifyCodeWaitSeconds <= 0) {
                                        timer.cancel();
                                        return;
                                      }

                                      setState(() {
                                        verifyCodeWaitSeconds--;
                                      });
                                    });

                                    showSuccessMessage(
                                        '${AppLocale.verifyCodeSendSuccess.getString(context)}${isEmail ? AppLocale.email.getString(context) : AppLocale.phone.getString(context)}');
                                  }).onError((error, stackTrace) {
                                    setState(() {
                                      verifyCodeWaitSeconds = 0;
                                      timer?.cancel();
                                    });

                                    showErrorMessage(
                                        resolveError(context, error!));
                                  });
                                },
                                child: Text(
                                  AppLocale.sendVerifyCode.getString(context),
                                  style: TextStyle(
                                    color: customColors.linkColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 15),
                  // 创建账号
                  Container(
                    height: 50,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: customColors.linkColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: onCreateSubmit,
                      child: Text(
                        AppLocale.createAccount.getString(context),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  // 直接登录
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop(_usernameController.text.trim());
                              } else {
                                context.go(
                                    '/login?username=${_usernameController.text.trim()}');
                              }
                            },
                            child: Text(
                              AppLocale.directSignin.getString(context),
                              style: TextStyle(
                                color: customColors.linkColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildUserTermsAndPrivicy(customColors, context),
                    ]),
                  ),
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
                  color: customColors.weakTextColor,
                  fontSize: 13,
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
                  color: customColors.weakLinkColor,
                  fontSize: 13,
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
                  color: customColors.weakTextColor,
                  fontSize: 13,
                ),
              ),
              TextSpan(
                text: '《${AppLocale.privacyPolicy.getString(context)}》',
                style:
                    TextStyle(color: customColors.weakLinkColor, fontSize: 13),
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

  onCreateSubmit() {
    FocusScope.of(context).requestFocus(FocusNode());

    final username = _usernameController.text.trim();
    if (username == '') {
      showErrorMessage(AppLocale.accountRequired.getString(context));
      return;
    }

    if (!emailValidator.hasMatch(username) &&
        !phoneNumberValidator.hasMatch(username)) {
      showErrorMessage(AppLocale.accountFormatError.getString(context));
      return;
    }

    final password = _passwordController.text.trim();
    if (password == '' || password.length < 8 || password.length > 20) {
      showErrorMessage(AppLocale.passwordFormatError.getString(context));
      return;
    }

    if (verifyCodeId == '') {
      showErrorMessage(AppLocale.pleaseGetVerifyCodeFirst.getString(context));
      return;
    }

    final verificationCode = _verificationCodeController.text.trim();
    if (verificationCode == '') {
      showErrorMessage(AppLocale.verifyCodeRequired.getString(context));
      return;
    }
    if (verificationCode.length != 6) {
      showErrorMessage(AppLocale.verifyCodeFormatError.getString(context));
      return;
    }

    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode != '' && inviteCode.length > 20) {
      showErrorMessage(AppLocale.inviteCodeFormatError.getString(context));
      return;
    }

    if (!agreeProtocol) {
      showErrorMessage(AppLocale.pleaseReadAgreeProtocol.getString(context));
      return;
    }

    final cancel = BotToast.showCustomLoading(
      toastBuilder: (cancel) {
        return LoadingIndicator(
          message: AppLocale.processingWait.getString(context),
        );
      },
      allowClick: false,
      duration: const Duration(seconds: 120),
    );

    APIServer()
        .signupWithPassword(
      username: username,
      password: password,
      inviteCode: inviteCode,
      verifyCodeId: verifyCodeId,
      verifyCode: verificationCode,
    )
        .then((value) async {
      await widget.settings.set(settingAPIServerToken, value.token);
      await widget.settings.set(settingUserInfo, jsonEncode(value));

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

        return;
      } else {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          context.go(
              '${Ability().homeRoute}?show_initial_dialog=${value.isNewUser ? "true" : "false"}&reward=${value.reward}');
        }
      }
    }).catchError((e) {
      showErrorMessage(resolveError(context, e));
    }).whenComplete(() => cancel());
  }
}
