import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'web/payment_element.dart' if (dart.library.js) 'web/payment_element_web.dart';

class WebPaymentProxy extends StatefulWidget {
  final SettingRepository setting;
  final String paymentId;
  final String paymentIntent;
  final String price;
  final String publishableKey;
  final String? finishAction;

  const WebPaymentProxy({
    super.key,
    required this.setting,
    required this.paymentId,
    required this.paymentIntent,
    required this.price,
    required this.publishableKey,
    this.finishAction,
  });

  @override
  State<WebPaymentProxy> createState() => _WebPaymentProxyState();
}

class _WebPaymentProxyState extends State<WebPaymentProxy> {
  @override
  void initState() {
    super.initState();

    Stripe.publishableKey = widget.publishableKey;
    Stripe.urlScheme = 'flutterstripe';
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            '',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: customColors.backgroundContainerColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          maxWidth: CustomSize.smallWindowSize,
          child: Center(
            child: FutureBuilder(
                future: Stripe.instance.applySettings(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Logger.instance.e('Stripe 初始化失败：${snapshot.error}');
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Builder(
                            builder: (context) {
                              return PlatformPaymentElement(
                                widget.paymentIntent,
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: EnhancedButton(
                          title: '确定付款（${widget.price}）',
                          onPressed: () async {
                            final cancel = BotToast.showCustomLoading(
                              toastBuilder: (cancel) {
                                return LoadingIndicator(
                                  message: AppLocale.processingWait.getString(context),
                                );
                              },
                              allowClick: false,
                              duration: const Duration(seconds: 120),
                            );

                            try {
                              await pay(
                                widget.paymentId,
                                action: widget.finishAction,
                              );
                            } catch (e) {
                              Logger.instance.e('支付失败：$e');
                              // ignore: use_build_context_synchronously
                              showErrorMessageEnhanced(context, '请填写完整的支付信息');
                            } finally {
                              cancel();
                            }
                          },
                        ),
                      )
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
