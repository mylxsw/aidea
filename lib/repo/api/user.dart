import 'package:askaide/repo/api/quota.dart';

class User {
  int id;
  String? name;
  String? email;
  String? phone;
  String? inviteCode;
  String? avatar;
  int? invitedBy;
  String? unionId;

  User(
    this.id,
    this.name,
    this.email,
    this.phone, {
    this.inviteCode,
    this.avatar,
    this.invitedBy,
    this.unionId,
  });

  /// 是否需要绑定手机号码
  bool get needBindPhone => phone == null || phone!.isEmpty;

  String displayName() {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }

    if (email != null && email!.isNotEmpty) {
      return email!;
    }

    if (phone != null && phone!.isNotEmpty) {
      return phone!;
    }

    return '-';
  }

  toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'invite_code': inviteCode,
        'avatar': avatar,
        'invited_by': invitedBy,
        'union_id': unionId,
      };

  static fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['name'],
      json['email'],
      json['phone'],
      inviteCode: json['invite_code'],
      avatar: json['avatar'],
      invitedBy: json['invited_by'],
      unionId: json['union_id'],
    );
  }
}

class UserInfo {
  User user;
  Quota quota;
  UserControl control;

  bool get showInviteMessage =>
      control.enableInvite && user.inviteCode != null && user.inviteCode != '';

  UserInfo(this.user, this.quota, this.control);

  toJson() => {
        'user': user.toJson(),
        'quota': quota.toJson(),
        'control': control.toJson(),
      };

  static fromJson(Map<String, dynamic> json) {
    return UserInfo(
      User.fromJson(json['user']),
      Quota.fromJson(json['quota']),
      UserControl.fromJson(json['control']),
    );
  }

  static UserInfo empty() {
    return UserInfo(
      User(0, "-", "-", "-"),
      Quota(0, 0, 0),
      UserControl(enableInvite: true),
    );
  }
}

class UserControl {
  bool isSetPassword;
  bool enableInvite;
  String? inviteMessage;
  String? userCardBg;
  String? inviteCardBg;
  String? inviteCardColor;
  String? inviteCardSlogan;
  bool withLab;

  UserControl({
    required this.enableInvite,
    this.inviteMessage,
    this.userCardBg,
    this.inviteCardBg,
    this.inviteCardColor,
    this.inviteCardSlogan,
    this.isSetPassword = false,
    this.withLab = false,
  });

  toJson() => {
        'enable_invite': enableInvite,
        'invite_message': inviteMessage,
        'user_card_bg': userCardBg,
        'invite_card_bg': inviteCardBg,
        'invite_card_color': inviteCardColor,
        'invite_card_slogan': inviteCardSlogan,
        'is_set_password': isSetPassword,
        'with_lab': withLab,
      };

  static UserControl fromJson(Map<String, dynamic> json) {
    return UserControl(
      enableInvite: json['enable_invite'] ?? true,
      inviteMessage: json['invite_message'],
      userCardBg: json['user_card_bg'],
      inviteCardBg: json['invite_card_bg'],
      inviteCardColor: json['invite_card_color'],
      inviteCardSlogan: json['invite_card_slogan'],
      isSetPassword: json['is_set_pwd'] ?? false,
      withLab: json['with_lab'] ?? false,
    );
  }
}
