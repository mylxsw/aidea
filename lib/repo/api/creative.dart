import 'dart:convert';

import 'package:intl/intl.dart';

class CreativeGalleryItemResponse {
  CreativeGallery item;
  bool isInternalUser;

  CreativeGalleryItemResponse(this.item, this.isInternalUser);

  toJson() => {
        'data': item.toJson(),
        'is_internal_user': isInternalUser,
      };

  static CreativeGalleryItemResponse fromJson(Map<String, dynamic> json) {
    return CreativeGalleryItemResponse(
      CreativeGallery.fromJson(json['data']),
      json['is_internal_user'] ?? false,
    );
  }
}

class CreativeGallery {
  int id;
  int? userId;
  String? username;
  int? creativeHistoryId;
  int creativeType;
  String creativeId;
  String? meta;
  String? prompt;
  String? negativePrompt;
  String? answer;
  int refCount;
  int starLevel;
  int hotValue;
  int status;
  DateTime? createdAt;
  DateTime? updatedAt;

  CreativeGallery({
    required this.id,
    this.userId,
    this.username,
    this.creativeHistoryId,
    required this.creativeType,
    required this.creativeId,
    this.meta,
    this.prompt,
    this.negativePrompt,
    this.answer,
    this.refCount = 0,
    this.starLevel = 0,
    this.hotValue = 0,
    this.status = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get metaMap {
    if (meta == null || meta!.isEmpty) {
      return {};
    }

    return jsonDecode(meta!);
  }

  List<String> get images {
    try {
      if (creativeType == 2 && answer != null && answer != '') {
        return (jsonDecode(answer!) as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'creative_history_id': creativeHistoryId,
        'creative_type': creativeType,
        'creative_id': creativeId,
        'meta': meta,
        'prompt': prompt,
        'negative_prompt': negativePrompt,
        'answer': answer,
        'ref_count': refCount,
        'star_level': starLevel,
        'hot_value': hotValue,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static CreativeGallery fromJson(Map<String, dynamic> json) {
    return CreativeGallery(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      creativeHistoryId: json['creative_history_id'],
      creativeType: json['creative_type'],
      creativeId: json['creative_id'] ?? 'text-to-image',
      meta: json['meta'],
      prompt: json['prompt'],
      negativePrompt: json['negative_prompt'],
      answer: json['answer'],
      refCount: json['ref_count'] ?? 0,
      starLevel: json['star_level'] ?? 0,
      hotValue: json['hot_value'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class CreativeIslandCapacity {
  bool showAIRewrite;
  bool showUpscaleBy;
  bool showNegativeText;
  bool showStyle;
  bool showSeed;
  bool showImageCount;
  bool showPromptForImage2Image;
  List<String> allowRatios;
  List<CreativeIslandVendorModel> vendorModels;
  List<String> allowUpscaleBy;
  bool showImageStrength;
  List<CreativeIslandImageFilter> filters;
  List<CreativeIslandArtisticStyle> artisticStyles;

  CreativeIslandCapacity({
    required this.showAIRewrite,
    required this.showUpscaleBy,
    required this.showNegativeText,
    required this.showSeed,
    required this.showStyle,
    required this.showImageCount,
    required this.allowRatios,
    required this.showPromptForImage2Image,
    this.vendorModels = const [],
    this.allowUpscaleBy = const [],
    this.showImageStrength = false,
    this.filters = const [],
    this.artisticStyles = const [],
  });

  toJson() => {
        'show_ai_rewrite': showAIRewrite,
        'show_upscale_by': showUpscaleBy,
        'show_negative_text': showNegativeText,
        'show_style': showStyle,
        'show_seed': showSeed,
        'show_image_count': showImageCount,
        'show_prompt_for_image2image': showPromptForImage2Image,
        'allow_ratios': allowRatios,
        'vendor_models': vendorModels.map((e) => e.toJson()).toList(),
        'allow_upscale_by': allowUpscaleBy,
        'show_image_strength': showImageStrength,
        'filters': filters.map((e) => e.toJson()).toList(),
        'artistic_styles': artisticStyles.map((e) => e.toJson()).toList(),
      };

  static CreativeIslandCapacity fromJson(Map<String, dynamic> json) {
    return CreativeIslandCapacity(
      showAIRewrite: json['show_ai_rewrite'] ?? false,
      showUpscaleBy: json['show_upscale_by'] ?? false,
      showNegativeText: json['show_negative_text'] ?? false,
      showStyle: json['show_style'] ?? false,
      showSeed: json['show_seed'] ?? false,
      showImageCount: json['show_image_count'] ?? false,
      showPromptForImage2Image: json['show_prompt_for_image2image'] ?? false,
      allowRatios: (json['allow_ratios'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      vendorModels: ((json['vendor_models'] ?? []) as List<dynamic>)
          .map((e) => CreativeIslandVendorModel.fromJson(e))
          .toList(),
      allowUpscaleBy: (json['allow_upscale_by'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      showImageStrength: json['show_image_strength'] ?? false,
      filters: ((json['filters'] ?? []) as List<dynamic>)
          .map((e) => CreativeIslandImageFilter.fromJson(e))
          .toList(),
      artisticStyles: ((json['artistic_styles'] ?? []) as List<dynamic>)
          .map((e) => CreativeIslandArtisticStyle.fromJson(e))
          .toList(),
    );
  }
}

class CreativeIslandArtisticStyle {
  String id;
  String name;
  String? previewImage;

  CreativeIslandArtisticStyle({
    required this.id,
    required this.name,
    this.previewImage,
  });

  toJson() => {
        'id': id,
        'name': name,
        'preview_image': previewImage,
      };

  static CreativeIslandArtisticStyle fromJson(Map<String, dynamic> json) {
    return CreativeIslandArtisticStyle(
      id: json['id'],
      name: json['name'],
      previewImage: json['preview_image'],
    );
  }
}

class CreativeIslandImageFilter {
  int id;
  String name;
  String? description;
  String previewImage;

  CreativeIslandImageFilter({
    required this.id,
    required this.name,
    required this.previewImage,
    this.description,
  });

  toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'preview_image': previewImage,
      };

  static CreativeIslandImageFilter fromJson(Map<String, dynamic> json) {
    return CreativeIslandImageFilter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      previewImage: json['preview_image'],
    );
  }
}

class CreativeIslandVendorModel {
  String id;
  String? vendor;
  String name;
  bool upscale;
  bool showStyle;
  bool showImageStrength;
  String? introUrl;

  CreativeIslandVendorModel({
    required this.id,
    required this.name,
    required this.upscale,
    this.vendor,
    this.showStyle = false,
    this.showImageStrength = false,
    this.introUrl,
  });

  toJson() => {
        'id': id,
        'name': name,
        'vendor': vendor,
        'upscale': upscale,
        'show_style': showStyle,
        'show_image_strength': showImageStrength,
        'intro_url': introUrl,
      };

  static CreativeIslandVendorModel fromJson(Map<String, dynamic> json) {
    return CreativeIslandVendorModel(
      id: json['id'],
      name: json['name'],
      vendor: json['vendor'],
      upscale: json['upscale'] ?? false,
      showStyle: json['show_style'] ?? false,
      showImageStrength: json['show_image_strength'] ?? false,
      introUrl: json['intro_url'],
    );
  }
}

class CreativeIslandCompletionResp {
  String content;
  String type;
  List<String> resources;

  CreativeIslandCompletionResp({
    required this.content,
    required this.type,
    this.resources = const [],
  });

  toJson() => {
        'content': content,
        'type': type,
        'resources': resources,
      };

  static CreativeIslandCompletionResp fromJson(Map<String, dynamic> json) {
    return CreativeIslandCompletionResp(
      content: json['content'],
      type: json['type'],
      resources: json['resources'] != null
          ? (json['resources'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
    );
  }
}

class CreativeIslandItems {
  List<CreativeIslandItem> items;
  List<String> categories;
  String? backgroundImage;

  CreativeIslandItems(this.items, this.categories, {this.backgroundImage});
}

class CreativeIslandItemExtSize {
  int width;
  int height;
  String aspectRatio;

  CreativeIslandItemExtSize({
    required this.width,
    required this.height,
    required this.aspectRatio,
  });

  toJson() => {
        'width': width,
        'height': height,
        'aspect_ratio': aspectRatio,
      };

  static CreativeIslandItemExtSize fromJson(Map<String, dynamic> json) {
    return CreativeIslandItemExtSize(
      width: json['width'],
      height: json['height'],
      aspectRatio: json['aspect_ratio'],
    );
  }
}

class CreativeIslandItemExtension {
  bool? aiRewrite;
  bool? showAIRewrite;
  String? upscaleBy;
  bool? showNegativeText;
  bool? showAdvanceButton;
  List<CreativeIslandItemExtSize>? allowSizes;

  CreativeIslandItemExtension({
    this.aiRewrite,
    this.showAIRewrite,
    this.upscaleBy,
    this.showNegativeText,
    this.allowSizes,
    this.showAdvanceButton,
  });

  toJson() => {
        'ai_rewrite': aiRewrite,
        'show_ai_rewrite': showAIRewrite,
        'upscale_by': upscaleBy,
        'show_negative_text': showNegativeText,
        'allow_sizes': allowSizes?.map((e) => e.toJson()).toList(),
        'show_advance_button': showAdvanceButton,
      };

  static CreativeIslandItemExtension fromJson(Map<String, dynamic> json) {
    return CreativeIslandItemExtension(
      aiRewrite: json['ai_rewrite'],
      showAIRewrite: json['show_ai_rewrite'],
      upscaleBy: json['upscale_by'],
      showNegativeText: json['show_negative_text'],
      showAdvanceButton: json['show_advance_button'],
      allowSizes: json['allow_sizes'] != null
          ? (json['allow_sizes'] as List<dynamic>)
              .map((e) => CreativeIslandItemExtSize.fromJson(e))
              .toList()
          : null,
    );
  }
}

class CreativeIslandItem {
  String id;
  String title;
  String? description;
  bool supportStream;
  List<String> categories;
  String vendor;
  String modelType;
  String? bgImage;
  String? bgEmbeddedImage;
  String? label;
  String? labelColor;
  String? titleColor;
  String? submitBtnText;
  String? promptInputTitle;
  int waitSeconds;
  bool showImageStyleSelector;
  bool noPrompt;

  String? hint;
  int? wordCount;
  CreativeIslandItemExtension? extension;

  /// 是否显示高级按钮
  bool get showAdvanceButton {
    if (extension != null && extension!.showAdvanceButton != null) {
      return extension!.showAdvanceButton!;
    }

    return false;
  }

  /// 返回支持的图片尺寸
  List<CreativeIslandItemExtSize> get imageAllowSizes {
    if (extension != null && extension!.allowSizes != null) {
      return extension!.allowSizes!;
    }

    return [];
  }

  /// 是否启用 AI 优化的默认值
  bool get aiRewriteDefaultValue {
    if (extension != null && extension!.aiRewrite != null) {
      return extension!.aiRewrite!;
    }

    return false;
  }

  /// 是否显示反向提示语输入框
  bool get isShowNegativeText {
    if (extension != null && extension!.showNegativeText != null) {
      return extension!.showNegativeText!;
    }

    return false;
  }

  /// 是否显示 AI 重写按钮
  bool get isShowAIRewrite {
    if (extension != null && extension!.showAIRewrite != null) {
      return extension!.showAIRewrite!;
    }

    return false;
  }

  CreativeIslandItem({
    required this.id,
    required this.title,
    required this.vendor,
    required this.modelType,
    this.categories = const [],
    this.supportStream = false,
    this.description,
    this.bgImage,
    this.bgEmbeddedImage,
    this.label,
    this.labelColor,
    this.titleColor,
    this.hint,
    this.wordCount,
    this.submitBtnText,
    this.promptInputTitle,
    this.waitSeconds = 30,
    this.showImageStyleSelector = false,
    this.noPrompt = false,
    this.extension,
  });

  toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'support_stream': supportStream,
        'model_type': modelType, // 'text-generation' | 'image-generation'
        'vendor': vendor,
        'categories': categories,
        'bg_image': bgImage,
        'bg_embedded_image': bgEmbeddedImage,
        'label': label,
        'label_color': labelColor,
        'title_color': titleColor,
        'hint': hint,
        'word_count': wordCount,
        'submit_btn_text': submitBtnText,
        'prompt_input_title': promptInputTitle,
        'wait_seconds': waitSeconds,
        'show_image_style_selector': showImageStyleSelector,
        'no_prompt': noPrompt,
        'extension': extension?.toJson(),
      };

  static fromJson(Map<String, dynamic> json) {
    return CreativeIslandItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      supportStream: json['support_stream'] ?? false,
      modelType: json['model_type'] ?? 'text-generation',
      vendor: json['vendor'],
      categories: ((json['category'] ?? '') as String).split(',').toList(),
      bgImage: json['bg_image'],
      bgEmbeddedImage: json['bg_embedded_image'],
      label: json['label'],
      labelColor: json['label_color'],
      titleColor: json['title_color'],
      hint: json['hint'],
      wordCount: json['word_count'] ?? 0,
      submitBtnText: json['submit_btn_text'],
      promptInputTitle: json['prompt_input_title'],
      waitSeconds: json['wait_seconds'] ?? 30,
      showImageStyleSelector: json['show_image_style_selector'] ?? false,
      noPrompt: json['no_prompt'] ?? false,
      extension: json['extension'] != null
          ? CreativeIslandItemExtension.fromJson(json['extension'])
          : null,
    );
  }
}

class CreativeIslandCompletionAsyncResp {
  String taskId;

  CreativeIslandCompletionAsyncResp(this.taskId);

  toJson() => {
        'task_id': taskId,
      };

  static CreativeIslandCompletionAsyncResp fromJson(Map<String, dynamic> json) {
    return CreativeIslandCompletionAsyncResp(json['task_id']);
  }
}

class CreativeItemInServer {
  int id;
  int? userId;
  String islandId;
  int? islandType;
  String? vendor;
  String? islandName;
  String? islandTitle;
  String? arguments;
  String? prompt;
  String? answer;
  int? quotaUsed;
  int? status;
  int? shared;
  String? filterName;
  DateTime? createdAt;
  DateTime? updatedAt;

  bool showBetaFeature;

  CreativeItemInServer({
    required this.id,
    required this.islandId,
    required this.showBetaFeature,
    this.userId,
    this.islandType,
    this.islandName,
    this.islandTitle,
    this.vendor,
    this.arguments,
    this.prompt,
    this.answer,
    this.quotaUsed,
    this.status,
    this.shared,
    this.createdAt,
    this.updatedAt,
  });

  CreativeItemArguments get creativeItemArguments {
    if (arguments != null) {
      return CreativeItemArguments.fromJson(jsonDecode(arguments!));
    }

    return CreativeItemArguments(
      width: 512,
      height: 512,
      steps: 1,
      imageCount: 1,
    );
  }

  bool get isShared => shared == 1;

  String get errorCode => NumberFormat('E000000000').format(id);

  toJson() => {
        'id': id,
        'user_id': userId,
        'island_id': islandId,
        'island_type': islandType,
        'island_name': islandName,
        'island_title': islandTitle,
        'vendor': vendor,
        'arguments': arguments,
        'prompt': prompt,
        'answer': answer,
        'quota_used': quotaUsed,
        'status': status,
        'shared': shared,
        'show_beta_feature': showBetaFeature,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static CreativeItemInServer fromJson(Map<String, dynamic> json) {
    return CreativeItemInServer(
      id: json['id'],
      userId: json['user_id'],
      islandId: json['island_id'],
      islandType: json['island_type'],
      islandName: json['island_name'],
      islandTitle: json['island_title'],
      vendor: json['vendor'],
      arguments: json['arguments'],
      prompt: json['prompt'],
      answer: json['answer'],
      quotaUsed: json['quota_used'],
      status: json['status'],
      shared: json['shared'],
      showBetaFeature: json['show_beta_feature'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isSuccessful => status == 3;
  bool get isFailed =>
      status != null && (status == 4 || (status! <= 2 && answer != null));
  bool get isProcessing => status != null && status! <= 2 && answer == null;

  bool get isTextType => islandType == 1;
  bool get isImageType =>
      islandType != null && (islandType == 2 || islandType! >= 5);

  List<String> get images {
    try {
      if (isImageType && answer != null && answer != '' && isSuccessful) {
        return (jsonDecode(answer!) as List<dynamic>).cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  String get firstImagePreview {
    final imgs = images;
    if (imgs.isEmpty) {
      return "";
    }

    if (!imgs.first.startsWith('https://ssl.aicode.cc/')) {
      return imgs.first;
    }

    final original = imgs.first.split('?').first;
    if (original.toLowerCase().endsWith('.jpg') ||
        original.toLowerCase().endsWith('.jpeg') ||
        original.toLowerCase().endsWith('.png') ||
        original.toLowerCase().endsWith('.webp') ||
        original.toLowerCase().endsWith('.gif')) {
      return "$original-avatar";
    }

    return imgs.first;
  }

  Map<String, dynamic> get params {
    if (arguments != null) {
      return jsonDecode(arguments!);
    }

    return {};
  }

  String get markdownAnswer {
    if (isProcessing) {
      return '正在生成中...';
    }

    if (isFailed) {
      return '生成失败\n\n```\n$answer\n```';
    }

    if (isImageType && answer != null && isSuccessful) {
      return images.map((e) => '![image]($e)').join("\n\n");
    }

    return answer ?? '';
  }
}

class CreativeItemArguments {
  int? width;
  int? height;
  int? steps;
  int? imageCount;
  String? image;
  int? wordCount;
  String? negativePrompt;
  String? realPrompt;
  String? realNegativePrompt;
  String? modelName;
  int? seed;
  String? filterName;

  CreativeItemArguments({
    this.width,
    this.height,
    this.steps,
    this.imageCount,
    this.image,
    this.wordCount,
    this.negativePrompt,
    this.realPrompt,
    this.realNegativePrompt,
    this.modelName,
    this.seed,
    this.filterName,
  });

  toJson() => {
        'width': width,
        'height': height,
        'steps': steps,
        'image_count': imageCount,
        'image': image,
        'word_count': wordCount,
        'negative_prompt': negativePrompt,
        'real_prompt': realPrompt,
        'real_negative_prompt': realNegativePrompt,
        'model_name': modelName,
        'seed': seed,
        'filter_name': filterName,
      };

  static CreativeItemArguments fromJson(Map<String, dynamic> json) {
    return CreativeItemArguments(
      width: json['width'],
      height: json['height'],
      steps: json['steps'],
      imageCount: json['image_count'] ?? 1,
      image: json['image'],
      wordCount: json['word_count'],
      negativePrompt: json['negative_prompt'],
      realPrompt: json['real_prompt'],
      realNegativePrompt: json['real_negative_prompt'],
      modelName: json['model_name'],
      seed: json['seed'],
      filterName: json['filter_name'],
    );
  }
}

class CreativeIslandItemV2 {
  String id;
  String title;
  String titleColor;
  String previewImage;
  String routeUri;
  String tag;
  String? note;
  String size;

  CreativeIslandItemV2({
    required this.id,
    required this.title,
    required this.titleColor,
    required this.previewImage,
    required this.routeUri,
    this.tag = '',
    this.note,
    this.size = 'large',
  });

  toJson() => {
        'id': id,
        'title': title,
        'title_color': titleColor,
        'preview_image': previewImage,
        'route_uri': routeUri,
        'tag': tag,
        'note': note,
        'size': size,
      };

  static CreativeIslandItemV2 fromJson(Map<String, dynamic> json) {
    return CreativeIslandItemV2(
      id: json['id'],
      title: json['title'],
      titleColor: json['title_color'],
      previewImage: json['preview_image'],
      routeUri: json['route_uri'],
      tag: json['tag'] ?? '',
      note: json['note'],
      size: json['size'] ?? 'large',
    );
  }
}
