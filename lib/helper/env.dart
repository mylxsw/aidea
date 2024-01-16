import 'dart:io' show Platform;

import 'package:askaide/helper/platform.dart';

/// 默认 API 服务器地址
/// 注意：当你使用自己的服务器时，请修改该地址为你自己的服务器地址
const defaultAPIServerURL = 'https://ai-api.aicode.cc';

/// API 服务器地址
String get apiServerURL {
  var url = const String.fromEnvironment(
    'API_SERVER_URL',
    defaultValue: defaultAPIServerURL,
  );

  // 当配置的 URL 为 / 时，自动替换为空，用于 Web 端
  if (url == '/') {
    return '';
  }

  return url;
}

String get getHomePath {
  Map<String, String> envVars = Platform.environment;
  if (PlatformTool.isMacOS() || PlatformTool.isLinux()) {
    return '${envVars['HOME'] ?? ''}/.aidea';
  } else if (PlatformTool.isWindows()) {
    return '${envVars['UserProfile'] ?? ''}/.aidea';
  }

  return '.aidea';
}
