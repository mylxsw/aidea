class OtherPayCreatedReponse {
  String params;
  String paymentId;
  bool sandbox;

  OtherPayCreatedReponse(this.params, this.paymentId, {this.sandbox = false});

  toJson() => {
        'params': params,
        'payment_id': paymentId,
        'sandbox': sandbox,
      };

  static OtherPayCreatedReponse fromJson(Map<String, dynamic> json) {
    return OtherPayCreatedReponse(
      json['params'],
      json['payment_id'],
      sandbox: json['sandbox'] ?? false,
    );
  }
}

class PaymentProduct {
  String id;
  String name;
  int quota;
  int retailPrice;
  int retailPriceUSD;
  String expirePolicy;
  String expirePolicyText;
  bool recommend;
  String? description;

  PaymentProduct({
    required this.id,
    required this.name,
    required this.quota,
    required this.retailPrice,
    required this.expirePolicy,
    required this.expirePolicyText,
    this.recommend = false,
    this.description,
    this.retailPriceUSD = 0,
  });

  String get retailPriceText => '¥${(retailPrice / 100).toStringAsFixed(0)}';

  String get retailPriceUSDText =>
      '\$${(retailPriceUSD / 100).toStringAsFixed(2)}';

  toJson() => {
        'id': id,
        'name': name,
        'quota': quota,
        'retail_price': retailPrice,
        'retail_price_usd': retailPriceUSD,
        'expire_policy': expirePolicy,
        'expire_policy_text': expirePolicyText,
        'recommend': recommend,
        'description': description,
      };

  static PaymentProduct fromJson(Map<String, dynamic> json) {
    return PaymentProduct(
      id: json['id'],
      name: json['name'],
      quota: json['quota'],
      retailPrice: json['retail_price'],
      retailPriceUSD: json['retail_price_usd'] ?? 0,
      expirePolicy: json['expire_policy'],
      expirePolicyText: json['expire_policy_text'],
      recommend: json['recommend'] ?? false,
      description: json['description'],
    );
  }
}

class PaymentProducts {
  final List<PaymentProduct> consume;
  final String? note;
  final bool preferUSD;

  PaymentProducts(this.consume, {this.note, this.preferUSD = false});

  toJson() => {
        'consume': consume,
        'note': note,
        'prefer_usd': preferUSD,
      };

  static PaymentProducts fromJson(Map<String, dynamic> json) {
    return PaymentProducts(
      (json['consume'] as List<dynamic>)
          .map((e) => PaymentProduct.fromJson(e))
          .toList(),
      note: json['note'],
      preferUSD: json['prefer_usd'] ?? false,
    );
  }
}

class PaymentStatus {
  final bool success;
  final String? note;

  PaymentStatus(this.success, {this.note});

  toJson() => {
        'success': success,
        'note': note,
      };

  static PaymentStatus fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      json['success'],
      note: json['note'],
    );
  }
}

class StripePaymentCreatedResponse {
  final String paymentId;
  final String customer;
  final String paymentIntent;
  final String ephemeralKey;
  final String publishableKey;

  StripePaymentCreatedResponse(
    this.paymentId,
    this.customer,
    this.paymentIntent,
    this.ephemeralKey,
    this.publishableKey,
  );

  toJson() => {
        'payment_id': paymentId,
        'customer': customer,
        'payment_intent': paymentIntent,
        'ephemeral_key': ephemeralKey,
        'publishable_key': publishableKey,
      };

  static StripePaymentCreatedResponse fromJson(Map<String, dynamic> json) {
    return StripePaymentCreatedResponse(
      json['payment_id'],
      json['customer'],
      json['payment_intent'],
      json['ephemeral_key'],
      json['publishable_key'],
    );
  }
}
