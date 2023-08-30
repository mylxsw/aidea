class RoomGalleryResponse {
  List<RoomGallery> galleries;
  List<String> tags;

  RoomGalleryResponse({
    required this.galleries,
    required this.tags,
  });

  toJson() => {
        'galleries': galleries.map((e) => e.toJson()).toList(),
        'tags': tags,
      };

  static RoomGalleryResponse fromJson(Map<String, dynamic> json) {
    return RoomGalleryResponse(
      galleries: ((json['data'] ?? []) as List<dynamic>)
          .map((e) => RoomGallery.fromJson(e))
          .toList(),
      tags: ((json['tags'] ?? []) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class RoomGallery {
  int id;
  String name;
  String avatarUrl;
  String description;
  List<String> tags;

  RoomGallery({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.description,
    required this.tags,
  });

  toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
        'description': description,
        'tags': tags,
      };

  static RoomGallery fromJson(Map<String, dynamic> json) {
    return RoomGallery(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatar_url'] ?? '',
      description: json['description'] ?? '',
      tags: ((json['tags'] ?? []) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }
}
