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
  bool supportReasoning;
  bool supportSearch;

  HomeModelV2({
    required this.type,
    required this.id,
    required this.name,
    required this.supportVision,
    this.modelId,
    this.modelName,
    this.avatarUrl,
    this.supportReasoning = false,
    this.supportSearch = false,
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
      supportReasoning: json['support_reasoning'] ?? false,
      supportSearch: json['support_search'] ?? false,
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
        'support_reasoning': supportReasoning,
        'support_search': supportSearch,
        'avatar_url': avatarUrl,
      };
}
