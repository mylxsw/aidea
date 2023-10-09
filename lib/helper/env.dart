/// API 服务器地址
String get apiServerURL {
  var url = const String.fromEnvironment(
    'API_SERVER_URL',
    defaultValue: 'https://ai-api.aicode.cc',
  );

  // 当配置的 URL 为 / 时，自动替换为空，用于 Web 端
  if (url == '/') {
    return '';
  }

  return url;
}
