import 'dart:convert';

import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/repo/data/settings_data.dart';
import 'package:http/http.dart' as http;

class DeepAIRepository {
  late String serverURL;
  late String apiKey;
  late bool selfHosted;

  Map<String, String> _headers = {};
  late String language;

  final SettingDataProvider settings;

  DeepAIRepository(this.settings) {
    selfHosted = settings.getDefaultBool(settingDeepAISelfHosted, false);
    language = settings.getDefault(settingLanguage, 'zh');

    _reloadServerConfig();

    settings.listen((settings, key, value) {
      selfHosted = settings.getDefaultBool(settingDeepAISelfHosted, false);
      language = settings.getDefault(settingLanguage, 'zh');

      _reloadServerConfig();
    });
  }

  void _reloadServerConfig() {
    if (selfHosted) {
      serverURL = settings.getDefault(settingDeepAIURL, defaultDeepAIServerURL);
      apiKey = settings.getDefault(settingDeepAIAPIToken, '');
      _headers = {};
    } else {
      apiKey = settings.getDefault(settingAPIServerToken, '');
      serverURL = apiServerURL;

      _headers = {
        'X-CLIENT-VERSION': clientVersion,
        'X-PLATFORM': PlatformTool.operatingSystem(),
        'X-PLATFORM-VERSION': PlatformTool.operatingSystemVersion(),
        'X-LANGUAGE': language,
      };
    }
  }

  // static List<Model> supportModels() {
  //   return [
  //     Model(
  //       'text2img',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '根据文本描述创建图像',
  //     ),
  //     Model(
  //       'cute-creature-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成可爱的动物图像',
  //     ),
  //     Model(
  //       'fantasy-world-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成奇幻世界图像',
  //     ),
  //     Model(
  //       'cyberpunk-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成未来科幻图像',
  //     ),
  //     Model(
  //       'anime-portrait-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成动漫人物图像',
  //     ),
  //     Model(
  //       'old-style-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成老式风格图像',
  //     ),
  //     Model(
  //       'renaissance-painting-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成文艺复兴风格图像',
  //     ),
  //     Model(
  //       'abstract-painting-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成抽象风格图像',
  //     ),
  //     Model(
  //       'impressionism-painting-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成印象派风格图像',
  //     ),
  //     Model(
  //       'surreal-graphics-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成超现实风格图像',
  //     ),
  //     Model(
  //       '3d-objects-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成3D物体图像',
  //     ),
  //     Model(
  //       'origami-3d-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成折纸风格图像',
  //     ),
  //     Model(
  //       'hologram-3d-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成全息图像',
  //     ),
  //     Model(
  //       '3d-character-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成3D人物图像',
  //     ),
  //     Model(
  //       'watercolor-painting-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成水彩风格图像',
  //     ),
  //     Model(
  //       'pop-art-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成流行艺术风格图像',
  //     ),
  //     Model(
  //       'contemporary-architecture-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成现代建筑图像',
  //     ),
  //     Model(
  //       'future-architecture-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成未来建筑图像',
  //     ),
  //     Model(
  //       'watercolor-architecture-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成水彩建筑图像',
  //     ),
  //     Model(
  //       'fantasy-character-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成奇幻人物图像',
  //     ),
  //     Model(
  //       'steampunk-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成蒸汽朋克风格图像',
  //     ),
  //     Model(
  //       'logo-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成Logo图像',
  //     ),
  //     Model(
  //       'pixel-art-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成像素风格图像',
  //     ),
  //     Model(
  //       'street-art-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成街头艺术风格图像',
  //     ),
  //     Model(
  //       'surreal-portrait-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成超现实人物图像',
  //     ),
  //     Model(
  //       'anime-world-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成动漫世界图像',
  //     ),
  //     Model(
  //       'fantasy-portrait-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成奇幻人物图像',
  //     ),
  //     Model(
  //       'comics-portrait-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成漫画人物图像',
  //     ),
  //     Model(
  //       'cyberpunk-portrait-generator',
  //       'deepai',
  //       category: modelTypeDeepAI,
  //       description: '生成未来科幻人物图像',
  //     ),
  //   ];
  // }

  Future<DeepAIPaintResult> painting(
    String model,
    String prompt, {
    int gridSize = 1,
    int width = 512,
    int height = 512,
    String? negativePrompt,
  }) async {
    var params = <String, dynamic>{
      "text": prompt,
      "grid_size": gridSize.toString(),
      "width": width.toString(),
      "height": height.toString(),
    };
    if (negativePrompt != null) {
      params['negative_prompt'] = negativePrompt;
    }

    var url = selfHosted
        ? Uri.parse('$serverURL/api/$model')
        : Uri.parse('$serverURL/v1/deepai/images/$model/text-to-image');

    var headers = <String, String>{};
    headers.addAll(_headers);
    if (selfHosted) {
      headers['api-key'] = apiKey;
    } else {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    var resp = await http.post(
      url,
      body: params,
      headers: headers,
    );

    if (resp.statusCode != 200) {
      return Future.error((resp.body as Map<String, dynamic>)['error']);
    }

    var ret = jsonDecode(resp.body) as Map<String, dynamic>;

    return Future.value(DeepAIPaintResult(ret['id'], ret['output_url']));
  }

  Future<String> paintingAsync(
    String model,
    String prompt, {
    int gridSize = 1,
    int width = 512,
    int height = 512,
    String? negativePrompt,
  }) async {
    var params = <String, dynamic>{
      "text": prompt,
      "grid_size": gridSize.toString(),
      "width": width.toString(),
      "height": height.toString(),
    };
    if (negativePrompt != null) {
      params['negative_prompt'] = negativePrompt;
    }

    var url =
        Uri.parse('$serverURL/v1/deepai/images/$model/text-to-image-async');

    var headers = <String, String>{};
    headers.addAll(_headers);
    headers['Authorization'] = 'Bearer $apiKey';

    var resp = await http.post(
      url,
      body: params,
      headers: headers,
    );

    if (resp.statusCode != 200) {
      return Future.error((resp.body as Map<String, dynamic>)['error']);
    }

    return Future.value(jsonDecode(resp.body)['task_id']);
  }
}

class DeepAIPaintResult {
  final String id;
  final String url;

  DeepAIPaintResult(this.id, this.url);
}
