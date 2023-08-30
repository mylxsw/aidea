import 'package:intl/intl.dart';

class QuotaEvaluated {
  int cost;
  bool enough;
  int? waitDuration;

  QuotaEvaluated({required this.cost, this.enough = true, this.waitDuration});

  toJson() => {
        'cost': cost,
        'enough': enough,
        'wait_duration': waitDuration,
      };

  static QuotaEvaluated fromJson(Map<String, dynamic> json) {
    return QuotaEvaluated(
      cost: json['cost'],
      enough: json['enough'] ?? true,
      waitDuration: json['wait_duration'],
    );
  }
}

class QuotaResp {
  int total;
  List<QuotaDetail> details;

  QuotaResp(this.total, this.details);

  toJson() => {
        'total': total,
        'details': details.map((e) => e.toJson()).toList(),
      };

  static QuotaResp fromJson(Map<String, dynamic> json) {
    return QuotaResp(
      json['total'],
      (json['details'] as List).map((e) => QuotaDetail.fromJson(e)).toList(),
    );
  }
}

class QuotaDetail {
  int id;
  int userId;
  int quota;
  int rest;
  String? note;
  DateTime periodStartAt;
  DateTime periodEndAt;
  bool expired;
  DateTime createdAt;

  QuotaDetail({
    required this.id,
    required this.userId,
    required this.quota,
    required this.rest,
    required this.periodStartAt,
    required this.periodEndAt,
    required this.expired,
    required this.createdAt,
    this.note,
  });

  toJson() => {
        'id': id,
        'user_id': userId,
        'quota': quota,
        'rest': rest,
        'period_start_at': periodStartAt.toIso8601String(),
        'period_end_at': periodEndAt.toIso8601String(),
        'expired': expired,
        'created_at': createdAt.toIso8601String(),
        'note': note,
      };

  static QuotaDetail fromJson(Map<String, dynamic> json) {
    return QuotaDetail(
      id: json['id'],
      userId: json['user_id'],
      quota: json['quota'],
      rest: json['rest'],
      note: json['note'],
      periodStartAt: DateTime.parse(json['period_start_at']),
      periodEndAt: DateTime.parse(json['period_end_at']),
      expired: json['expired'],
      createdAt: DateTime.parse(json['created_at'] ?? json['period_start_at']),
    );
  }
}

class Quota {
  int quota;
  int rest;
  int used;

  Quota(this.quota, this.used, this.rest);

  double quotaPercent() {
    return (used * 1.0) / quota;
  }

  int quotaRemain() {
    return quota - used;
  }

  String quotaRemainString() {
    return (quota - used).toString();
  }

  String quotaString() {
    return NumberFormat('0,000').format(quota);
  }

  String usedString() {
    return NumberFormat('0,000').format(used);
  }

  toJson() => {
        'quota': quota,
        'used': used,
        'rest': rest,
      };

  static fromJson(Map<String, dynamic> json) {
    return Quota(
      json['quota'],
      json['used'],
      json['rest'],
    );
  }
}
