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

class AppleProduct {
  String id;
  String name;
  int quota;
  int retailPrice;
  String expirePolicy;
  String expirePolicyText;
  bool recommend;
  String? description;

  AppleProduct({
    required this.id,
    required this.name,
    required this.quota,
    required this.retailPrice,
    required this.expirePolicy,
    required this.expirePolicyText,
    this.recommend = false,
    this.description,
  });

  String get retailPriceText => '¥${(retailPrice / 100).toStringAsFixed(0)}';

  toJson() => {
        'id': id,
        'name': name,
        'quota': quota,
        'retail_price': retailPrice,
        'expire_policy': expirePolicy,
        'expire_policy_text': expirePolicyText,
        'recommend': recommend,
        'description': description,
      };

  static AppleProduct fromJson(Map<String, dynamic> json) {
    return AppleProduct(
      id: json['id'],
      name: json['name'],
      quota: json['quota'],
      retailPrice: json['retail_price'],
      expirePolicy: json['expire_policy'],
      expirePolicyText: json['expire_policy_text'],
      recommend: json['recommend'] ?? false,
      description: json['description'],
    );
  }
}

class ApplePayProducts {
  final List<AppleProduct> consume;
  final String? note;

  ApplePayProducts(this.consume, {this.note});

  toJson() => {
        'consume': consume,
        'note': note,
      };

  static ApplePayProducts fromJson(Map<String, dynamic> json) {
    return ApplePayProducts(
      (json['consume'] as List<dynamic>)
          .map((e) => AppleProduct.fromJson(e))
          .toList(),
      note: json['note'],
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
