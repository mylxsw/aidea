import 'package:askaide/repo/api/room_gallery.dart';

enum PromotionEventClickButtonType {
  none,
  url,
  inAppRoute;

  static PromotionEventClickButtonType fromName(String typeName) {
    switch (typeName) {
      case 'url':
        return PromotionEventClickButtonType.url;
      case 'in_app_route':
        return PromotionEventClickButtonType.inAppRoute;
      default:
        return PromotionEventClickButtonType.none;
    }
  }

  String toName() {
    switch (this) {
      case PromotionEventClickButtonType.url:
        return 'url';
      case PromotionEventClickButtonType.inAppRoute:
        return 'in_app_route';
      default:
        return 'none';
    }
  }
}

class PromotionEvent {
  String? title;
  String content;
  PromotionEventClickButtonType clickButtonType;
  String? clickValue;
  String? clickButtonColor;
  String? backgroundImage;
  String? textColor;
  bool closeable;
  int? maxCloseDurationInDays;

  PromotionEvent({
    this.title,
    required this.content,
    required this.clickButtonType,
    this.clickValue,
    this.clickButtonColor,
    this.backgroundImage,
    this.textColor,
    required this.closeable,
    this.maxCloseDurationInDays,
  });

  toJson() => {
        'title': title,
        'content': content,
        'click_button_type': clickButtonType.toName(),
        'click_value': clickValue,
        'click_button_color': clickButtonColor,
        'background_image': backgroundImage,
        'text_color': textColor,
        'closeable': closeable,
        'max_close_duration_in_days': maxCloseDurationInDays,
      };

  static PromotionEvent fromJson(Map<String, dynamic> json) {
    return PromotionEvent(
      title: json['title'],
      content: json['content'],
      clickButtonType: PromotionEventClickButtonType.fromName(
          json['click_button_type'] ?? ''),
      clickValue: json['click_value'],
      clickButtonColor: json['click_button_color'],
      backgroundImage: json['background_image'],
      textColor: json['text_color'],
      closeable: json['closeable'] ?? false,
      maxCloseDurationInDays: json['max_close_duration_in_days'],
    );
  }
}

class ShareInfo {
  String qrCode;
  String message;
  String? inviteCode;

  ShareInfo({
    required this.qrCode,
    required this.message,
    this.inviteCode,
  });

  toJson() => {
        'qr_code': qrCode,
        'message': message,
        'invite_code': inviteCode,
      };

  static ShareInfo fromJson(Map<String, dynamic> json) {
    return ShareInfo(
      qrCode: json['qr_code'],
      message: json['message'],
      inviteCode: json['invite_code'],
    );
  }
}

class QuotaUsageInDay {
  String date;
  int used;

  QuotaUsageInDay({
    required this.date,
    required this.used,
  });

  toJson() => {
        'date': date,
        'used': used,
      };

  static QuotaUsageInDay fromJson(Map<String, dynamic> json) {
    return QuotaUsageInDay(
      date: json['date'],
      used: json['used'],
    );
  }
}

class QuotaUsageDetailInDay {
  int used;
  String type;
  String createdAt;

  QuotaUsageDetailInDay({
    required this.used,
    required this.type,
    required this.createdAt,
  });

  toJson() => {
        'used': used,
        'type': type,
        'created_at': createdAt,
      };

  static QuotaUsageDetailInDay fromJson(Map<String, dynamic> json) {
    return QuotaUsageDetailInDay(
      used: json['used'],
      type: json['type'],
      createdAt: json['created_at'],
    );
  }
}

class RoomsResponse {
  List<RoomInServer> rooms;
  List<RoomGallery>? suggests;

  RoomsResponse({
    required this.rooms,
    this.suggests,
  });

  toJson() => {
        'rooms': rooms,
        'suggests': suggests,
      };

  static RoomsResponse fromJson(Map<String, dynamic> json) {
    var rooms = <RoomInServer>[];
    for (var item in json['data'] ?? []) {
      rooms.add(RoomInServer.fromJson(item));
    }

    var suggests = <RoomGallery>[];
    for (var item in json['suggests'] ?? []) {
      suggests.add(RoomGallery.fromJson(item));
    }

    return RoomsResponse(
      rooms: rooms,
      suggests: suggests,
    );
  }
}

class RoomInServer {
  int id;
  int userId;
  int avatarId;
  String? avatarUrl;
  String name;
  String? description;
  int? priority;
  String model;
  String vendor;
  String? systemPrompt;
  String? initMessage;
  int maxContext;
  int? maxTokens;
  int? roomType;
  DateTime? lastActiveTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  List<String> members;

  RoomInServer({
    required this.id,
    required this.userId,
    required this.avatarId,
    required this.name,
    required this.maxContext,
    this.roomType,
    this.avatarUrl,
    this.description,
    this.priority,
    required this.model,
    required this.vendor,
    this.systemPrompt,
    this.initMessage,
    this.lastActiveTime,
    this.createdAt,
    this.updatedAt,
    this.maxTokens,
    this.members = const [],
  });

  toJson() => {
        'id': id,
        'user_id': userId,
        'avatar_id': avatarId,
        'avatar_url': avatarUrl,
        'name': name,
        'description': description,
        'priority': priority,
        'model': model,
        'vendor': vendor,
        'init_message': initMessage,
        'max_context': maxContext,
        'room_type': roomType,
        'max_tokens': maxTokens,
        'system_prompt': systemPrompt,
        'last_active_time': lastActiveTime?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'members': members,
      };

  static RoomInServer fromJson(Map<String, dynamic> json) {
    return RoomInServer(
      id: json['id'],
      userId: json['user_id'],
      avatarId: json['avatar_id'] ?? 0,
      avatarUrl: json['avatar_url'],
      name: json['name'],
      description: json['description'],
      priority: json['priority'],
      model: json['model'] ?? '',
      vendor: json['vendor'] ?? '',
      systemPrompt: json['system_prompt'],
      initMessage: json['init_message'],
      maxContext: json['max_context'] ?? 10,
      maxTokens: json['max_tokens'],
      roomType: json['room_type'],
      lastActiveTime: json['last_active_time'] != null
          ? DateTime.parse(json['last_active_time'])
          : null,
      createdAt:
          json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      updatedAt:
          json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class VersionCheckResp {
  bool hasUpdate;
  String serverVersion;
  bool forceUpdate;
  String url;
  String message;

  VersionCheckResp({
    required this.hasUpdate,
    required this.serverVersion,
    required this.forceUpdate,
    required this.url,
    required this.message,
  });

  toJson() => {
        'has_update': hasUpdate,
        'server_version': serverVersion,
        'force_update': forceUpdate,
        'url': url,
        'message': message,
      };

  static VersionCheckResp fromJson(Map<String, dynamic> json) {
    return VersionCheckResp(
      hasUpdate: json['has_update'] ?? false,
      serverVersion: json['server_version'],
      forceUpdate: json['force_update'] ?? false,
      url: json['url'],
      message: json['message'],
    );
  }
}

class SignInResp {
  int id;
  String name;
  String? email;
  String? phone;
  String token;
  bool isNewUser;
  int reward;

  SignInResp({
    required this.id,
    required this.name,
    this.email,
    required this.token,
    this.phone,
    this.isNewUser = false,
    this.reward = 0,
  });

  toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'token': token,
        'is_new_user': isNewUser,
        'reward': reward,
      };

  bool get needBindPhone => phone == null || phone!.isEmpty;

  static SignInResp fromJson(Map<String, dynamic> json) {
    return SignInResp(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      token: json['token'],
      isNewUser: json['is_new_user'] ?? false,
      reward: json['reward'] ?? 0,
    );
  }
}

class AsyncTaskResp {
  String status;
  List<String>? errors;
  List<String>? resources;
  String? originImage;

  AsyncTaskResp(this.status, {this.errors, this.resources, this.originImage});

  toJson() => {
        'status': status,
        'errors': errors,
        'resources': resources,
        'origin_image': originImage,
      };

  static AsyncTaskResp fromJson(Map<String, dynamic> json) {
    return AsyncTaskResp(
      json['status'],
      errors: json['errors'] != null
          ? (json['errors'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      resources: json['resources'] != null
          ? (json['resources'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : null,
      originImage: json['origin_image'],
    );
  }
}

class Prompt {
  String title;
  String content;

  Prompt(this.title, this.content);

  toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }
}

class ChatExample {
  String title;
  String? content;
  List<String> models;
  List<String> tags;

  ChatExample(
    this.title, {
    this.content,
    this.models = const [],
    this.tags = const [],
  });

  get text => content ?? title;

  toJson() => {
        'title': title,
        'content': content,
        'models': models,
        'tags': tags,
      };

  fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    models = json['models'];
    tags = json['tags'];
  }
}

class TranslateText {
  String? result;
  String? speakUrl;

  TranslateText(this.result, this.speakUrl);

  toJson() => {
        'result': result,
        'speak_url': speakUrl,
      };

  static fromJson(Map<String, dynamic> json) {
    return TranslateText(json['result'], json['speak_url']);
  }
}

class UploadInitResponse {
  String bucket;
  String key;
  String token;
  String url;

  UploadInitResponse(this.key, this.bucket, this.token, this.url);

  toJson() => {
        'bucket': bucket,
        'key': key,
        'token': token,
        'url': url,
      };

  static fromJson(Map<String, dynamic> json) {
    return UploadInitResponse(
      json['key'],
      json['bucket'],
      json['token'],
      json['url'],
    );
  }
}

class ModelStyle {
  String id;
  String name;
  String? preview;

  ModelStyle({required this.id, required this.name, this.preview});

  toJson() => {
        'id': id,
        'name': name,
        'preview': preview,
      };

  static ModelStyle fromJson(Map<String, dynamic> json) {
    return ModelStyle(
      id: json['id'],
      name: json['name'],
      preview: json['preview'],
    );
  }
}

class Model {
  String id;
  String name;
  String shortName;
  String? description;
  String category;
  bool isChat;
  bool isImage;
  bool disabled;
  String? tag;
  String? avatarUrl;
  bool supportVision;

  String get realModelId {
    return id.split(':').last;
  }

  Model({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.isChat,
    required this.isImage,
    this.description,
    this.disabled = false,
    this.tag,
    this.avatarUrl,
    this.supportVision = false,
  });

  toJson() => {
        'id': id,
        'name': name,
        'short_name': shortName,
        'description': description,
        'category': category,
        'is_chat': isChat,
        'is_image': isImage,
        'disabled': disabled,
        'tag': tag,
        'avatar_url': avatarUrl,
        'support_vision': supportVision,
      };

  static Model fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'] ?? json['name'],
      description: json['description'],
      category: json['category'],
      isChat: json['is_chat'],
      isImage: json['is_image'],
      disabled: json['disabled'] ?? false,
      tag: json['tag'],
      avatarUrl: json['avatar_url'],
      supportVision: json['support_vision'] ?? false,
    );
  }
}

class BackgroundImage {
  String url;
  String preview;

  BackgroundImage(this.url, this.preview);

  toJson() => {
        'url': url,
        'preview': preview,
      };

  static BackgroundImage fromJson(Map<String, dynamic> json) {
    return BackgroundImage(
      json['url'],
      json['preview'],
    );
  }
}

class UserExistenceResp {
  bool exist;
  String signInMethod;

  UserExistenceResp(this.exist, this.signInMethod);

  toJson() => {
        'exist': exist,
        'sign_in_method': signInMethod,
      };

  static UserExistenceResp fromJson(Map<String, dynamic> json) {
    return UserExistenceResp(
      json['exist'],
      json['sign_in_method'],
    );
  }
}

class PromptCategory {
  String name;
  List<PromptCategory> children;
  List<PromptTag> tags;

  PromptCategory(this.name, this.children, this.tags);

  toJson() => {
        'name': name,
        'children': children,
        'tags': tags,
      };

  static PromptCategory fromJson(Map<String, dynamic> json) {
    var children = <PromptCategory>[];
    for (var item in json['children'] ?? []) {
      children.add(PromptCategory.fromJson(item));
    }

    var tags = <PromptTag>[];
    for (var item in json['tags'] ?? []) {
      tags.add(PromptTag.fromJson(item));
    }

    return PromptCategory(
      json['name'],
      children,
      tags,
    );
  }
}

class PromptTag {
  String name;
  String value;

  PromptTag(this.name, this.value);

  toJson() => {
        'name': name,
        'value': value,
      };

  static PromptTag fromJson(Map<String, dynamic> json) {
    return PromptTag(
      json['name'],
      json['value'],
    );
  }
}

class FreeModelCount {
  String model;
  String name;
  int leftCount;
  int maxCount;
  String? info;

  FreeModelCount({
    required this.model,
    required this.name,
    required this.leftCount,
    required this.maxCount,
    this.info,
  });

  toJson() => {
        'model': model,
        'name': name,
        'left_count': leftCount,
        'max_count': maxCount,
        'info': info,
      };

  static FreeModelCount fromJson(Map<String, dynamic> json) {
    return FreeModelCount(
      model: json['model'],
      name: json['name'] ?? json['model'],
      leftCount: json['left_count'] ?? 0,
      maxCount: json['max_count'] ?? 0,
      info: json['info'],
    );
  }
}
