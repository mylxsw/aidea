import 'package:askaide/helper/platform.dart';
import 'package:askaide/repo/api/payment.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meta/meta.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<PaymentLoadAppleProducts>((event, emit) async {
      if (PlatformTool.isIOS()) {
        final products = await APIServer().applePayProducts();
        if (products.consume.isEmpty) {
          emit(PaymentAppleProductsLoaded(
            const <ProductDetails>[],
            note: products.note,
            error: '没有任何可购买的项目',
            localProducts: const [],
            loading: false,
          ));
          return;
        }

        emit(PaymentAppleProductsLoaded(
            products.consume
                .map(
                  (e) => ProductDetails(
                    id: e.id,
                    title: e.name,
                    description: '',
                    price: '-',
                    rawPrice: 0,
                    currencyCode: '',
                  ),
                )
                .toList(),
            note: products.note,
            localProducts: products.consume,
            loading: true));

        final productIds = products.consume.map((e) => e.id).toSet();
        final response =
            await InAppPurchase.instance.queryProductDetails(productIds);
        if (response.notFoundIDs.isNotEmpty) {
          emit(PaymentAppleProductsLoaded(
            const <ProductDetails>[],
            note: products.note,
            localProducts: products.consume,
            error: '没有任何可购买的项目',
            loading: false,
          ));
          return;
        }

        final remoteProducts = <ProductDetails>[];
        for (var id in productIds) {
          remoteProducts.add(
            response.productDetails.firstWhere((element) => element.id == id),
          );
        }

        emit(PaymentAppleProductsLoaded(
          remoteProducts,
          note: products.note,
          localProducts: products.consume,
          loading: false,
        ));
      } else {
        final products = await APIServer().otherPayProducts();
        if (products.consume.isEmpty) {
          emit(PaymentAppleProductsLoaded(
            const <ProductDetails>[],
            note: products.note,
            error: '没有任何可购买的项目',
            localProducts: const [],
            loading: false,
          ));
          return;
        }

        emit(
          PaymentAppleProductsLoaded(
            products.consume
                .map(
                  (e) => ProductDetails(
                    id: e.id,
                    title: e.name,
                    description: '',
                    price: e.retailPriceText,
                    rawPrice: e.retailPrice.toDouble(),
                    currencyCode: '',
                  ),
                )
                .toList(),
            note: products.note,
            localProducts: products.consume,
            loading: false,
          ),
        );
      }
    });
  }
}
