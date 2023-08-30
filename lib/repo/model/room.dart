import 'package:askaide/helper/constant.dart';

/// 聊天室
class Room {
  /// 聊天室 ID
  int? id;

  /// 用户 ID
  int? userId;

  /// 头像 ID
  int? avatarId;

  /// 头像链接
  String? avatarUrl;

  /// 聊天室名称
  String name;

  /// 聊天室类别
  String category;

  /// 显示优先级（排序，值越大越靠前）
  int priority;

  /// 聊天室采用的模型
  String model;

  /// 模型初始化消息
  String? initMessage;

  /// 模型最大上下文数量
  int maxContext;

  /// 模型最大返回 Token 数量
  int? maxTokens;

  /// room 类型：local or remote
  bool? localRoom;

  bool get isLocalRoom => localRoom ?? false;

  /// 聊天室头像 标识
  int get avatar => (avatarId == null || avatarId == 0) ? 0 : avatarId!;

  /// 模型类别
  String modelCategory() {
    final segs = model.split(':');
    if (segs.length == 1) {
      return 'openai';
    }

    return segs[0];
  }

  /// 模型名称
  String modelName() {
    final segs = model.split(':');
    if (segs.length == 1) {
      return segs[0];
    }

    return segs[1];
  }

  /// 聊天室图标
  String? iconData;

  /// 聊天室图标颜色
  String? color;

  /// 聊天室描述
  String? description;

  /// 系统提示
  String? systemPrompt;

  /// 聊天室创建时间
  DateTime? createdAt;

  /// 聊天室最后活跃时间
  DateTime? lastActiveTime;

  Room(this.name, this.category,
      {this.description,
      this.id,
      this.userId,
      this.avatarId,
      this.avatarUrl,
      this.createdAt,
      this.lastActiveTime,
      this.iconData,
      this.systemPrompt,
      this.priority = 0,
      this.color,
      this.initMessage,
      this.localRoom,
      this.maxContext = 10,
      this.maxTokens,
      this.model = defaultChatModel});

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'model': model,
      'priority': priority,
      'icon_data': iconData,
      'color': color,
      'description': description,
      'system_prompt': systemPrompt,
      'init_message': initMessage,
      'max_context': maxContext,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'last_active_time': lastActiveTime?.millisecondsSinceEpoch,
    };
  }

  Room.fromMap(Map<String, Object?> map)
      : id = map['id'] as int,
        userId = map['user_id'] as int?,
        avatarId = map['avatar_id'] as int?,
        avatarUrl = map['avatar_url'] as String?,
        name = map['name'] as String,
        category = map['category'] as String,
        priority = map['priority'] as int,
        model = map['model'] as String,
        iconData = map['icon_data'] as String?,
        color = map['color'] as String?,
        systemPrompt = map['system_prompt'] as String?,
        description = map['description'] as String?,
        initMessage = map['init_message'] as String?,
        maxContext = map['max_context'] as int? ?? 10,
        maxTokens = map['max_tokens'] as int?,
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
        lastActiveTime = DateTime.fromMillisecondsSinceEpoch(
            map['last_active_time'] as int? ?? 0);
}
