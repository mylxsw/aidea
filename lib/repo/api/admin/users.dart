class AdminUser {
  final int id;
  final String? email;
  final String? phone;
  final String? realname;
  final String? avatar;
  final String? unionId;
  final String? appleUid;
  final int? invitedBy;
  final String? inviteCode;
  final String? userType;
  final String? status;
  final String? preferSigninMethod;
  final DateTime? createdAt;

  AdminUser({
    required this.id,
    this.email,
    this.phone,
    this.realname,
    this.avatar,
    this.unionId,
    this.appleUid,
    this.invitedBy,
    this.inviteCode,
    required this.userType,
    this.preferSigninMethod,
    this.createdAt,
    this.status,
  });

  String get displayName {
    if (realname != null && realname!.isNotEmpty) {
      return realname!;
    }

    if (email != null && email!.isNotEmpty) {
      return email!;
    }

    if (phone != null && phone!.isNotEmpty) {
      return phone!;
    }

    return '-';
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      realname: json['realname'],
      avatar: json['avatar'],
      unionId: json['union_id'],
      appleUid: json['apple_uid'],
      invitedBy: json['invite_by'],
      inviteCode: json['invite_code'],
      userType: json['user_type'],
      preferSigninMethod: json['prefer_signin_method'],
      createdAt:
          json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'realname': realname,
      'avatar': avatar,
      'union_id': unionId,
      'apple_uid': appleUid,
      'invite_by': invitedBy,
      'invite_code': inviteCode,
      'user_type': userType,
      'prefer_signin_method': preferSigninMethod,
      'CreatedAt': createdAt?.toIso8601String(),
      'status': status,
    };
  }
}
