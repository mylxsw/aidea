import 'dart:convert';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/repo/data/settings_data.dart';
import 'package:http/http.dart' as http;

/// StabilityAI 模型
class StabilityAIRepository {
  final SettingDataProvider settings;

  late String serverURL;
  late String apiKey;
  late String organization;
  late String language;

  late bool selfHosted;

  Map<String, String> _headers = {};

  StabilityAIRepository(this.settings) {
    selfHosted = settings.getDefaultBool(settingStabilityAISelfHosted, false);
    language = settings.getDefault(settingLanguage, 'zh');

    _reloadServerConfig();

    settings.listen((settings, key, value) {
      selfHosted = settings.getDefaultBool(settingStabilityAISelfHosted, false);
      language = settings.getDefault(settingLanguage, 'zh');

      _reloadServerConfig();
    });
  }

  void _reloadServerConfig() {
    if (selfHosted) {
      serverURL =
          settings.getDefault(settingStabilityAIURL, defaultStabilityAIURL);
      organization = settings.getDefault(settingStabilityAIOrganization, '');
      apiKey = settings.getDefault(settingStabilityAIAPIToken, '');

      _headers = {};
    } else {
      apiKey = settings.getDefault(settingAPIServerToken, '');
      organization = "";
      serverURL = apiServerURL;

      _headers = {
        'X-CLIENT-VERSION': clientVersion,
        'X-PLATFORM': PlatformTool.operatingSystem(),
        'X-PLATFORM-VERSION': PlatformTool.operatingSystemVersion(),
        'X-LANGUAGE': language,
      };
    }
  }

  /// 创建请求头
  Map<String, String> _buildRequestHeaders() {
    var headers = <String, String>{
      'Authorization': 'Bearer $apiKey',
    };

    headers.addAll(_headers);

    if (organization.isNotEmpty) {
      headers['Organization'] = organization;
    }

    return headers;
  }

  /// 默认的模型列表
  // static List<Model> supportModels() {
  //   return [
  //     // Model(
  //     //   'esrgan-v1-x2plus',
  //     //   modelTypeStabilityAI,
  //     //   category: modelTypeStabilityAI,
  //     //   description: 'Real-ESRGAN_x2plus upscaler model',
  //     // ),
  //     Model(
  //       'stable-diffusion-v1',
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: 'Stability-AI Stable Diffusion v1.4',
  //     ),
  //     Model(
  //       'stable-diffusion-v1-5',
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: 'Stability-AI Stable Diffusion v1.5',
  //     ),
  //     Model(
  //       'stable-diffusion-512-v2-0',
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: 'Stability-AI Stable Diffusion v2.0',
  //     ),
  //     Model(
  //       'stable-diffusion-768-v2-0',
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: 'Stability-AI Stable Diffusion 768 v2.0',
  //     ),
  //     Model(
  //       'stable-diffusion-512-v2-1',
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: 'Stability-AI Stable Diffusion v2.1',
  //     ),
  //     Model(
  //       'stable-diffusion-768-v2-1',
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: 'Stability-AI Stable Diffusion 768 v2.1',
  //     ),
  //     Model(
  //       'stable-diffusion-xl-beta-v2-2-2',
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: 'Stability-AI Stable Diffusion XL Beta v2.2.2',
  //     ),
  //     // Model(
  //     //   'stable-inpainting-v1-0',
  //     //   modelTypeStabilityAI,
  //     //   category: modelTypeStabilityAI,
  //     //   description: 'Stability-AI Stable Inpainting v1.0',
  //     // ),
  //     // Model(
  //     //   'stable-inpainting-512-v2-0',
  //     //   modelTypeStabilityAI,
  //     //   category: modelTypeStabilityAI,
  //     //   description: 'Stability-AI Stable Inpainting v2.0',
  //     // ),
  //   ];
  // }

  /// 查询模型列表
  // Future<List<Model>> models() async {
  //   var resp = await http.get(
  //     Uri.parse('$serverURL/v1/engines/list'),
  //     headers: <String, String>{
  //       'Accept': 'application/json',
  //     }..addAll(_buildRequestHeaders()),
  //   );

  //   if (resp.statusCode != 200) {
  //     return Future.error('Failed to load models: ${resp.body}');
  //   }

  //   var models = <Model>[];
  //   for (var item in jsonDecode(resp.body) as List) {
  //     if ((item['type'] as String).toLowerCase() != 'picture') {
  //       print(item);
  //       continue;
  //     }

  //     models.add(Model(
  //       item['id'],
  //       modelTypeStabilityAI,
  //       category: modelTypeStabilityAI,
  //       description: item['description'],
  //     ));
  //   }

  //   return models;
  // }

  /// 创建图片，返回图片的 base64 编码
  /// 不同模型价格表： https://platform.stability.ai/docs/getting-started/credits-and-billing#pricing-table
  /// width,height+steps+engine 决定价格
  Future<List<String>> createImageBase64(
    String engine,
    List<StabilityAIPrompt> prompts, {
    int width = 0,
    int height = 0,
    int cfgScale = 7,
    int samples = 1,
    int seed = 0,
    int steps = 30,
    // 3d-model analog-film anime cinematic comic-book digital-art enhance fantasy-art
    // isometric line-art low-poly modeling-compound neon-punk origami photographic
    // pixel-art tile-texture
    String? stylePreset,
  }) async {
    // 注意：图像宽度和高度必须满足下面条件
    // For 768 engines: 589,824 ≤ height * width ≤ 1,048,576
    // All other engines: 262,144 ≤ height * width ≤ 1,048,576
    if (width == 0) {
      if (engine.contains('-768-')) {
        width = 768;
      } else {
        width = 512;
      }
    }

    if (height == 0) {
      if (engine.contains('-768-')) {
        height = 768;
      } else {
        height = 512;
      }
    }

    var params = <String, dynamic>{
      'width': width,
      'height': height,
      'cfg_scale': cfgScale,
      'samples': samples,
      'seed': seed,
      'steps': steps,
      'text_prompts': prompts,
    };

    if (stylePreset != null) {
      params['style_preset'] = stylePreset;
    }

    var headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    }..addAll(_buildRequestHeaders());

    final url = selfHosted
        ? Uri.parse('$serverURL/v1/generation/$engine/text-to-image')
        : Uri.parse('$serverURL/v1/stabilityai/images/$engine/text-to-image');

    var req = http.Request('POST', url);
    req.body = jsonEncode(params);
    req.headers.addAll(headers);

    var resp = await http.Response.fromStream(await http.Client().send(req));
    if (resp.statusCode != 200) {
      var ret = jsonDecode(resp.body);
      return Future.error(ret['error']);
    }

    var images = <String>[];
    for (var item in jsonDecode(resp.body)['artifacts'] as List) {
      images.add(item['base64']);
    }

    return images;
  }

  /// 创建图片，返回图片的 base64 编码
  /// 不同模型价格表： https://platform.stability.ai/docs/getting-started/credits-and-billing#pricing-table
  /// width,height+steps+engine 决定价格
  Future<String> createImageBase64Async(
    String engine,
    List<StabilityAIPrompt> prompts, {
    int width = 0,
    int height = 0,
    int cfgScale = 7,
    int samples = 1,
    int seed = 0,
    int steps = 30,
    // 3d-model analog-film anime cinematic comic-book digital-art enhance fantasy-art
    // isometric line-art low-poly modeling-compound neon-punk origami photographic
    // pixel-art tile-texture
    String? stylePreset,
  }) async {
    // 注意：图像宽度和高度必须满足下面条件
    // For 768 engines: 589,824 ≤ height * width ≤ 1,048,576
    // All other engines: 262,144 ≤ height * width ≤ 1,048,576
    if (width == 0) {
      if (engine.contains('-768-')) {
        width = 768;
      } else {
        width = 512;
      }
    }

    if (height == 0) {
      if (engine.contains('-768-')) {
        height = 768;
      } else {
        height = 512;
      }
    }

    var params = <String, dynamic>{
      'width': width,
      'height': height,
      'cfg_scale': cfgScale,
      'samples': samples,
      'seed': seed,
      'steps': steps,
      'text_prompts': prompts,
    };

    if (stylePreset != null) {
      params['style_preset'] = stylePreset;
    }

    var headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    }..addAll(_buildRequestHeaders());

    final url = Uri.parse(
        '$serverURL/v1/stabilityai/images/$engine/text-to-image-async');

    var req = http.Request('POST', url);
    req.body = jsonEncode(params);
    req.headers.addAll(headers);

    var resp = await http.Response.fromStream(await http.Client().send(req));
    if (resp.statusCode != 200) {
      var ret = jsonDecode(resp.body);
      return Future.error(ret['error']);
    }

    return jsonDecode(resp.body)['task_id'] as String;
  }
}

class StabilityAIPrompt {
  final String text;
  final double weight;

  StabilityAIPrompt(this.text, this.weight);

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'weight': weight,
    };
  }
}
