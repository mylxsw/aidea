import 'dart:io';

import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/error.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/deepai_repo.dart';
import 'package:askaide/repo/model/chat_message.dart';
import 'package:askaide/repo/model/message.dart';
import 'package:askaide/repo/model/room.dart';
import 'package:askaide/repo/openai_repo.dart';
import 'package:askaide/repo/stabilityai_repo.dart';
import 'package:dart_openai/openai.dart';

/// 根据聊天类型，调用不同的 API 接口
class ModelResolver {
  late final OpenAIRepository openAIRepo;
  late final DeepAIRepository deepAIRepo;
  late final StabilityAIRepository stabilityAIRepo;

  /// 初始化，设置模型实现
  void init({
    required OpenAIRepository openAIRepo,
    required DeepAIRepository deepAIRepo,
    required StabilityAIRepository stabilityAIRepo,
  }) {
    this.openAIRepo = openAIRepo;
    this.deepAIRepo = deepAIRepo;
    this.stabilityAIRepo = stabilityAIRepo;
  }

  ModelResolver._();
  static final instance = ModelResolver._();

  /// 语音转文字
  Future<String> audioToText(File file) async {
    try {
      return await openAIRepo.audioTranscription(audioFile: file);
    } catch (error) {
      throw resolveErrorMessage(error);
    }
  }

  /// 发起聊天请求
  Future request({
    required Room room,
    required List<Message> contextMessages,
    required Function(ChatStreamRespData value) onMessage,
    int? maxTokens,
  }) async {
    if (room.modelCategory() == modelTypeDeepAI) {
      return await _deepAIModel(
        room: room,
        message: contextMessages.last,
        contextMessages: contextMessages,
        onMessage: (value) {
          onMessage(ChatStreamRespData(content: value));
        },
      );
    } else if (room.modelCategory() == modelTypeStabilityAI) {
      return await _stabilityAIModel(
        room: room,
        message: contextMessages.last,
        contextMessages: contextMessages,
        onMessage: (value) {
          onMessage(ChatStreamRespData(content: value));
        },
      );
    } else {
      return await _openAIModel(
        room: room,
        contextMessages: contextMessages,
        onMessage: onMessage,
        maxTokens: maxTokens,
      );
    }
  }

  /// 调用 StabilityAI API
  Future<void> _stabilityAIModel({
    required Room room,
    required Message message,
    required List<Message> contextMessages,
    required Function(String value) onMessage,
  }) async {
    if (stabilityAIRepo.selfHosted) {
      var res = await stabilityAIRepo.createImageBase64(
        room.modelName(),
        [StabilityAIPrompt(message.text, 0.5)],
      );

      for (var data in res) {
        var path = await writeImageFromBase64(data, 'png');
        // print('图片路径: $path');
        onMessage('\n![image]($path)\n');
      }
    } else {
      var taskId = await stabilityAIRepo.createImageBase64Async(
        room.modelName(),
        [StabilityAIPrompt(message.text, 0.5)],
      );

      await Future.delayed(const Duration(seconds: 10));
      await _waitForTasks(taskId, onMessage);
    }
  }

  Future<void> _waitForTasks(
    String taskId,
    Function(String value) onMessage, {
    int retry = 0,
  }) async {
    var res = await APIServer().asyncTaskStatus(taskId);
    if (res.status == 'success') {
      for (var data in res.resources!) {
        onMessage('\n![image]($data)\n');
      }
    } else if (res.status == 'failed') {
      throw '响应失败: ${res.errors!.join("\n")}';
    } else {
      if (retry > 10) {
        throw '响应超时';
      }

      await Future.delayed(const Duration(seconds: 5));
      await _waitForTasks(taskId, onMessage, retry: retry + 1);
    }
  }

  /// 调用 DeepAI API
  Future<void> _deepAIModel({
    required Room room,
    required Message message,
    required List<Message> contextMessages,
    required Function(String value) onMessage,
  }) async {
    if (deepAIRepo.selfHosted) {
      var res = await deepAIRepo.painting(room.modelName(), message.text);
      onMessage('\n![${res.id}](${res.url})\n');
    } else {
      var taskId =
          await deepAIRepo.paintingAsync(room.modelName(), message.text);
      await Future.delayed(const Duration(seconds: 10));
      await _waitForTasks(taskId, onMessage);
    }
  }

  /// 调用 OpenAI API
  Future<void> _openAIModel({
    required Room room,
    required List<Message> contextMessages,
    required Function(ChatStreamRespData value) onMessage,
    int? maxTokens,
  }) async {
    // 图像模式
    if (OpenAIRepository.isImageModel(room.modelName())) {
      var res = await openAIRepo.createImage(contextMessages.last.text, n: 2);
      for (var url in res) {
        onMessage(ChatStreamRespData(content: '\n![image]($url)\n'));
      }

      return;
    }

    // 聊天模型
    return await openAIRepo.chatStream(
      _buildRequestContext(room, contextMessages),
      onMessage,
      model: room.modelName(),
      maxTokens: maxTokens,
      roomId: room.isLocalRoom ? null : room.id,
    );
  }

  /// 构建机器人请求上下文
  List<ChatMessage> _buildRequestContext(
    Room room,
    List<Message> messages,
  ) {
    // // N 小时内的消息作为一个上下文
    // var recentMessages = messages
    //     .where((e) => e.ts!.millisecondsSinceEpoch > lastAliveTime())
    //     .toList();
    var recentMessages = messages.toList();
    int contextBreakIndex = recentMessages.lastIndexWhere((element) =>
        element.isSystem() && element.type == MessageType.contextBreak);

    if (contextBreakIndex > -1) {
      recentMessages = recentMessages.sublist(contextBreakIndex + 1);
    }

    var contextMessages = recentMessages
        .where((e) => !e.isSystem() && !e.isInitMessage())
        .where((e) => !e.statusIsFailed())
        .map((e) => e.role == Role.receiver
            ? ChatMessage(
                role: OpenAIChatMessageRole.assistant,
                content: e.text,
                images: e.images)
            : ChatMessage(
                role: OpenAIChatMessageRole.user,
                content: e.text,
                images: e.images))
        .toList();

    if (contextMessages.length > room.maxContext * 2) {
      contextMessages =
          contextMessages.sublist(contextMessages.length - room.maxContext * 2);
    }

    if (room.systemPrompt != null && room.systemPrompt != '') {
      contextMessages.insert(
        0,
        ChatMessage(
          role: OpenAIChatMessageRole.system,
          content: room.systemPrompt!,
        ),
      );
    }

    return contextMessages;
  }
}
