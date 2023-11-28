class Article {
  int id;
  String title;
  String content;
  String? author;
  String? type;
  DateTime? createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.author,
    this.type,
    this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      type: json['type'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
