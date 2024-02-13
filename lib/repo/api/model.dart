/// 自定义首页模型
class HomeModelV2 {
  /// 类型：model/room_gallery/rooms/room_enterprise
  String type;
  String id;
  String name;
  String? avatarUrl;
  String? modelId;
  String? modelName;
  bool supportVision;

  HomeModelV2({
    required this.type,
    required this.id,
    required this.name,
    required this.supportVision,
    this.modelId,
    this.modelName,
    this.avatarUrl,
  });

  String get uniqueKey {
    return '$type|$id';
  }

  static HomeModelV2 fromJson(Map<String, dynamic> json) {
    return HomeModelV2(
      type: json['type'],
      id: json['id'],
      name: json['name'],
      modelId: json['model_id'],
      modelName: json['model_name'],
      supportVision: json['support_vision'] ?? false,
      avatarUrl: json['avatar_url'],
    );
  }

  toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'model_id': modelId,
        'model_name': modelName,
        'support_vision': supportVision,
        'avatar_url': avatarUrl,
      };
}
