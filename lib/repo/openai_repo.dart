import 'dart:async';
import 'dart:io';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/repo/model/model.dart' as mm;
import 'package:dart_openai/openai.dart';
import 'package:askaide/repo/data/settings_data.dart';

class OpenAIRepository {
  final SettingDataProvider settings;

  late bool selfHosted;
  late String language;

  OpenAIRepository(this.settings) {
    selfHosted = settings.getDefaultBool(settingOpenAISelfHosted, false);
    language = settings.getDefault(settingLanguage, 'zh');

    _reloadServerConfig();

    settings.listen((settings, key, value) {
      selfHosted = settings.getDefaultBool(settingOpenAISelfHosted, false);
      language = settings.getDefault(settingLanguage, 'zh');

      _reloadServerConfig();
    });
  }

  void _reloadServerConfig() {
    // 自己的 OpenAI 服务器
    if (selfHosted) {
      OpenAI.baseUrl =
          settings.getDefault(settingOpenAIURL, defaultOpenAIServerURL);
      OpenAI.organization = settings.get(settingOpenAIOrganization);
      OpenAI.apiKey = settings.getDefault(settingOpenAIAPIToken, '');
      OpenAI.externalHeaders = {};
    } else {
      // 使用公共服务器
      OpenAI.apiKey = settings.getDefault(settingAPIServerToken, '');
      OpenAI.baseUrl = apiServerURL;
      OpenAI.organization = "";
      OpenAI.externalHeaders = {
        'X-CLIENT-VERSION': clientVersion,
        'X-PLATFORM': PlatformTool.operatingSystem(),
        'X-PLATFORM-VERSION': PlatformTool.operatingSystemVersion(),
        'X-LANGUAGE': language,
      };
    }

    OpenAI.showLogs = false;
  }

  /// 基于 prompt 生成图片
  Future<List<String>> createImage(
    String prompt, {
    int n = 1,
    OpenAIImageSize size = OpenAIImageSize.size1024,
  }) async {
    var model = await OpenAI.instance.image.create(
        prompt: prompt,
        n: n,
        size: size,
        responseFormat: OpenAIImageResponseFormat.url);
    return model.data.map((e) => e.url).toList();
  }

  /// 判断模型是否支持聊天
  static bool isChatModel(String model) {
    return supportForChat[model] != null && supportForChat[model]!.isChatModel;
  }

  /// 判断模型是否为图片模型
  static bool isImageModel(String model) {
    return model == defaultImageModel;
  }

  // 兼容性列表查看：https://platform.openai.com/docs/models/gpt-3
  // key: 模型名, value: 是否支持聊天模式
  static final supportForChat = <String, mm.Model>{
    'gpt-3.5-turbo': mm.Model(
      'gpt-3.5-turbo',
      'gpt-3.5-turbo',
      'openai',
      category: modelTypeOpenAI,
      isChatModel: true,
      description: '能力最强的 GPT-3.5 模型，成本低',
    ),
    'gpt-3.5-turbo-16k': mm.Model(
      'gpt-3.5-turbo-16k',
      'gpt-3.5-turbo-16k',
      'openai',
      category: modelTypeOpenAI,
      isChatModel: true,
      description: '能力最强的 GPT-3.5 模型，成本为 gpt-3.5-turbo 的两倍，但是支持 4K 上下文',
    ),
    'gpt-4': mm.Model(
      'gpt-4',
      'gpt-4',
      'openai',
      category: modelTypeOpenAI,
      isChatModel: true,
      description: '比GPT-3.5模型更强，能够执行复杂任务，并优化用于聊天',
    ),

    'gpt-4-32k': mm.Model(
      'gpt-4-32k',
      'gpt-4-32k',
      'openai',
      category: modelTypeOpenAI,
      isChatModel: true,
      description: '基于 GPT-4，但是支持4倍的内容长度',
    ),

    // 'gpt-4-0314': Model(
    //   'gpt-4-0314',
    //   'openai',
    //   category: modelTypeOpenAI,
    //   isChatModel: true,
    // ),
    // 'gpt-4-32k-0314': Model(
    //   'gpt-4-32k-0314',
    //   'openai',
    //   category: modelTypeOpenAI,
    //   isChatModel: true,
    // ),
    //// gpt-3.5-turbo-0301 将在 2023年6月1日停止服务
    // 'gpt-3.5-turbo-0301': Model(
    //   'gpt-3.5-turbo-0301',
    //   'openai',
    //   category: modelTypeOpenAI,
    //   isChatModel: true,
    // ),
    // 'text-davinci-003': Model(
    //   'text-davinci-003',
    //   'openai',
    //   category: modelTypeOpenAI,
    // ),
    // 'text-davinci-002': Model(
    //   'text-davinci-002',
    //   'openai',
    //   category: modelTypeOpenAI,
    // ),
    // 'text-curie-001': Model(
    //   'text-curie-001',
    //   'openai',
    //   category: modelTypeOpenAI,
    // ),
    // 'text-babbage-001': Model(
    //   'text-babbage-001',
    //   'openai',
    //   category: modelTypeOpenAI,
    // ),
    // 'text-ada-001': Model(
    //   'text-ada-001',
    //   'openai',
    //   category: modelTypeOpenAI,
    // ),
  };

  /// 支持的模型
  static List<mm.Model> supportModels() {
    var models = supportForChat.values.toList();
    // models.add(Model(
    //   defaultImageModel,
    //   'openai',
    //   category: modelTypeOpenAI,
    //   description: '根据自然语言创建现实的图像和艺术',
    // ));
    return models;
  }

  // /// @deprecated
  // Future<List<mm.Model>> models() async {
  //   var models = (await OpenAI.instance.model.list())
  //       .where((e) => e.ownedBy == 'openai')
  //       .map((e) => mm.Model(e.id, e.ownedBy, category: modelTypeOpenAI))
  //       .toList();
  //   var supportModels =
  //       models.where((e) => supportForChat.containsKey(e.id)).toList();

  //   supportModels.add(mm.Model(
  //     defaultImageModel,
  //     'openai',
  //     category: modelTypeOpenAI,
  //     description: defaultModelNotChatDesc,
  //   ));

  //   return supportModels;
  // }

  Future<void> completionStream(
    String model,
    String message,
    void Function(ChatStreamRespData data) onData, {
    double temperature = 1.0,
    user = 'user',
    int? maxTokens,
  }) async {
    var completer = Completer<void>();

    try {
      var stream = OpenAI.instance.completion.createStream(
        model: model,
        prompt: message,
        temperature: temperature,
        n: 1,
        maxTokens: maxTokens,
        user: user,
      );

      stream.listen(
        (event) {
          for (var element in event.choices) {
            onData(ChatStreamRespData(content: element.text));
          }
        },
        onDone: () => completer.complete(),
        onError: (e) => completer.completeError(e),
        cancelOnError: true,
      ).onError((e) {
        completer.completeError(e);
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<void> chatStream(
    List<OpenAIChatCompletionChoiceMessageModel> messages,
    void Function(ChatStreamRespData data) onData, {
    double temperature = 1.0,
    user = 'user',
    model = defaultChatModel,
    int? roomId,
    int? maxTokens,
  }) async {
    var completer = Completer<void>();

    try {
      var chatStream = OpenAI.instance.chat.createStream(
        model: model,
        messages: messages,
        temperature: temperature,
        user: user,
        maxTokens: maxTokens,
        n: Ability().supportLocalOpenAI()
            ? null
            : roomId, // n 参数暂时用不到，复用作为 roomId
      );

      chatStream.listen(
        (event) {
          for (var element in event.choices) {
            if (element.delta.content != null) {
              onData(ChatStreamRespData(
                content: element.delta.content!,
                role: element.delta.role,
              ));
            }
          }
        },
        onDone: () => completer.complete(),
        onError: (e) => completer.completeError(e),
        cancelOnError: true,
      ).onError((e) {
        completer.completeError(e);
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  /// 音频文件转文字
  Future<String> audioTranscription({
    required File audioFile,
  }) async {
    var audioModel = await OpenAI.instance.audio.createTranscription(
      file: audioFile,
      model: 'whisper-1',
    );

    return audioModel.text;
  }
}

class ChatReplyMessage {
  final int index;
  final String role;
  final String content;
  final String? finishReason;

  ChatReplyMessage({
    required this.index,
    required this.role,
    required this.content,
    this.finishReason,
  });
}

class ChatStreamRespData {
  final String? role;
  final String content;

  ChatStreamRespData({
    this.role,
    required this.content,
  });
}
