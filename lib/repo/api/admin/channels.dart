class AdminChannel {
  int? id;
  String name;
  String type;
  String? server;
  String? secret;

  AdminChannelMeta? meta;

  String get display {
    return name;
  }

  AdminChannel({
    this.id,
    required this.name,
    required this.type,
    this.server,
    this.secret,
    this.meta,
  });

  factory AdminChannel.fromJson(Map<String, dynamic> json) {
    return AdminChannel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      server: json['server'],
      secret: json['secret'],
      meta:
          json['meta'] != null ? AdminChannelMeta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'server': server,
      'secret': secret,
      'meta': meta?.toJson(),
    };
  }
}

class AdminChannelMeta {
  bool? usingProxy;
  bool? openaiAzure;
  String? openaiAzureAPIVersion;

  AdminChannelMeta({
    this.usingProxy,
    this.openaiAzure,
    this.openaiAzureAPIVersion,
  });

  factory AdminChannelMeta.fromJson(Map<String, dynamic> json) {
    return AdminChannelMeta(
      usingProxy: json['using_proxy'],
      openaiAzure: json['openai_azure'],
      openaiAzureAPIVersion: json['openai_azure_api_version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'using_proxy': usingProxy,
      'openai_azure': openaiAzure,
      'openai_azure_api_version': openaiAzureAPIVersion,
    };
  }
}

class AdminChannelAddReq {
  String name;
  String type;
  String? server;
  String? secret;

  AdminChannelMeta? meta;

  AdminChannelAddReq({
    required this.name,
    required this.type,
    this.server,
    this.secret,
    this.meta,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'server': server,
      'secret': secret,
      'meta': meta?.toJson(),
    };
  }
}

class AdminChannelUpdateReq {
  String? name;
  String? type;
  String? server;
  String? secret;

  AdminChannelMeta? meta;

  AdminChannelUpdateReq({
    this.name,
    this.type,
    this.server,
    this.secret,
    this.meta,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'server': server,
      'secret': secret,
      'meta': meta?.toJson(),
    };
  }
}

class AdminChannelType {
  String name;
  String? display;
  bool dynamicType;

  String get text {
    return display ?? name;
  }

  AdminChannelType({
    required this.name,
    this.display,
    required this.dynamicType,
  });

  factory AdminChannelType.fromJson(Map<String, dynamic> json) {
    return AdminChannelType(
      name: json['name'],
      display: json['display'],
      dynamicType: json['dynamic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'display': display,
      'dynamic': dynamicType,
    };
  }
}
