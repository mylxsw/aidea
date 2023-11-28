class NotifyMessage {
  int id;
  int articleId;
  String title;
  String content;
  String? type;
  DateTime? createdAt;

  NotifyMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.articleId,
    this.type,
    this.createdAt,
  });

  factory NotifyMessage.fromJson(Map<String, dynamic> json) {
    return NotifyMessage(
      id: json['id'],
      articleId: json['article_id'] ?? json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'title': title,
      'content': content,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
