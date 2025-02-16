import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/password_field.dart';
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
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class RetrievePasswordScreen extends StatefulWidget {
  final String? username;
  final SettingRepository setting;
  const RetrievePasswordScreen({super.key, this.username, required this.setting});

  @override
  State<RetrievePasswordScreen> createState() => _RetrievePasswordScreenState();
}

class _RetrievePasswordScreenState extends State<RetrievePasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  String verifyCodeId = '';

  final phoneNumberValidator = RegExp(r"^1[3456789]\d{9}$");
  final emailValidator = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void initState() {
    super.initState();

    if (widget.username != null) {
      _usernameController.text = widget.username!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: Text(
            AppLocale.resetPassword.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundContainerColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextFormField(
                  controller: _usernameController,
                  inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(200, 192, 192, 192)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: customColors.linkColor!),
                    ),
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
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: PasswordField(
                  controller: _passwordController,
                  labelText: AppLocale.newPassword.getString(context),
                  hintText: AppLocale.passwordInputTips.getString(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 10.0, top: 15, bottom: 0),
                child: VerifyCodeInput(
                  controller: _verificationCodeController,
                  onVerifyCodeSent: (id) {
                    verifyCodeId = id;
                  },
                  sendVerifyCode: () {
                    return APIServer().sendResetPasswordCode(
                      _usernameController.text.trim(),
                      verifyType: phoneNumberValidator.hasMatch(_usernameController.text) ? 'sms' : 'email',
                    );
                  },
                  sendCheck: () {
                    final username = _usernameController.text.trim();
                    final isPhoneNumber = phoneNumberValidator.hasMatch(username);
                    final isEmail = emailValidator.hasMatch(username);

                    if (username == '') {
                      showErrorMessage(AppLocale.accountRequired.getString(context));
                      return false;
                    }

                    if (!isPhoneNumber && !isEmail) {
                      showErrorMessage(AppLocale.accountFormatError.getString(context));
                      return false;
                    }

                    return true;
                  },
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
                  onPressed: onResetSubmit,
                  child: Text(
                    AppLocale.resetPassword.getString(context),
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
    final username = _usernameController.text.trim();
    if (username == '') {
      showErrorMessage(AppLocale.accountRequired.getString(context));
      return;
    }

    if (!phoneNumberValidator.hasMatch(username) && !emailValidator.hasMatch(username)) {
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
        .resetPasswordByCode(
      username: username,
      password: password,
      verifyCodeId: verifyCodeId,
      verifyCode: verificationCode,
    )
        .then((value) {
      showSuccessMessage(AppLocale.passwordResetOK.getString(context));
      context.pop();
    }).catchError((e) {
      showErrorMessage(resolveError(context, e));
    }).whenComplete(() => cancel());
  }
}
