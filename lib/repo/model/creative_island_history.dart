class CreativeIslandHistory {
  int? id;
  String itemId;
  int? userId;
  String? arguments;
  String? prompt;
  String? answer;
  String? taskId;
  String? status;
  DateTime createdAt;

  CreativeIslandHistory(
    this.itemId, {
    this.id,
    this.userId,
    this.arguments,
    this.prompt,
    this.answer,
    DateTime? createdAt,
    this.taskId,
    this.status,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'user_id': userId,
      'arguments': arguments,
      'prompt': prompt,
      'answer': answer,
      'task_id': taskId,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  CreativeIslandHistory.fromJson(Map<String, Object?> map)
      : id = map['id'] as int?,
        itemId = map['item_id'] as String,
        userId = map['user_id'] as int?,
        arguments = map['arguments'] as String?,
        prompt = map['prompt'] as String?,
        answer = map['answer'] as String?,
        taskId = map['task_id'] as String?,
        status = map['status'] as String?,
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0);
}
