import 'dart:io' show Directory, Platform;
import 'package:askaide/helper/platform.dart';
import 'package:path_provider/path_provider.dart';

class PathHelper {
  late final String cachePath;
  late final String documentsPath;
  late final String supportPath;

  init() async {
    try {
      cachePath = (await getApplicationCacheDirectory()).path;
    } catch (e) {
      cachePath = '';
    }

    try {
      documentsPath = (await getApplicationDocumentsDirectory()).path;
    } catch (e) {
      documentsPath = '';
    }

    try {
      supportPath = (await getApplicationSupportDirectory()).path;
    } catch (e) {
      supportPath = '';
    }

    // 确保 .aidea 目录存在
    try {
      Directory(getHomePath).create(recursive: true);
    } catch (e) {
      print('创建 $getHomePath 目录失败: $e');
    }
  }

  String get getHomePath {
    Map<String, String> envVars = Platform.environment;
    if (PlatformTool.isMacOS() || PlatformTool.isLinux()) {
      return '${envVars['HOME'] ?? ''}/.aidea';
    } else if (PlatformTool.isWindows()) {
      return '${envVars['UserProfile'] ?? ''}/.aidea';
    } else if (PlatformTool.isAndroid()) {
      return '$documentsPath/.aidea';
    }

    return '.aidea';
  }

  String get getLogfilePath {
    return '$getHomePath/aidea.log';
  }

  String get getCachePath {
    return getHomePath;
  }

  /// 单例
  static final PathHelper _instance = PathHelper._internal();
  PathHelper._internal();

  factory PathHelper() {
    return _instance;
  }

  Map<String, String> toMap() {
    return {
      'cachePath': cachePath,
      'cachePathReal': getCachePath,
      'documentsPath': documentsPath,
      'supportPath': supportPath,
      'homePath': getHomePath,
      'logfilePath': getLogfilePath,
    };
  }
}
