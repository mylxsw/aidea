class UserAPIKey {
  int id;
  int? userId;
  String name;
  String token;
  int status;
  DateTime? validBefore;
  DateTime? createdAt;

  UserAPIKey({
    required this.id,
    this.userId,
    required this.name,
    required this.token,
    required this.status,
    this.validBefore,
    this.createdAt,
  });

  factory UserAPIKey.fromJson(Map<String, dynamic> json) {
    return UserAPIKey(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      token: json['token'],
      status: json['status'],
      validBefore: json['valid_before'] != null
          ? DateTime.parse(json['valid_before'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'token': token,
      'status': status,
      'valid_before': validBefore?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
