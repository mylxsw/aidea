import 'dart:convert';

import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/verify_code_input.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class BindPhoneScreen extends StatefulWidget {
  final SettingRepository setting;
  final bool isSignIn;
  const BindPhoneScreen({super.key, required this.setting, this.isSignIn = true});

  @override
  State<BindPhoneScreen> createState() => _BindPhoneScreenState();
}

class _BindPhoneScreenState extends State<BindPhoneScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  String verifyCodeId = '';
  final phoneNumberValidator = RegExp(r"^1[3456789]\d{9}$");

  @override
  void initState() {
    super.initState();

    context.read<AccountBloc>().add(AccountLoadEvent(cache: false));

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
    _inviteCodeController.dispose();
    _usernameController.dispose();
    _verificationCodeController.dispose();

    super.dispose();
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
            AppLocale.bindPhone.getString(context),
            style: const TextStyle(
              fontSize: CustomSize.appBarTitleSize,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              if (widget.isSignIn) {
                context.go('${Ability().homeRoute}?show_initial_dialog=false&reward=0');
              } else {
                context.pop();
              }

              // 当返回值为 logout 时，表示需要退出登录
              // if (widget.isSignIn) {
              //   context.pop('logout');
              // } else {
              //   context.pop();
              // }
            },
            icon: Icon(widget.isSignIn ? Icons.close : Icons.arrow_back_ios),
          ),
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: BlocBuilder<AccountBloc, AccountState>(
            buildWhen: (previous, current) => current is AccountLoaded,
            builder: (context, state) {
              if (state is AccountLoaded) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(200, 192, 192, 192)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: customColors.linkColor ?? Colors.green),
                          ),
                          floatingLabelStyle: TextStyle(color: customColors.linkColor!),
                          isDense: true,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: AppLocale.account.getString(context),
                          labelStyle: const TextStyle(fontSize: 17),
                          hintText: AppLocale.phoneInputTips.getString(context),
                          hintStyle: TextStyle(
                            color: customColors.textfieldHintColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 5.0, top: 15, bottom: 0),
                      child: VerifyCodeInput(
                        controller: _verificationCodeController,
                        onVerifyCodeSent: (id) {
                          verifyCodeId = id;
                        },
                        sendVerifyCode: () {
                          return APIServer().sendBindPhoneCode(_usernameController.text.trim());
                        },
                        sendCheck: () {
                          final username = _usernameController.text.trim();
                          final isPhoneNumber = phoneNumberValidator.hasMatch(username);

                          if (!isPhoneNumber) {
                            showErrorMessage(AppLocale.phoneNumberFormatError.getString(context));
                            return false;
                          }

                          return true;
                        },
                      ),
                    ),
                    if (state.user!.user.invitedBy == null || state.user!.user.invitedBy == 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                        child: TextFormField(
                          controller: _inviteCodeController,
                          inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(200, 192, 192, 192)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: customColors.linkColor!),
                            ),
                            floatingLabelStyle: TextStyle(color: customColors.linkColor!),
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: AppLocale.inviteCode.getString(context),
                            labelStyle: const TextStyle(fontSize: 17),
                            hintText: AppLocale.inviteCodeInputTips.getString(context),
                            hintStyle: TextStyle(
                              color: customColors.textfieldHintColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    Container(
                      height: 45,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: customColors.linkColor,
                        borderRadius: CustomSize.borderRadius,
                      ),
                      child: TextButton(
                        onPressed: onSubmit,
                        child: Text(
                          AppLocale.ok.getString(context),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
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

  onSubmit() {
    final username = _usernameController.text.trim();
    if (username == '') {
      showErrorMessage(AppLocale.accountRequired.getString(context));
      return;
    }

    if (!phoneNumberValidator.hasMatch(username)) {
      showErrorMessage(AppLocale.phoneNumberFormatError.getString(context));
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
        .bindPhone(
      username: username,
      verifyCodeId: verifyCodeId,
      verifyCode: verificationCode,
      inviteCode: inviteCode,
    )
        .then((value) async {
      await widget.setting.set(settingAPIServerToken, value.token);
      await widget.setting.set(settingUserInfo, jsonEncode(value));

      if (widget.isSignIn) {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          context.go(
              '${Ability().homeRoute}?show_initial_dialog=${value.isNewUser ? "true" : "false"}&reward=${value.reward}');
        }
      } else {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          showSuccessMessage(AppLocale.operateSuccess.getString(context));
        }
      }
    }).catchError((e) {
      showErrorMessage(resolveError(context, e));
    }).whenComplete(() => cancel());
  }
}
