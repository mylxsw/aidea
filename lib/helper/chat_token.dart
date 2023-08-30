import 'package:askaide/helper/logger.dart';
import 'package:tiktoken/tiktoken.dart';

/// 计算 message 包含的 token 数量
int tokenCount(String model, String message) {
  try {
    final encoding = encodingForModel(model);
    return encoding.encode(message).length;
  } catch (e) {
    Logger.instance.e(e);
    return -1;
  }
}
