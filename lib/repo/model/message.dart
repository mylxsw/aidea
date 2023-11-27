import 'dart:convert';

import 'package:askaide/helper/helper.dart';

/// 聊天消息
class Message {
  /// 聊天所属的聊天室 ID
  int? roomId;

  /// 用户ID
  int? userId;

  /// 聊天历史 ID
  int? chatHistoryId;

  /// 消息ID
  int? id;

  /// 消息方向
  Role role;

  /// 消息内容
  String text;

  /// 消息附加信息，用于提供模型相关信息
  String? extra;

  /// 消息发送时的模型
  String? model;

  /// 消息类型
  MessageType type;

  /// 发送者
  String? user;

  /// 时间戳
  DateTime? ts;

  /// 关联消息ID（问题 ID）
  int? refId;

  /// 服务端 ID
  int? serverId;

  /// 消息状态: 1-成功 0-等待应答 2-失败
  int status;

  /// 消息消耗的配额
  int? quotaConsumed;

  /// 消息消耗的 token
  int? tokenConsumed;

  /// 是否当前消息已就绪，不需要持久化
  bool isReady = true;

  /// 消息发送者的头像，不需要持久化
  String? avatarUrl;

  /// 消息发送者的名称，不需要持久化
  String? senderName;

  /// 消息图片列表
  List<String>? images;

  Message(
    this.role,
    this.text, {
    required this.type,
    this.userId,
    this.chatHistoryId,
    this.id,
    this.user,
    this.ts,
    this.model,
    this.roomId,
    this.extra,
    this.refId,
    this.serverId,
    this.status = 1,
    this.quotaConsumed,
    this.tokenConsumed,
    this.avatarUrl,
    this.senderName,
    this.images,
  });

  /// 获取消息附加信息
  void setExtra(dynamic data) {
    extra = jsonEncode(data);
  }

  /// 获取消息附加信息
  decodeExtra() {
    if (extra == null) {
      return null;
    }

    return jsonDecode(extra!);
  }

  /// 是否是系统消息，包括时间线
  bool isSystem() {
    return type == MessageType.system ||
        type == MessageType.timeline ||
        type == MessageType.contextBreak;
  }

  /// 是否是初始消息
  bool isInitMessage() {
    return type == MessageType.initMessage;
  }

  /// 是否是时间线
  bool isTimeline() {
    return type == MessageType.timeline;
  }

  /// 格式化时间
  String friendlyTime() {
    return humanTime(ts);
  }

  /// 是否已失败
  bool statusIsFailed() {
    return status == 2;
  }

  /// 是否已成功
  bool statusIsSucceed() {
    return status == 1;
  }

  /// 是否等待应答
  bool statusPending() {
    return status == 0;
  }

  String get markdownWithImages {
    var t = text;
    if (images != null && images!.isNotEmpty) {
      t = images!.map((e) => '![img]($e)\n\n').join('') + t;
    }

    return t;
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'chat_history_id': chatHistoryId,
      'role': role.getRoleText(),
      'text': text,
      'type': type.getTypeText(),
      'extra': extra,
      'model': model,
      'user': user,
      'ts': ts?.millisecondsSinceEpoch,
      'room_id': roomId,
      'ref_id': refId,
      'server_id': serverId,
      'status': status,
      'token_consumed': tokenConsumed,
      'quota_consumed': quotaConsumed,
      'images': images != null ? jsonEncode(images) : null,
    };
  }

  Message.fromMap(Map<String, Object?> map)
      : id = map['id'] as int,
        userId = map['user_id'] as int?,
        chatHistoryId = map['chat_history_id'] as int?,
        role = Role.getRoleFromText(map['role'] as String),
        text = map['text'] as String,
        extra = map['extra'] as String?,
        model = map['model'] as String?,
        type = MessageType.getTypeFromText(map['type'] as String),
        user = map['user'] as String?,
        refId = map['ref_id'] as int?,
        serverId = map['server_id'] as int?,
        status = (map['status'] ?? 1) as int,
        tokenConsumed = map['token_consumed'] as int?,
        quotaConsumed = map['quota_consumed'] as int?,
        ts = map['ts'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['ts'] as int),
        roomId = map['room_id'] as int?,
        images = map['images'] == null
            ? null
            : (jsonDecode(map['images'] as String) as List<dynamic>)
                .cast<String>();
}

enum Role {
  receiver,
  sender;

  static Role getRoleFromText(String value) {
    switch (value) {
      case 'receiver':
        return Role.receiver;
      case 'assistant':
        return Role.receiver;
      case 'sender':
        return Role.sender;
      case 'user':
        return Role.sender;
      default:
        return Role.receiver;
    }
  }

  String getRoleText() {
    switch (this) {
      case Role.receiver:
        return 'receiver';
      case Role.sender:
        return 'sender';
      default:
        return 'receiver';
    }
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  location,
  command,
  system,
  timeline,
  contextBreak,
  hide,
  initMessage;

  String getTypeText() {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.audio:
        return 'audio';
      case MessageType.video:
        return 'video';
      case MessageType.location:
        return 'location';
      case MessageType.command:
        return 'command';
      case MessageType.system:
        return 'system';
      case MessageType.timeline:
        return 'timeline';
      case MessageType.contextBreak:
        return 'contextBreak';
      case MessageType.hide:
        return 'hide';
      case MessageType.initMessage:
        return 'initMessage';
      default:
        return 'text';
    }
  }

  static MessageType getTypeFromText(String value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'location':
        return MessageType.location;
      case 'command':
        return MessageType.command;
      case 'system':
        return MessageType.system;
      case 'timeline':
        return MessageType.timeline;
      case 'contextBreak':
        return MessageType.contextBreak;
      case 'hide':
        return MessageType.hide;
      case 'initMessage':
        return MessageType.initMessage;
      default:
        return MessageType.text;
    }
  }
}
