import 'package:askaide/helper/ability.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'dart:html' as html;
import 'package:stripe_js/stripe_api.dart' as js;

Future<PaymentIntent> pay(String paymentId) async {
  final currentUrl = Uri.parse(html.window.location.href);
  var href = Uri(
    scheme: currentUrl.scheme,
    host: currentUrl.host,
    port: currentUrl.port,
    fragment: '/payment/result?payment_id=$paymentId',
  ).toString();

  return await WebStripe.instance.confirmPaymentElement(
    ConfirmPaymentElementOptions(
      confirmParams: ConfirmPaymentParams(
        return_url: href,
      ),
    ),
  );
}

class PlatformPaymentElement extends StatelessWidget {
  const PlatformPaymentElement(this.clientSecret, {super.key});

  final String? clientSecret;

  @override
  Widget build(BuildContext context) {
    return PaymentElement(
      autofocus: true,
      enablePostalCode: true,
      onCardChanged: (_) {},
      clientSecret: clientSecret ?? '',
      appearance: js.ElementAppearance(
        theme: Ability().themeMode == 'dark'
            ? js.ElementTheme.night
            : js.ElementTheme.stripe,
      ),
    );
  }
}
