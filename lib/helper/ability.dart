import 'package:askaide/helper/constant.dart';
import 'package:askaide/repo/settings_repo.dart';

class Ability {
  late final SettingRepository setting;

  init(SettingRepository setting) {
    this.setting = setting;
  }

  /// 单例
  static final Ability _instance = Ability._internal();
  Ability._internal();

  factory Ability() {
    return _instance;
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
