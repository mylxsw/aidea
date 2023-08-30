import 'dart:convert';

class ImageModel {
  int id;
  String modelId;
  String modelName;
  String vendor;
  String? realModel;
  int? status;

  ImageModel({
    required this.id,
    required this.modelId,
    required this.modelName,
    required this.vendor,
    this.realModel,
    this.status,
  });

  toJson() => {
        'id': id,
        'model_id': modelId,
        'model_name': modelName,
        'vendor': vendor,
        'real_model': realModel,
        'status': status,
      };

  static ImageModel fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      modelId: json['model_id'],
      modelName: json['model_name'],
      vendor: json['vendor'],
      realModel: json['real_model'],
      status: json['status'],
    );
  }
}

class ImageModelFilter {
  int id;
  String name;
  String modelId;
  String? previewImage;
  int? status;
  String? meta;

  ImageModelFilter({
    required this.id,
    required this.name,
    required this.modelId,
    this.previewImage,
    this.status,
    this.meta,
  });

  toJson() => {
        'id': id,
        'name': name,
        'model_id': modelId,
        'preview_image': previewImage,
        'status': status,
        'meta': meta,
      };

  static ImageModelFilter fromJson(Map<String, dynamic> json) {
    return ImageModelFilter(
      id: json['id'],
      name: json['name'],
      modelId: json['model_id'],
      previewImage: json['preview_image'],
      status: json['status'],
      meta: jsonEncode(json['meta'] ?? {}),
    );
  }
}
