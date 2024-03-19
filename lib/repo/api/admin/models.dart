class AdminModel {
  String modelId;
  String name;
  String? shortName;
  String? description;
  String? avatarUrl;
  int status;
  AdminModelMeta? meta;
  List<AdminModelProvider> providers;

  AdminModel({
    required this.modelId,
    required this.name,
    this.shortName,
    this.description,
    this.avatarUrl,
    required this.status,
    this.meta,
    required this.providers,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      modelId: json['modelId'],
      name: json['name'],
      shortName: json['shortName'],
      description: json['description'],
      avatarUrl: json['avatarUrl'],
      status: json['status'],
      meta: json['meta'] != null ? AdminModelMeta.fromJson(json['meta']) : null,
      providers: ((json['providers'] ?? []) as List)
          .map((e) => AdminModelProvider.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'name': name,
      'shortName': shortName,
      'description': description,
      'avatarUrl': avatarUrl,
      'status': status,
      'meta': meta?.toJson(),
      'providers': providers.map((e) => e.toJson()).toList(),
    };
  }
}

class AdminModelMeta {
  bool? vision;
  bool? restricted;
  int? maxContext;
  int? inputPrice;
  int? outputPrice;

  AdminModelMeta({
    this.vision,
    this.restricted,
    this.maxContext,
    this.inputPrice,
    this.outputPrice,
  });

  factory AdminModelMeta.fromJson(Map<String, dynamic> json) {
    return AdminModelMeta(
      vision: json['vision'],
      restricted: json['restricted'],
      maxContext: json['maxContext'],
      inputPrice: json['inputPrice'],
      outputPrice: json['outputPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vision': vision,
      'restricted': restricted,
      'maxContext': maxContext,
      'inputPrice': inputPrice,
      'outputPrice': outputPrice,
    };
  }
}

class AdminModelProvider {
  int? id;
  String? name;
  String? modelRewrite;
  String? prompt;

  AdminModelProvider({
    this.id,
    this.name,
    this.modelRewrite,
    this.prompt,
  });

  factory AdminModelProvider.fromJson(Map<String, dynamic> json) {
    return AdminModelProvider(
      id: json['id'],
      name: json['name'],
      modelRewrite: json['modelRewrite'],
      prompt: json['prompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modelRewrite': modelRewrite,
      'prompt': prompt,
    };
  }
}

class AdminModelAddReq {
  String modelId;
  String name;
  String? shortName;
  String? description;
  String? avatarUrl;
  int status;
  AdminModelMeta? meta;
  List<AdminModelProvider>? providers;

  AdminModelAddReq({
    required this.modelId,
    required this.name,
    this.shortName,
    this.description,
    this.avatarUrl,
    required this.status,
    this.meta,
    this.providers,
  });

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'name': name,
      'shortName': shortName,
      'description': description,
      'avatarUrl': avatarUrl,
      'status': status,
      'meta': meta?.toJson(),
      'providers': providers?.map((e) => e.toJson()).toList(),
    };
  }
}

class AdminModelUpdateReq {
  String name;
  String? shortName;
  String? description;
  String? avatarUrl;
  int status;
  AdminModelMeta? meta;
  List<AdminModelProvider>? providers;

  AdminModelUpdateReq({
    required this.name,
    this.shortName,
    this.description,
    this.avatarUrl,
    required this.status,
    this.meta,
    this.providers,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortName': shortName,
      'description': description,
      'avatarUrl': avatarUrl,
      'status': status,
      'meta': meta?.toJson(),
      'providers': providers?.map((e) => e.toJson()).toList(),
    };
  }
}
