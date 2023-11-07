import 'package:askaide/page/component/coin.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/payment.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PriceBlock extends StatelessWidget {
  final CustomColors customColors;
  final ProductDetails detail;
  final ProductDetails? selectedProduct;
  final AppleProduct product;
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
            color: customColors.paymentItemBackgroundColor,
            border: Border.all(
              color:
                  (selectedProduct != null && selectedProduct!.id == detail.id)
                      ? customColors.linkColor ?? Colors.green
                      : customColors.paymentItemBackgroundColor!,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Coin(
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
                        '${product.expirePolicyText}内有效',
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (detail.price != product.retailPriceText)
                          Text(
                            product.retailPriceText,
                            style: TextStyle(
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                              color: customColors.paymentItemDescriptionColor
                                  ?.withAlpha(200),
                            ),
                          ),
                        if (detail.price != product.retailPriceText)
                          const SizedBox(width: 10),
                        Text(
                          detail.price,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: customColors.linkColor,
                          ),
                        ),
                      ],
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
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
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
