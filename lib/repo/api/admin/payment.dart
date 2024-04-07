class AdminPaymentHistory {
  final int id;
  final int userId;
  final String paymentId;
  final String? source;
  final int quantity;
  final int retailPrice;
  final String environment;
  final DateTime purchaseAt;

  AdminPaymentHistory({
    required this.id,
    required this.userId,
    required this.paymentId,
    required this.quantity,
    required this.retailPrice,
    required this.environment,
    required this.purchaseAt,
    this.source,
  });

  factory AdminPaymentHistory.fromJson(Map<String, dynamic> json) {
    return AdminPaymentHistory(
      id: json['id'],
      userId: json['user_id'],
      paymentId: json['payment_id'],
      quantity: json['quantity'],
      retailPrice: json['retail_price'],
      environment: json['environment'],
      purchaseAt: DateTime.parse(json['purchase_at']),
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'payment_id': paymentId,
      'quantity': quantity,
      'retail_price': retailPrice,
      'environment': environment,
      'purchase_at': purchaseAt.toIso8601String(),
      'source': source,
    };
  }
}
