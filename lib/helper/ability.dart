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

  /// 是否支持 Websocket
  bool supportWebSocket() {
    return capabilities.supportWebsocket && !supportLocalOpenAI();
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

  /// 是否支持 OpenAI
  bool get enableOpenAI {
    return capabilities.openaiEnabled;
  }

  /// 是否支持支付宝
  bool get enableAlipay {
    return capabilities.alipayEnabled;
  }

  /// 是否支持 ApplePay
  bool get enableApplePay {
    return capabilities.applePayEnabled;
  }

  /// 是否支持支付功能
  bool get enablePayment {
    if (!enableApplePay && !enableAlipay) {
      return false;
    }

    if (PlatformTool.isIOS() && enableApplePay) {
      return true;
    }

    return enableAlipay;
  }

  /// 是否支持API Server
  bool supportAPIServer() {
    return setting.stringDefault(settingAPIServerToken, '') != '';
  }

  /// 是否启用了 OpenAI 自定义设置
  bool supportLocalOpenAI() {
    return setting.boolDefault(settingOpenAISelfHosted, false);
  }

  /// 是否支持翻译功能
  bool supportTranslate() {
    return false;
    // return setting.stringDefault(settingAPIServerToken, '') != '';
  }

  /// 是否支持语音合成功能
  bool supportSpeak() {
    // return setting.stringDefault(settingAPIServerToken, '') != '';
    return true;
  }

  /// 是否支持图片上传功能
  bool supportImageUploader() {
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
