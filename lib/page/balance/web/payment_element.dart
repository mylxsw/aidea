import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<PaymentIntent> pay(String paymentId, {String? action}) async {
  throw UnimplementedError();
}

void closeWindow() {
  throw UnimplementedError();
}

class PlatformPaymentElement extends StatelessWidget {
  const PlatformPaymentElement(this.clientSecret, {super.key});

  final String? clientSecret;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
