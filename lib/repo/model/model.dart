class Model {
  final String id;
  final String name;
  final String? shortName;
  final String ownedBy;
  String? description;
  bool isChatModel = false;
  bool disabled;
  String? avatarUrl;
  bool supportVision = false;

  String? tag;
  String? tagTextColor;
  String? tagBgColor;
  bool isNew = false;
  String category;

  Model(
    this.id,
    this.name,
    this.ownedBy, {
    this.shortName,
    required this.category,
    this.description,
    this.isChatModel = false,
    this.disabled = false,
    this.tag,
    this.avatarUrl,
    this.supportVision = false,
    this.tagTextColor,
    this.tagBgColor,
    this.isNew = false,
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
    bool? isChatModel,
    bool? disabled,
    String? avatarUrl,
    bool? supportVision,
    String? tag,
    String? tagTextColor,
    String? tagBgColor,
    bool? isNew,
    String? category,
  }) {
    return Model(
      id ?? this.id,
      name ?? this.name,
      ownedBy ?? this.ownedBy,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      isChatModel: isChatModel ?? this.isChatModel,
      disabled: disabled ?? this.disabled,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      supportVision: supportVision ?? this.supportVision,
      tag: tag ?? this.tag,
      tagTextColor: tagTextColor ?? this.tagTextColor,
      tagBgColor: tagBgColor ?? this.tagBgColor,
      isNew: isNew ?? this.isNew,
      category: category ?? this.category,
    );
  }
}
