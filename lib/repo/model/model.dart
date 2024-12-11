import 'dart:convert';

class Model {
  final String id;
  final String name;
  final String? shortName;
  final String ownedBy;
  String? description;
  String? priceInfo;
  bool isChatModel = false;
  bool disabled;
  String? avatarUrl;
  bool supportVision = false;

  String? tag;
  String? tagTextColor;
  String? tagBgColor;
  bool isNew = false;
  String category;

  bool isDefault;

  Model(
    this.id,
    this.name,
    this.ownedBy, {
    this.shortName,
    required this.category,
    this.description,
    this.priceInfo,
    this.isChatModel = false,
    this.disabled = false,
    this.tag,
    this.avatarUrl,
    this.supportVision = false,
    this.tagTextColor,
    this.tagBgColor,
    this.isNew = false,
    this.isDefault = false,
  });

  String uid() {
    return id;
  }

  Model copyWith({
    String? id,
    String? name,
    String? shortName,
    String? ownedBy,
    String? description,
    String? priceInfo,
    bool? isChatModel,
    bool? disabled,
    String? avatarUrl,
    bool? supportVision,
    String? tag,
    String? tagTextColor,
    String? tagBgColor,
    bool? isNew,
    String? category,
    bool? isDefault,
  }) {
    return Model(
      id ?? this.id,
      name ?? this.name,
      ownedBy ?? this.ownedBy,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      priceInfo: priceInfo ?? this.priceInfo,
      isChatModel: isChatModel ?? this.isChatModel,
      disabled: disabled ?? this.disabled,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      supportVision: supportVision ?? this.supportVision,
      tag: tag ?? this.tag,
      tagTextColor: tagTextColor ?? this.tagTextColor,
      tagBgColor: tagBgColor ?? this.tagBgColor,
      isNew: isNew ?? this.isNew,
      category: category ?? this.category,
      isDefault: isDefault ?? false,
    );
  }

  ModelPrice get modelPrice {
    if (priceInfo == null || priceInfo == '') {
      return ModelPrice(input: 0, output: 0, request: 0, note: '');
    }

    return ModelPrice.fromMap(jsonDecode(priceInfo!) as Map<String, dynamic>);
  }
}

class ModelPrice {
  final int input;
  final int output;
  final int request;
  final String note;

  bool get isFree {
    return input == output && input == 0 && request == 0;
  }

  bool get hasNote {
    return note != '';
  }

  ModelPrice({
    required this.input,
    required this.output,
    required this.request,
    required this.note,
  });

  ModelPrice.fromMap(Map<String, dynamic> map)
      : input = map['input'] ?? 0,
        output = map['output'] ?? 0,
        request = map['request'] ?? 0,
        note = map['note'] ?? '';
}
