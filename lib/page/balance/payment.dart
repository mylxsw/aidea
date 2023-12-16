import 'dart:async';

import 'package:askaide/bloc/payment_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/balance/price_block.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/markdown.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quickalert/models/quickalert_type.dart';

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
    final purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      showErrorMessage(resolveError(context, error));
    });

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
      Logger.instance.d({
        'status': purchaseDetails.status,
        'productID': purchaseDetails.productID,
        'purchaseID': purchaseDetails.purchaseID,
        'transactionDate': purchaseDetails.transactionDate,
        'verificationData': purchaseDetails.verificationData,
      });
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          await APIServer().updateApplePay(
            paymentId!,
            productId: purchaseDetails.productID,
            localVerifyData:
                purchaseDetails.verificationData.localVerificationData,
            serverVerifyData:
                purchaseDetails.verificationData.serverVerificationData,
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
              localVerifyData:
                  purchaseDetails.verificationData.localVerificationData,
              serverVerifyData:
                  purchaseDetails.verificationData.serverVerificationData,
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
        actions: [
          if (Ability().isUserLogon())
            TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                context.push('/quota-details');
              },
              child: Text(
                AppLocale.paymentHistory.getString(context),
                style: TextStyle(color: customColors.weakLinkColor),
                textScaleFactor: 0.9,
              ),
            ),
        ],
      ),
      backgroundColor: customColors.backgroundContainerColor,
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
                      final recommends = state.localProducts
                          .where((e) => e.recommend)
                          .toList();
                      if (recommends.isNotEmpty && !state.loading) {
                        setState(() {
                          selectedProduct = state.products
                              .firstWhere((e) => e.id == recommends.first.id);
                        });
                      }
                    }
                  }
                }
              },
              buildWhen: (previous, current) =>
                  current is PaymentAppleProductsLoaded,
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
                              product: state.localProducts
                                  .firstWhere((e) => e.id == item.id),
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
                          state.localProducts
                              .where((e) => e.id == selectedProduct!.id)
                              .first
                              .description!,
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
                        title:
                            '${AppLocale.toPay.getString(context)}   ${selectedProduct?.price ?? ''}',
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

                          _startPaymentLoading();
                          try {
                            await createAppApplePay();
                          } catch (e) {
                            _closePaymentLoading();
                            // ignore: use_build_context_synchronously
                            showErrorMessage(resolveError(context, e));
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '   购买说明：',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: customColors.paymentItemTitleColor
                                        ?.withOpacity(0.5),
                                  ),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  onPressed: () {
                                    _startPaymentLoading();
                                    // 恢复购买
                                    InAppPurchase.instance
                                        .restorePurchases()
                                        .whenComplete(() {
                                      _closePaymentLoading();
                                      showSuccessMessage('已恢复');
                                    });
                                  },
                                  child: Text(
                                    '恢复购买',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: customColors.paymentItemTitleColor
                                          ?.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Markdown(
                              data: state.note!,
                              textStyle: TextStyle(
                                color: customColors.paymentItemTitleColor
                                    ?.withOpacity(0.5),
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

  /// 创建苹果应用内支付
  Future<void> createAppApplePay() async {
    // 创建支付，服务端保存支付信息，创建支付订单
    paymentId = await APIServer().createApplePay(selectedProduct!.id);
    // 发起 Apple 支付
    InAppPurchase.instance.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: selectedProduct!),
    );
  }
}
