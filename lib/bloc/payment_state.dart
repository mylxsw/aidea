part of 'payment_bloc.dart';

@immutable
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentAppleProductsLoaded extends PaymentState {
  final List<ProductDetails> products;
  final List<PaymentProduct> localProducts;
  final Object? error;
  final bool loading;
  final String? note;
  final bool preferUSD;

  PaymentAppleProductsLoaded(
    this.products, {
    this.note,
    required this.localProducts,
    this.error,
    required this.loading,
    this.preferUSD = false,
  });
}
