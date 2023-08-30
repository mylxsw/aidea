class AlipayCreatedReponse {
  String params;
  String paymentId;

  AlipayCreatedReponse(this.params, this.paymentId);

  toJson() => {
        'params': params,
        'payment_id': paymentId,
      };

  static AlipayCreatedReponse fromJson(Map<String, dynamic> json) {
    return AlipayCreatedReponse(
      json['params'],
      json['payment_id'],
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
