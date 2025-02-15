import 'dart:async';

import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';

class VerifyCodeInput extends StatefulWidget {
  final Future<String> Function() sendVerifyCode;
  final Function(String) onVerifyCodeSent;
  final bool Function() sendCheck;
  final TextEditingController controller;
  final bool inColumnBlock;
  const VerifyCodeInput({
    super.key,
    required this.onVerifyCodeSent,
    required this.sendVerifyCode,
    required this.sendCheck,
    required this.controller,
    this.inColumnBlock = false,
  });

  @override
  State<VerifyCodeInput> createState() => _VerifyCodeInputState();
}

class _VerifyCodeInputState extends State<VerifyCodeInput> {
  final phoneNumberValidator = RegExp(r"^1[3456789]\d{9}$");

  //  下次发送验证码等待时间
  int verifyCodeWaitSeconds = 0;

  Timer? timer;
  DateTime? lastSendVerifyCodeTime;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      padding: widget.inColumnBlock ? const EdgeInsets.all(5) : null,
      child: Row(
        children: [
          if (widget.inColumnBlock)
            SizedBox(
              width: 80,
              child: Text(
                AppLocale.verifyCode.getString(context),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: customColors.textfieldLabelColor,
                ),
              ),
            ),
          if (widget.inColumnBlock) const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter,
                FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                counterText: '',
                border: widget.inColumnBlock ? InputBorder.none : const OutlineInputBorder(),
                enabledBorder: widget.inColumnBlock
                    ? InputBorder.none
                    : const OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(200, 192, 192, 192)),
                      ),
                focusedBorder: widget.inColumnBlock
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderSide: BorderSide(color: customColors.linkColor ?? Colors.green),
                      ),
                // floatingLabelStyle:
                //     TextStyle(color: customColors.linkColor ?? Colors.green),
                isDense: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: widget.inColumnBlock ? null : AppLocale.verifyCode.getString(context),
                labelStyle: const TextStyle(fontSize: 17),
                hintText: AppLocale.verifyCodeInputTips.getString(context),
                hintStyle: TextStyle(
                  color: customColors.textfieldHintColor,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 30),
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
                      if (!widget.sendCheck()) {
                        return;
                      }

                      widget.sendVerifyCode().then((id) {
                        widget.onVerifyCodeSent(id);
                        setState(() {
                          verifyCodeWaitSeconds = 60;
                        });

                        if (timer != null) {
                          timer?.cancel();
                          timer = null;
                        }

                        lastSendVerifyCodeTime = DateTime.now();
                        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                          if (verifyCodeWaitSeconds <= 0) {
                            timer.cancel();
                            return;
                          }

                          setState(() {
                            verifyCodeWaitSeconds = 60 - (DateTime.now().difference(lastSendVerifyCodeTime!).inSeconds);
                          });
                        });

                        showSuccessMessage(AppLocale.verifyCodeSendSuccess.getString(context));
                      }).onError((error, stackTrace) {
                        setState(() {
                          verifyCodeWaitSeconds = 0;
                        });
                        timer?.cancel();
                        showErrorMessage(resolveError(context, error!));
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
        ],
      ),
    );
  }
}
