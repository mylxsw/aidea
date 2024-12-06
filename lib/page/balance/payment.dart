import 'dart:async';

import 'package:askaide/bloc/payment_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/balance/price_block.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/markdown.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/payment.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:tobias/tobias.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'web/payment_element.dart' if (dart.library.js) 'web/payment_element_web.dart';

class PaymentScreen extends StatefulWidget {
  final SettingRepository setting;
  const PaymentScreen({super.key, required this.setting});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Function()? _cancelLoading;

  @override
  void initState() {
    if (PlatformTool.isIOS()) {
      final purchaseUpdated = InAppPurchase.instance.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription?.cancel();
      }, onError: (error) {
        showErrorMessage(resolveError(context, error));
      });
    } else if (PlatformTool.isAndroid()) {
      // 微信支付
      fluwx.weChatResponseEventHandler.listen((res) {
        if (res is fluwx.WeChatPaymentResponse) {
          if (res.isSuccessful) {
            showSuccessMessage('购买成功');
          } else {
            showErrorMessage(res.errStr ?? '支付失败');
          }
        }
      });
    }

    // 加载支付产品列表
    context.read<PaymentBloc>().add(PaymentLoadAppleProducts());

    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // 支付 ID
  String? paymentId;

  ProductDetails? selectedProduct;

  /// 监听支付状态
  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          await APIServer().updateApplePay(
            paymentId!,
            productId: purchaseDetails.productID,
            localVerifyData: purchaseDetails.verificationData.localVerificationData,
            serverVerifyData: purchaseDetails.verificationData.serverVerificationData,
            verifyDataSource: purchaseDetails.verificationData.source,
          );

          break;
        case PurchaseStatus.error:
          APIServer()
              .cancelApplePay(
            paymentId!,
            reason: purchaseDetails.error.toString(),
          )
              .whenComplete(() {
            _closePaymentLoading();
            showErrorMessage(resolveError(context, purchaseDetails.error!));
          });

          break;
        case PurchaseStatus.purchased: // fall through
          if (paymentId != null) {
            APIServer()
                .verifyApplePay(
              paymentId!,
              productId: purchaseDetails.productID,
              purchaseId: purchaseDetails.purchaseID,
              transactionDate: purchaseDetails.transactionDate,
              localVerifyData: purchaseDetails.verificationData.localVerificationData,
              serverVerifyData: purchaseDetails.verificationData.serverVerificationData,
              verifyDataSource: purchaseDetails.verificationData.source,
              status: purchaseDetails.status.toString(),
            )
                .then((status) {
              _closePaymentLoading();
              showSuccessMessage('购买成功');
            }).onError((error, stackTrace) {
              _closePaymentLoading();
              showErrorMessage(resolveError(context, error!));
            });
          }

          break;
        case PurchaseStatus.restored:
          Logger.instance.d('恢复购买');
          _closePaymentLoading();
          showSuccessMessage('恢复成功');
          break;
        case PurchaseStatus.canceled:
          APIServer().cancelApplePay(paymentId!).whenComplete(() {
            _closePaymentLoading();
            showErrorMessage('购买已取消');
          });

          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  /// 关闭支付中的 loading
  void _closePaymentLoading() {
    paymentId = null;
    if (_cancelLoading != null) {
      _cancelLoading!();
      _cancelLoading = null;
    }
  }

  /// 开始支付中的 loading
  void _startPaymentLoading() {
    _cancelLoading = BotToast.showCustomLoading(
      toastBuilder: (cancel) {
        return LoadingIndicator(
          message: AppLocale.processingWait.getString(context),
        );
      },
      allowClick: false,
      duration: const Duration(seconds: 120),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        elevation: 0,
        title: Text(
          AppLocale.buyCoins.getString(context),
          style: const TextStyle(
            fontSize: CustomSize.appBarTitleSize,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: customColors.weakLinkColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/setting');
            }
          },
        ),
        actions: [
          if (Ability().isUserLogon())
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                context.push('/quota-details');
              },
              child: Text(
                AppLocale.paymentHistory.getString(context),
                style: TextStyle(color: customColors.weakLinkColor),
                textScaler: const TextScaler.linear(0.9),
              ),
            ),
        ],
      ),
      backgroundColor: customColors.backgroundColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: BlocConsumer<PaymentBloc, PaymentState>(
              listener: (context, state) {
                if (state is PaymentAppleProductsLoaded) {
                  if (state.error != null) {
                    showErrorMessage(resolveError(context, state.error!));
                  } else {
                    if (state.localProducts.isEmpty) {
                      showErrorMessage('暂无可购买的产品');
                    } else {
                      final recommends = state.localProducts.where((e) => e.recommend).toList();
                      if (recommends.isNotEmpty && !state.loading) {
                        setState(() {
                          selectedProduct = state.products.firstWhere((e) => e.id == recommends.first.id);
                        });
                      }
                    }
                  }
                }
              },
              buildWhen: (previous, current) => current is PaymentAppleProductsLoaded,
              builder: (context, state) {
                if (state is! PaymentAppleProductsLoaded) {
                  return const Center(child: LoadingIndicator());
                }

                if (state.error != null) {
                  return Center(
                    child: Text(
                      state.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return Column(
                  children: [
                    Column(
                      children: [
                        for (var item in state.products)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedProduct = item;
                              });
                            },
                            child: PriceBlock(
                              customColors: customColors,
                              detail: item,
                              selectedProduct: selectedProduct,
                              product: state.localProducts.firstWhere((e) => e.id == item.id),
                              loading: state.loading,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (selectedProduct != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          state.localProducts.where((e) => e.id == selectedProduct!.id).first.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: customColors.weakTextColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: EnhancedButton(
                        title: '${AppLocale.toPay.getString(context)}   ${selectedProduct?.price ?? ''}',
                        onPressed: () async {
                          if (state.loading) {
                            showErrorMessage('价格加载中，请稍后');
                            return;
                          }
                          if (selectedProduct == null) {
                            showErrorMessage('请选择购买的产品');
                            return;
                          }

                          if (!Ability().isUserLogon()) {
                            showBeautyDialog(
                              context,
                              type: QuickAlertType.warning,
                              text: '该功能需要登录账号后使用',
                              onConfirmBtnTap: () {
                                context.pop();
                                context.push('/login');
                              },
                              showCancelBtn: true,
                              confirmBtnText: '立即登录',
                            );
                            return;
                          }

                          // 根据当前平台不通，调用不同的支付方式
                          if (PlatformTool.isAndroid()) {
                            handlePaymentForAndroid(
                              state,
                              context,
                              customColors,
                            );
                          } else if (PlatformTool.isIOS()) {
                            _startPaymentLoading();
                            try {
                              await createAppApplePay();
                            } catch (e) {
                              _closePaymentLoading();
                              // ignore: use_build_context_synchronously
                              showErrorMessage(resolveError(context, e));
                            }
                          } else if (PlatformTool.isWeb()) {
                            handlePaymentForWeb(state, context, customColors);
                          } else {
                            handlePaymentForPC(state, context, customColors);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state.note != null)
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '   购买说明：',
                              style: TextStyle(
                                fontSize: 12,
                                color: customColors.paymentItemTitleColor?.withOpacity(0.5),
                              ),
                            ),
                            Markdown(
                              data: state.note!,
                              textStyle: TextStyle(
                                color: customColors.paymentItemTitleColor?.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void handlePaymentForWeb(PaymentAppleProductsLoaded state, BuildContext context, CustomColors customColors) {
    // openConfirmDialog(
    //   context,
    //   '当前终端在线支付暂不可用，预计最晚 2023 年 10 月 15 日恢复，如需充值，请使用移动端 APP（支持 Android 手机、Apple 手机）。',
    //   () {
    //     launchUrlString(
    //       'https://aidea.aicode.cc',
    //       mode: LaunchMode.externalApplication,
    //     );
    //   },
    //   confirmText: '前往下载移动端 APP',
    // )

    final localProduct = state.localProducts.firstWhere((e) => e.id == selectedProduct!.id);

    final enableStripe = Ability().enableStripe && localProduct.supportStripe;

    openListSelectDialog(
      context,
      <SelectorItem>[
        if (Ability().enableWechatPay)
          SelectorItem(
            const PaymentMethodItem(
              title: Text('微信支付'),
              image: 'assets/wechat-pay.png',
            ),
            'wechat-pay',
          ),
        SelectorItem(
          const PaymentMethodItem(
            title: Text('支付宝扫码'),
            image: 'assets/zhifubao.png',
          ),
          'web',
        ),
        SelectorItem(
          const PaymentMethodItem(
            title: Text('支付宝手机版'),
            image: 'assets/zhifubao.png',
          ),
          'wap',
        ),
        if (enableStripe)
          SelectorItem(
            PaymentMethodItem(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Stripe'),
                  const SizedBox(width: 5),
                  Text(
                    '(${localProduct.retailPriceUSDText})',
                    style: TextStyle(
                      color: customColors.paymentItemTitleColor?.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              image: 'assets/stripe.png',
            ),
            'stripe',
          ),
      ],
      (value) {
        _startPaymentLoading();
        if (value.value == 'stripe') {
          createStripePayment(localProduct);
        } else if (value.value == 'wechat-pay') {
          createWechatPayment(localProduct);
        } else {
          createWebOrWapAlipay(source: value.value).onError((error, stackTrace) {
            _closePaymentLoading();
            showErrorMessageEnhanced(context, error!);
          });
        }

        return true;
      },
      title: '请选择支付方式',
      heightFactor: 0.4,
    );
  }

  /// 处理 PC 端支付
  void handlePaymentForPC(
    PaymentAppleProductsLoaded state,
    BuildContext context,
    CustomColors customColors,
  ) async {
    final localProduct = state.localProducts.firstWhere((e) => e.id == selectedProduct!.id);
    final enableStripe = Ability().enableStripe && localProduct.supportStripe;
    openListSelectDialog(
      context,
      <SelectorItem>[
        if (Ability().enableWechatPay)
          SelectorItem(
            const PaymentMethodItem(
              title: Text('微信支付'),
              image: 'assets/wechat-pay.png',
            ),
            'wechat-pay',
          ),
        if (Ability().enableOtherPay)
          SelectorItem(
            const PaymentMethodItem(
              title: Text('支付宝'),
              image: 'assets/zhifubao.png',
            ),
            'alipay',
          ),
        if (enableStripe)
          SelectorItem(
            PaymentMethodItem(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Stripe'),
                  const SizedBox(width: 5),
                  Text(
                    '(${localProduct.retailPriceUSDText})',
                    style: TextStyle(
                      color: customColors.paymentItemTitleColor?.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              image: 'assets/stripe.png',
            ),
            'stripe',
          ),
      ],
      (value) {
        _startPaymentLoading();

        if (value.value == 'alipay') {
          createWebOrWapAlipay(source: 'web').onError((error, stackTrace) {
            _closePaymentLoading();
            showErrorMessageEnhanced(context, error!);
          });
        } else if (value.value == 'wechat-pay') {
          createWechatPayment(localProduct);
        } else {
          createStripePayment(localProduct);
        }

        return true;
      },
      title: '请选择支付方式',
      heightFactor: 0.4,
    );
  }

  void handlePaymentForAndroid(
    PaymentAppleProductsLoaded state,
    BuildContext context,
    CustomColors customColors,
  ) {
    final localProduct = state.localProducts.firstWhere((e) => e.id == selectedProduct!.id);
    final enableStripe = Ability().enableStripe && localProduct.supportStripe;
    openListSelectDialog(
      context,
      <SelectorItem>[
        if (Ability().enableWechatPay)
          SelectorItem(
            const PaymentMethodItem(
              title: Text('微信支付'),
              image: 'assets/wechat-pay.png',
            ),
            'wechat-pay',
          ),
        if (Ability().enableOtherPay)
          SelectorItem(
            const PaymentMethodItem(
              title: Text('支付宝'),
              image: 'assets/zhifubao.png',
            ),
            'alipay',
          ),
        if (enableStripe)
          SelectorItem(
            PaymentMethodItem(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Stripe'),
                  const SizedBox(width: 5),
                  Text(
                    '(${localProduct.retailPriceUSDText})',
                    style: TextStyle(
                      color: customColors.paymentItemTitleColor?.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              image: 'assets/stripe.png',
            ),
            'stripe',
          ),
      ],
      (value) {
        _startPaymentLoading();

        if (value.value == 'alipay') {
          createAppAlipay().onError((error, stackTrace) {
            _closePaymentLoading();
            showErrorMessageEnhanced(context, error!);
          });
        } else if (value.value == 'wechat-pay') {
          createWechatPayment(localProduct);
        } else {
          createStripePayment(localProduct);
        }

        return true;
      },
      title: '请选择支付方式',
      heightFactor: 0.3,
    );
  }

  /// 创建苹果应用内支付
  Future<void> createAppApplePay() async {
    // 创建支付，服务端保存支付信息，创建支付订单
    paymentId = await APIServer().createApplePay(selectedProduct!.id);
    // 发起 Apple 支付
    InAppPurchase.instance.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: selectedProduct!),
    );
  }

  /// 创建其它付款（Web 或 Wap）
  Future<void> createWebOrWapAlipay({required String source}) async {
    final created = await APIServer().createOtherPay(
      selectedProduct!.id,
      source: source,
    );
    paymentId = created.paymentId;

    // 调起其它支付
    launchUrlString(created.params).then((value) {
      _closePaymentLoading();
      openConfirmDialog(
        context,
        '请确认支付宝支付是否已完成',
        () async {
          _startPaymentLoading();
          try {
            final resp = await APIServer().queryPaymentStatus(created.paymentId);
            if (resp.success) {
              showSuccessMessage(resp.note ?? '支付成功');
              _closePaymentLoading();
            } else {
              // 支付失败，延迟 5s 再次查询支付状态
              await Future.delayed(const Duration(seconds: 5), () async {
                try {
                  final value = await APIServer().queryPaymentStatus(created.paymentId);

                  if (value.success) {
                    showSuccessMessage(value.note ?? '支付成功');
                  } else {
                    showErrorMessage('支付未完成，我们接收到的状态为：${value.note}');
                  }
                  _closePaymentLoading();
                } catch (e) {
                  _closePaymentLoading();
                  // ignore: use_build_context_synchronously
                  showErrorMessage(resolveError(context, e));
                }
              });
            }
          } catch (e) {
            _closePaymentLoading();
            // ignore: use_build_context_synchronously
            showErrorMessage(resolveError(context, e));
          }
        },
        confirmText: '已完成支付',
        cancelText: '支付遇到问题，稍后继续',
      );
    });
  }

  /// 获取当前支付来源参数
  String paymentSource() {
    if (PlatformTool.isWeb()) {
      return 'web';
    } else if (PlatformTool.isIOS() || PlatformTool.isAndroid()) {
      return 'app';
    }
    return 'pc';
  }

  /// 创建微信支付
  Future<void> createWechatPayment(PaymentProduct product) async {
    try {
      final created = await APIServer().createWechatPayment(
        productId: product.id,
        source: paymentSource(),
      );
      paymentId = created.paymentId;

      if (PlatformTool.isAndroid() || PlatformTool.isIOS()) {
        await fluwx.payWithWeChat(
          appId: created.appId!,
          partnerId: created.partnerId!,
          prepayId: created.prepayId!,
          packageValue: created.package!,
          nonceStr: created.noncestr!,
          timeStamp: int.parse(created.timestamp!),
          sign: created.sign!,
        );
      } else {
        openDialog(
          // ignore: use_build_context_synchronously
          context,
          builder: Builder(builder: (context) {
            return Container(
              alignment: Alignment.center,
              height: 250,
              width: 220,
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: CustomSize.borderRadius,
                    child: QrImageView(
                      data: created.codeUrl!,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '请使用微信扫码支付',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          onSubmit: () {
            _startPaymentLoading();
            APIServer().queryPaymentStatus(created.paymentId).then((resp) {
              if (resp.success) {
                showSuccessMessage(resp.note ?? '支付成功');
                _closePaymentLoading();
              } else {
                // 支付失败，延迟 5s 再次查询支付状态
                Future.delayed(const Duration(seconds: 5), () async {
                  try {
                    final value = await APIServer().queryPaymentStatus(created.paymentId);

                    if (value.success) {
                      showSuccessMessage(value.note ?? '支付成功');
                    } else {
                      showErrorMessage('支付未完成，我们接收到的状态为：${value.note}');
                    }
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    showErrorMessage(resolveError(context, e));
                  } finally {
                    _closePaymentLoading();
                  }
                });
              }
            });

            return true;
          },
          confirmText: '已完成支付',
          barrierDismissible: false,
        );
      }
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      showErrorMessageEnhanced(context, e);
    } finally {
      _closePaymentLoading();
    }
  }

  /// 创建 Stripe 支付
  Future<void> createStripePayment(PaymentProduct product) async {
    try {
      final created = await APIServer().createStripePaymentSheet(
        productId: product.id,
        source: paymentSource(),
      );
      paymentId = created.paymentId;

      if (PlatformTool.isWeb() || PlatformTool.isAndroid() || PlatformTool.isIOS()) {
        Stripe.publishableKey = created.publishableKey;
        Stripe.urlScheme = 'flutterstripe';

        await Stripe.instance.applySettings();
      }

      if (PlatformTool.isWeb()) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return Scaffold(
                appBar: AppBar(),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Builder(
                            builder: (context) {
                              return PlatformPaymentElement(
                                created.paymentIntent,
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: EnhancedButton(
                          title: '确定付款（${product.retailPriceUSDText}）',
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
                              await pay(created.paymentId);
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
                  ),
                ),
              );
            },
          ),
        );
      } else if (PlatformTool.isAndroid() || PlatformTool.isIOS()) {
        // 调起 Stripe 支付
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: created.paymentIntent,
            merchantDisplayName: 'AIdea',
            customerId: created.customer,
            customerEphemeralKeySecret: created.ephemeralKey,
            returnURL: 'flutterstripe://redirect',
            // ignore: use_build_context_synchronously
            style: Ability().themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light,
          ),
        );

        // 确认支付
        await Stripe.instance.presentPaymentSheet();

        showSuccessMessage('购买成功');
      } else {
        // PC 端支付，发起 Web 页面
        if (created.proxyUrl == '') {
          showErrorMessage('支付失败：未能获取支付链接');
          return;
        }

        Logger.instance.d(created.proxyUrl);

        launchUrlString(
          created.proxyUrl,
          mode: LaunchMode.externalApplication,
        ).then((value) {
          _closePaymentLoading();
          openConfirmDialog(
            context,
            '请确认支付是否已完成',
            () async {
              _startPaymentLoading();
              try {
                final resp = await APIServer().queryPaymentStatus(created.paymentId);
                if (resp.success) {
                  showSuccessMessage(resp.note ?? '支付成功');
                  _closePaymentLoading();
                } else {
                  // 支付失败，延迟 5s 再次查询支付状态
                  await Future.delayed(const Duration(seconds: 5), () async {
                    try {
                      final value = await APIServer().queryPaymentStatus(created.paymentId);

                      if (value.success) {
                        showSuccessMessage(value.note ?? '支付成功');
                      } else {
                        showErrorMessage('支付未完成，我们接收到的状态为：${value.note}');
                      }
                      _closePaymentLoading();
                    } catch (e) {
                      _closePaymentLoading();
                      // ignore: use_build_context_synchronously
                      showErrorMessage(resolveError(context, e));
                    }
                  });
                }
              } catch (e) {
                _closePaymentLoading();
                // ignore: use_build_context_synchronously
                showErrorMessage(resolveError(context, e));
              }
            },
            confirmText: '已完成支付',
            cancelText: '支付遇到问题，稍后继续',
          );
        });
      }
    } on Exception catch (e) {
      if (e is StripeException) {
        showErrorMessage('支付失败：${e.error.localizedMessage}');
      } else {
        // ignore: use_build_context_synchronously
        showErrorMessageEnhanced(context, e);
      }
    } finally {
      _closePaymentLoading();
    }
  }

  /// 创建其它付款（App）
  Future<void> createAppAlipay() async {
    // 其它支付
    final created = await APIServer().createOtherPay(
      selectedProduct!.id,
      source: 'app',
    );
    paymentId = created.paymentId;

    // 沙箱环境支持
    final env = created.sandbox ? AliPayEvn.SANDBOX : AliPayEvn.ONLINE;

    // 调起其它支付
    final aliPayRes = await aliPay(
      created.params,
      evn: env,
    ).whenComplete(() => _closePaymentLoading());
    Logger.instance.d("=================");
    Logger.instance.d(aliPayRes);
    Logger.instance.d(aliPayRes["resultStatus"]);
    if (aliPayRes['resultStatus'] == '9000') {
      await APIServer().otherPayClientConfirm(
        aliPayRes.map((key, value) => MapEntry(key.toString(), value)),
      );

      showSuccessMessage('购买成功');
    } else {
      switch (aliPayRes['resultStatus']) {
        case 8000: // fall through
        case 6004:
          showErrorMessage('支付处理中，请稍后查看购买历史确认结果');
          break;
        case 4000:
          showErrorMessage('支付失败');
          break;
        case 5000:
          showErrorMessage('重复请求');
          break;
        case 6001:
          showErrorMessage('支付已取消');
          break;
        case 6002:
          showErrorMessage('网络连接出错');
          break;
        default:
          showErrorMessage('支付失败');
      }
    }
    Logger.instance.d("-----------------");
  }
}

/// 支付方式选择项
class PaymentMethodItem extends StatelessWidget {
  final Widget title;
  final String? image;

  const PaymentMethodItem({super.key, required this.title, this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (image != null) ...[
          ClipRRect(
            borderRadius: CustomSize.borderRadius,
            child: Image.asset(
              image!,
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 10),
        ],
        title,
      ],
    );
  }
}
