import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/password_field.dart';
import 'package:askaide/page/component/verify_code_input.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordScreen extends StatefulWidget {
  final SettingRepository setting;

  const ChangePasswordScreen({super.key, required this.setting});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  String verifyCodeId = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: Text(
          AppLocale.modifyPassword.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
      ),
      backgroundColor: customColors.backgroundColor,
      body: BackgroundContainer(
        setting: widget.setting,
        backgroundColor: customColors.backgroundColor,
        enabled: false,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              ColumnBlock(
                innerPanding: 15,
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                showDivider: false,
                children: [
                  PasswordField(
                    controller: _passwordController,
                    labelText: AppLocale.newPassword.getString(context),
                    hintText: AppLocale.passwordInputTips.getString(context),
                    inColumnBlock: false,
                  ),
                  VerifyCodeInput(
                    inColumnBlock: false,
                    controller: _verificationCodeController,
                    onVerifyCodeSent: (id) {
                      verifyCodeId = id;
                    },
                    sendVerifyCode: () {
                      return APIServer().sendResetPasswordCodeForSignedUser();
                    },
                    sendCheck: () {
                      return true;
                    },
                  ),
                ],
              ),
              Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: customColors.linkColor,
                  borderRadius: CustomSize.borderRadius,
                ),
                child: TextButton(
                  onPressed: onResetSubmit,
                  child: Text(
                    AppLocale.ok.getString(context),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onResetSubmit() {
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
        .resetPasswordByCodeSignedUser(
      password: password,
      verifyCodeId: verifyCodeId,
      verifyCode: verificationCode,
    )
        .then((value) {
      showSuccessMessage(AppLocale.operateSuccess.getString(context));
      if (context.canPop()) {
        context.pop();
      }
    }).catchError((e) {
      showErrorMessage(resolveError(context, e));
    }).whenComplete(() => cancel());
  }
}
