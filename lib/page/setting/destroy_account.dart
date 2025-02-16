import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/verify_code_input.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class DestroyAccountScreen extends StatefulWidget {
  final SettingRepository setting;

  const DestroyAccountScreen({super.key, required this.setting});

  @override
  State<DestroyAccountScreen> createState() => _DestroyAccountScreenState();
}

class _DestroyAccountScreenState extends State<DestroyAccountScreen> {
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

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: Text(
            AppLocale.deleteAccount.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const MessageBox(
                  message:
                      '请注意，注销账号后：\n1. 您的数据将被清空，包括角色、创作岛历史纪录、充值数据、智慧果使用明细等全部数据；\n2. 您未使用完的智慧果将会被销毁，无法继续使用，无法退回；\n3. 注销操作不可逆，一旦账号注销，所有被删除数据均无法恢复。',
                  type: MessageBoxType.warning,
                ),
                const SizedBox(height: 15),
                ColumnBlock(
                  padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
                  children: [
                    VerifyCodeInput(
                      inColumnBlock: false,
                      controller: _verificationCodeController,
                      onVerifyCodeSent: (id) {
                        verifyCodeId = id;
                      },
                      sendVerifyCode: () {
                        return APIServer().sendDestroyAccountSMSCode();
                      },
                      sendCheck: () {
                        return true;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.red, borderRadius: CustomSize.borderRadius),
                  child: TextButton(
                    onPressed: onDestroySubmit,
                    child: Text(
                      AppLocale.confirmDeleteAccount.getString(context),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onDestroySubmit() {
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
        .destroyAccount(
      verifyCodeId: verifyCodeId,
      verifyCode: verificationCode,
    )
        .then((value) async {
      await widget.setting.set(settingAPIServerToken, '');
      await widget.setting.set(settingUserInfo, '');

      showSuccessMessage('账号注销成功');

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        context.go('/login');
      }
    }).catchError((e) {
      showErrorMessage(resolveError(context, e));
    }).whenComplete(() => cancel());
  }
}
