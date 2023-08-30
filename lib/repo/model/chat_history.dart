class ChatHistory {
  int? id;
  int? userId;
  int? roomId;
  String? title;
  String? lastMessage;
  String? model;
  DateTime? createdAt;
  DateTime? updatedAt;

  ChatHistory({
    this.id,
    this.userId,
    this.roomId,
    this.title,
    this.model,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
  });

  ChatHistory.fromMap(Map<String, Object?> map) {
    id = map['id'] as int?;
    userId = map['user_id'] as int?;
    roomId = map['room_id'] as int?;
    title = map['title'] as String?;
    model = map['model'] as String?;
    lastMessage = map['last_message'] as String?;
    createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int);
    updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int);
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': roomId,
      'title': title,
      'model': model,
      'last_message': lastMessage,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }
}
