class Model {
  final String id;
  final String name;
  final String? shortName;
  final String ownedBy;
  String? description;
  String category;
  bool isChatModel = false;
  bool disabled;
  String? tag;

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
  });

  String uid() {
    return '$category:$id';
  }
}
