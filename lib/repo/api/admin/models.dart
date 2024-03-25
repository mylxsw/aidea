class AdminModel {
  String modelId;
  String name;
  String? shortName;
  String? description;
  String? avatarUrl;
  int status;
  AdminModelMeta? meta;
  List<AdminModelProvider> providers;

  bool get isVision => meta?.vision ?? false;
  int get inputPrice => meta?.inputPrice ?? 0;
  int get outputPrice => meta?.outputPrice ?? 0;
  int get maxContext => meta?.maxContext ?? 0;

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
      modelId: json['model_id'],
      name: json['name'],
      shortName: json['short_name'],
      description: json['description'],
      avatarUrl: json['avatar_url'],
      status: json['status'],
      meta: json['meta'] != null ? AdminModelMeta.fromJson(json['meta']) : null,
      providers: ((json['providers'] ?? []) as List)
          .map((e) => AdminModelProvider.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      'name': name,
      'short_name': shortName,
      'description': description,
      'avatar_url': avatarUrl,
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
  String? prompt;

  AdminModelMeta({
    this.vision,
    this.restricted,
    this.maxContext,
    this.inputPrice,
    this.outputPrice,
    this.prompt,
  });

  factory AdminModelMeta.fromJson(Map<String, dynamic> json) {
    return AdminModelMeta(
      vision: json['vision'],
      restricted: json['restricted'],
      maxContext: json['max_context'],
      inputPrice: json['input_price'],
      outputPrice: json['output_price'],
      prompt: json['prompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vision': vision,
      'restricted': restricted,
      'max_context': maxContext,
      'input_price': inputPrice,
      'output_price': outputPrice,
      'prompt': prompt,
    };
  }
}

class AdminModelProvider {
  int? id;
  String? name;
  String? modelRewrite;

  AdminModelProvider({
    this.id,
    this.name,
    this.modelRewrite,
  });

  factory AdminModelProvider.fromJson(Map<String, dynamic> json) {
    return AdminModelProvider(
      id: json['id'],
      name: json['name'],
      modelRewrite: json['model_rewrite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model_rewrite': modelRewrite,
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
      'model_id': modelId,
      'name': name,
      'short_name': shortName,
      'description': description,
      'avatar_url': avatarUrl,
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
      'short_name': shortName,
      'description': description,
      'avatar_url': avatarUrl,
      'status': status,
      'meta': meta?.toJson(),
      'providers': providers?.map((e) => e.toJson()).toList(),
    };
  }
}
