import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/repo/api/info.dart';
import 'package:askaide/repo/settings_repo.dart';

class Ability {
  late final SettingRepository setting;
  late Capabilities capabilities;

  init(SettingRepository setting, Capabilities capabilities) {
    this.setting = setting;
    this.capabilities = capabilities;
  }

  /// 单例
  static final Ability _instance = Ability._internal();
  Ability._internal();

  factory Ability() {
    return _instance;
  }

  /// 服务状态页
  String get serviceStatusPage {
    return capabilities.serviceStatusPage;
  }

  /// 是否支持 Websocket
  bool get supportWebSocket {
    return capabilities.supportWebsocket;
  }

  /// 是否支持 API Keys 功能
  bool get supportAPIKeys {
    return capabilities.supportAPIKeys;
  }

  /// 更新能力
  updateCapabilities(Capabilities capabilities) {
    this.capabilities = capabilities;
  }

  /// 首页支持的模型列表
  List<HomeModel> get homeModels {
    return capabilities.homeModels;
  }

  /// 是否显示首页模型描述
  bool get showHomeModelDescription {
    return capabilities.showHomeModelDescription;
  }

  /// 首页路由
  String get homeRoute {
    return capabilities.homeRoute;
  }

  /// 是否支持绘玩
  bool get enableGallery {
    return !capabilities.disableGallery;
  }

  /// 是否支持创作岛
  bool get enableCreationIsland {
    return !capabilities.disableCreationIsland;
  }

  /// 是否支持数字人
  bool get enableDigitalHuman {
    return !capabilities.disableDigitalHuman;
  }

  /// 是否支持聊一聊
  bool get enableChat {
    return !capabilities.disableChat;
  }

  /// 是否支持 OpenAI
  bool get enableOpenAI {
    return capabilities.openaiEnabled &&
        (!capabilities.disableChat || !capabilities.disableDigitalHuman);
  }

  /// 是否支持 IOS 外支付
  bool get enableOtherPay {
    return capabilities.otherPayEnabled;
  }

  /// 是否支持 ApplePay
  bool get enableApplePay {
    return capabilities.applePayEnabled;
  }

  /// 是否支持支付功能
  bool get enablePayment {
    if (!enableApplePay && !enableOtherPay) {
      return false;
    }

    if (PlatformTool.isIOS() && enableApplePay) {
      return true;
    }

    return enableOtherPay;
  }

  /// 是否支持API Server
  bool enableAPIServer() {
    return setting.stringDefault(settingAPIServerToken, '') != '';
  }

  /// 是否启用了 OpenAI 自定义设置
  bool get enableLocalOpenAI {
    return setting.boolDefault(settingOpenAISelfHosted, false);
  }

  /// 是否使用本地的 OpenAI 模型
  bool usingLocalOpenAIModel(String model) {
    return setting.boolDefault(settingOpenAISelfHosted, false) &&
        (model.startsWith('openai:') || model.startsWith('gpt-'));
  }

  /// 是否支持翻译功能
  bool get supportTranslate {
    return false;
    // return setting.stringDefault(settingAPIServerToken, '') != '';
  }

  /// 是否支持语音合成功能
  bool get supportSpeak {
    // return setting.stringDefault(settingAPIServerToken, '') != '';
    if (PlatformTool.isWeb()) {
      return false;
    }

    return true;
  }

  /// 是否支持图片上传功能
  bool get supportImageUploader {
    return supportImglocUploader() || supportQiniuUploader();
  }

  /// 是否支持Imgloc图片上传功能
  bool supportImglocUploader() {
    return setting.boolDefault(settingImageManagerSelfHosted, false) &&
        setting.stringDefault(settingImglocToken, '') != '';
  }

  /// 是否支持七牛云图片上传功能
  bool supportQiniuUploader() {
    return setting.stringDefault(settingAPIServerToken, '') != '';
  }
}
