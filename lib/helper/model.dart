import 'package:askaide/helper/constant.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/model.dart' as mm;
import 'package:askaide/repo/openai_repo.dart';
import 'package:askaide/repo/settings_repo.dart';

/// 模型聚合，用于聚合多种厂商的模型
class ModelAggregate {
  static late SettingRepository settings;

  static void init(SettingRepository settings) {
    ModelAggregate.settings = settings;
  }

  /// 支持的模型列表
  static Future<List<mm.Model>> models() async {
    final List<mm.Model> models = [];
    final isAPIServerSet =
        settings.stringDefault(settingAPIServerToken, '') != '';
    final selfHostOpenAI = settings.boolDefault(settingOpenAISelfHosted, false);

    if (isAPIServerSet) {
      models.addAll((await APIServer().models())
          .map(
            (e) => mm.Model(
              e.id.split(':').last,
              e.name,
              e.category,
              shortName: e.shortName,
              description: e.description,
              isChatModel: e.isChat,
              disabled: e.disabled,
              category: e.category,
              tag: e.tag,
              avatarUrl: e.avatarUrl,
            ),
          )
          .toList());
    }

    if (selfHostOpenAI) {
      return <mm.Model>[
        ...OpenAIRepository.supportModels(),
        ...models
            .where((element) => element.category != modelTypeOpenAI)
            .toList()
      ];
    }

    // if (isAPIServerSet ||
    //     settings.stringDefault(settingDeepAIAPIToken, '') != '') {
    //   models.addAll(DeepAIRepository.supportModels());
    // }

    // TODO Replace with StabilityAI API
    // if (isAPIServerSet ||
    //     settings.stringDefault(settingStabilityAIAPIToken, '') != '') {
    //   models.addAll(StabilityAIRepository.supportModels());
    // }

    return models;
  }

  /// 根据模型唯一id查找模型
  static Future<mm.Model> model(String uid) async {
    if (uid.split(':').length == 1) {
      uid = '$modelTypeOpenAI:$uid';
    }

    final supportModels = await models();
    // if (uid.startsWith('$modelTypeOpenAI:')) {
    //   models.addAll(OpenAIRepository.supportModels());
    // }

    // if (uid.startsWith('$modelTypeDeepAI:')) {
    //   models.addAll(DeepAIRepository.supportModels());
    // }

    // if (uid.startsWith('$modelTypeStabilityAI:')) {
    //   models.addAll(StabilityAIRepository.supportModels());
    // }

    return supportModels.firstWhere(
      (element) => element.uid() == uid,
      orElse: () => mm.Model(defaultChatModel, defaultChatModel, 'openai',
          category: modelTypeOpenAI),
    );
  }
}
