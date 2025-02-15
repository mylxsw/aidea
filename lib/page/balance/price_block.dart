import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/credit.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PriceBlock extends StatelessWidget {
  final CustomColors customColors;
  final ProductDetails detail;
  final ProductDetails? selectedProduct;
  final PaymentProduct product;
  final bool loading;

  const PriceBlock({
    super.key,
    required this.customColors,
    required this.detail,
    this.selectedProduct,
    required this.product,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: customColors.backgroundContainerColor,
            border: Border.all(
              color: (selectedProduct != null && selectedProduct!.id == detail.id)
                  ? customColors.linkColor ?? Colors.green
                  : customColors.paymentItemBackgroundColor!,
            ),
            borderRadius: CustomSize.borderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Credit(
                    count: product.quota,
                    color: customColors.paymentItemTitleColor,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 11,
                        color: Color.fromARGB(255, 224, 170, 7),
                      ),
                      const SizedBox(width: 1),
                      Text(
                        '${product.expirePolicyText} ${AppLocale.validDays.getString(context)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color.fromARGB(255, 224, 170, 7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              loading
                  ? const Text('加载中...')
                  : Text(
                      detail.price,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: customColors.linkColor,
                      ),
                    ),
            ],
          ),
        ),
        if (product.recommend)
          Positioned(
            right: 11,
            top: 6,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 224, 68, 7),
                borderRadius: BorderRadius.only(topRight: CustomSize.radius, bottomLeft: CustomSize.radius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: const Text(
                'Best Deal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          )
      ],
    );
  }
}
