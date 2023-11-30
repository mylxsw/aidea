import 'dart:convert';

import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/env.dart';
import 'package:askaide/helper/error.dart';
import 'package:askaide/helper/http.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/repo/api/article.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api/image_model.dart';
import 'package:askaide/repo/api/info.dart';
import 'package:askaide/repo/api/keys.dart';
import 'package:askaide/repo/api/notification.dart';
import 'package:askaide/repo/api/page.dart';
import 'package:askaide/repo/api/payment.dart';
import 'package:askaide/repo/api/quota.dart';
import 'package:askaide/repo/api/room_gallery.dart';
import 'package:askaide/repo/api/user.dart';
import 'package:askaide/repo/model/group.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class APIServer {
  /// 单例
  static final APIServer _instance = APIServer._internal();
  APIServer._internal();

  factory APIServer() {
    return _instance;
  }

  late String url;
  late String apiToken;
  late String language;

  init(SettingRepository setting) {
    apiToken = setting.stringDefault(settingAPIServerToken, '');
    language = setting.stringDefault(settingLanguage, 'zh');
    url = setting.stringDefault(settingServerURL, apiServerURL);

    setting.listen((settings, key, value) {
      if (key == settingAPIServerToken) {
        apiToken = settings.getDefault(settingAPIServerToken, '');
      }

      if (key == settingLanguage) {
        language = settings.getDefault(settingLanguage, 'zh');
      }

      if (key == settingServerURL) {
        url = settings.getDefault(settingServerURL, apiServerURL);
      }
    });
  }

  final List<DioErrorType> _retryableErrors = [
    DioErrorType.connectTimeout,
    DioErrorType.sendTimeout,
    DioErrorType.receiveTimeout,
  ];

  /// 异常处理
  Object _exceptionHandle(Object e, Object? stackTrace) {
    Logger.instance.e(e, stackTrace: stackTrace as StackTrace?);

    if (e is DioError) {
      if (e.response != null) {
        final resp = e.response!;

        if (resp.data is Map &&
            resp.data['error'] != null &&
            resp.statusCode != 402) {
          return resp.data['error'] ?? e.toString();
        }

        if (resp.statusCode != null) {
          final ret = resolveHTTPStatusCode(resp.statusCode!);
          if (ret != null) {
            return ret;
          }
        }

        return resp.statusMessage ?? e.toString();
      }

      if (_retryableErrors.contains(e.type)) {
        return '请求超时，请重试';
      }
    }

    return e.toString();
  }

  Options _buildRequestOptions({int? requestTimeout = 10000}) {
    return Options(
      headers: _buildAuthHeaders(),
      receiveDataWhenStatusError: true,
      sendTimeout: requestTimeout,
      receiveTimeout: requestTimeout,
    );
  }

  Map<String, dynamic> _buildAuthHeaders() {
    final headers = <String, dynamic>{
      'X-CLIENT-VERSION': clientVersion,
      'X-PLATFORM': PlatformTool.operatingSystem(),
      'X-PLATFORM-VERSION': PlatformTool.operatingSystemVersion(),
      'X-LANGUAGE': language,
    };

    if (apiToken == '') {
      return headers;
    }

    headers['Authorization'] = 'Bearer $apiToken';

    return headers;
  }

  /// 获取用户 ID，如果未登录则返回 null
  int? localUserID() {
    if (apiToken == '') {
      return null;
    }

    // 从 Jwt Token 中获取用户 ID
    final parts = apiToken.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = parts[1];
    final normalized = base64.normalize(payload);
    final resp = utf8.decode(base64.decode(normalized));
    final data = jsonDecode(resp);
    return data['id'];
  }

  Future<T> sendGetRequest<T>(
    String endpoint,
    T Function(dynamic) parser, {
    Map<String, dynamic>? queryParameters,
    int? requestTimeout = 10000,
  }) async {
    return request(
      HttpClient.get(
        '$url$endpoint',
        queryParameters: queryParameters,
        options: _buildRequestOptions(requestTimeout: requestTimeout),
      ),
      parser,
    );
  }

  Future<T> sendCachedGetRequest<T>(
    String endpoint,
    T Function(dynamic) parser, {
    String? subKey,
    Duration duration = const Duration(days: 1),
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    return request(
      HttpClient.getCached(
        '$url$endpoint',
        queryParameters: queryParameters,
        subKey: subKey,
        duration: duration,
        forceRefresh: forceRefresh,
        options: _buildRequestOptions(),
      ),
      parser,
    );
  }

  Future<T> sendPostRequest<T>(
    String endpoint,
    T Function(dynamic) parser, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    VoidCallback? finallyCallback,
  }) async {
    return request(
      HttpClient.post(
        '$url$endpoint',
        queryParameters: queryParameters,
        formData: formData,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendPostJSONRequest<T>(
    String endpoint,
    T Function(dynamic) parser, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    VoidCallback? finallyCallback,
  }) async {
    return request(
      HttpClient.postJSON(
        '$url$endpoint',
        queryParameters: queryParameters,
        data: data,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendPutRequest<T>(
    String endpoint,
    T Function(dynamic) parser, {
    String? subKey,
    Duration duration = const Duration(days: 1),
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    bool forceRefresh = false,
    VoidCallback? finallyCallback,
  }) async {
    return request(
      HttpClient.put(
        '$url$endpoint',
        queryParameters: queryParameters,
        formData: formData,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendPutJSONRequest<T>(
    String endpoint,
    T Function(dynamic) parser, {
    String? subKey,
    Duration duration = const Duration(days: 1),
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    bool forceRefresh = false,
    VoidCallback? finallyCallback,
  }) async {
    return request(
      HttpClient.putJSON(
        '$url$endpoint',
        queryParameters: queryParameters,
        data: data,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendDeleteRequest<T>(
    String endpoint,
    T Function(dynamic) parser, {
    String? subKey,
    Duration duration = const Duration(days: 1),
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    bool forceRefresh = false,
    VoidCallback? finallyCallback,
  }) async {
    return request(
      HttpClient.delete(
        '$url$endpoint',
        queryParameters: queryParameters,
        formData: formData,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> request<T>(
    Future<Response<dynamic>> respFuture,
    T Function(dynamic) parser, {
    VoidCallback? finallyCallback,
  }) async {
    try {
      final resp = await respFuture;
      if (resp.statusCode != 200) {
        return Future.error(resp.data['error']);
      }

      // Logger.instance.d("API Response: ${resp.data}");

      return parser(resp);
    } catch (e, stackTrace) {
      return Future.error(_exceptionHandle(e, stackTrace));
    } finally {
      finallyCallback?.call();
    }
  }

  String? _cacheSubKey() {
    final localUserId = localUserID();
    if (localUserId == null) {
      return null;
    }

    return 'local-uid=$localUserId';
  }

  /// 用户配额详情
  Future<QuotaResp?> quotaDetails() async {
    return sendGetRequest(
      '/v1/users/quota',
      (resp) => QuotaResp.fromJson(resp.data),
    );
  }

  /// 用户信息
  Future<UserInfo?> userInfo({bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/users/current',
      (resp) => UserInfo.fromJson(resp.data),
      duration: const Duration(minutes: 1),
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
    );
  }

  /// 检查手机号是否存在
  Future<UserExistenceResp> checkPhoneExists(String username) async {
    return sendPostRequest(
      '/v1/auth/2in1/check',
      (resp) => UserExistenceResp.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'username': username,
      }),
    );
  }

  /// 手机登录或者注册账号
  Future<SignInResp> signInOrUp({
    required String username,
    required String verifyCodeId,
    required String verifyCode,
    String? inviteCode,
  }) async {
    return sendPostRequest(
      '/v1/auth/2in1/sign-inup',
      (resp) => SignInResp.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'username': username,
        'verify_code_id': verifyCodeId,
        'verify_code': verifyCode,
        'invite_code': inviteCode,
      }),
    );
  }

  /// 使用密码登录
  Future<SignInResp> signInWithPassword(
      String username, String password) async {
    return sendPostRequest(
      '/v1/auth/sign-in',
      (resp) => SignInResp.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'username': username,
        'password': password,
      }),
    );
  }

  /// 使用 Apple 账号登录
  Future<SignInResp> signInWithApple({
    required String userIdentifier,
    String? givenName,
    String? familyName,
    String? email,
    String? authorizationCode,
    String? identityToken,
  }) async {
    return sendPostRequest(
      '/v1/auth/sign-in-apple/',
      (resp) => SignInResp.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'user_identifier': userIdentifier,
        'given_name': givenName,
        'family_name': familyName,
        'email': email,
        'authorization_code': authorizationCode,
        'identity_token': identityToken,
        'is_ios': PlatformTool.isIOS() || PlatformTool.isMacOS(),
      }),
    );
  }

  /// 获取代理服务器列表
  Future<List<String>> proxyServers(String service) async {
    return sendCachedGetRequest(
      '/v1/proxy/servers',
      (resp) =>
          (resp['servers'][service] as List).map((e) => e.toString()).toList(),
      subKey: _cacheSubKey(),
    );
  }

  /// 获取模型列表
  Future<List<Model>> models() async {
    return sendCachedGetRequest(
      '/v1/models',
      (resp) {
        var models = <Model>[];
        for (var model in resp.data) {
          models.add(Model.fromJson(model));
        }

        return models;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 获取系统级提示语列表
  Future<List<Prompt>> prompts() async {
    return sendCachedGetRequest(
      '/v1/prompts',
      (resp) {
        var prompts = <Prompt>[];
        for (var prompt in resp.data) {
          prompts.add(Prompt(prompt['title'], prompt['content']));
        }

        return prompts;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 获取提示语示例
  Future<List<ChatExample>> examples() async {
    return sendCachedGetRequest(
      '/v1/examples',
      (resp) {
        var examples = <ChatExample>[];
        for (var example in resp.data) {
          examples.add(ChatExample(
            example['title'],
            content: example['content'],
            models: example['models'],
          ));
        }

        return examples;
      },
      subKey: _cacheSubKey(),
    );
  }

  ///   获取头像列表
  Future<List<String>> avatars() async {
    return sendCachedGetRequest(
      '/v1/images/avatar',
      (resp) {
        return (resp.data['avatars'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      },
    );
  }

  ///  获取背景图列表
  Future<List<BackgroundImage>> backgrounds() async {
    return sendCachedGetRequest(
      '/v1/images/background',
      (resp) {
        var images = <BackgroundImage>[];
        for (var img in resp.data['preset']) {
          images.add(BackgroundImage.fromJson(img));
        }

        return images;
      },
    );
  }

  Future<TranslateText> translate(
    String text, {
    String from = 'auto',
  }) async {
    return sendPostRequest(
      '/v1/translate/',
      (resp) => TranslateText.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'text': text,
        'from': from,
      }),
    );
  }

  /// 上传初始化
  Future<UploadInitResponse> uploadInit(
    String name,
    int filesize, {
    String? usage,
  }) async {
    return sendPostRequest(
      '/v1/storage/upload-init',
      (resp) => UploadInitResponse.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'filesize': filesize,
        'name': name,
        'usage': usage,
      }),
    );
  }

  /// 获取模型支持的提示语示例
  Future<List<ChatExample>> exampleByTag(String tag) async {
    return sendCachedGetRequest(
      '/v1/examples/tags/$tag',
      (resp) {
        var examples = <ChatExample>[];
        for (var example in resp.data) {
          examples.add(ChatExample(
            example['title'],
            content: example['content'],
            models: ((example['models'] ?? []) as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
          ));
        }
        return examples;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 获取模型支持的反向提示语示例
  Future<List<ChatExample>> negativePromptExamples(String tag) async {
    return sendCachedGetRequest(
      '/v1/examples/negative-prompts/$tag',
      (resp) {
        var examples = <ChatExample>[];
        for (var example in resp.data['data']) {
          examples.add(ChatExample(
            example['title'],
            content: example['content'],
          ));
        }
        return examples;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 获取模型支持的提示语示例
  Future<List<ChatExample>> example(String model) async {
    return sendCachedGetRequest(
      '/v1/examples/$model',
      (resp) {
        var examples = <ChatExample>[];
        for (var example in resp.data) {
          examples.add(ChatExample(
            example['title'],
            content: example['content'],
            models: ((example['models'] ?? []) as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
          ));
        }
        return examples;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 模型风格列表
  Future<List<ModelStyle>> modelStyles(String category) async {
    return sendCachedGetRequest(
      '/v1/models/$category/styles',
      (resp) {
        var items = <ModelStyle>[];
        for (var item in resp.data) {
          items.add(ModelStyle.fromJson(item));
        }
        return items;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 创意岛项目列表
  Future<CreativeIslandItems> creativeIslandItems({
    required String mode,
    bool cache = true,
  }) async {
    return sendCachedGetRequest(
      '/v1/creative-island/items',
      (resp) {
        var items = <CreativeIslandItem>[];
        for (var item in resp.data['items']) {
          items.add(CreativeIslandItem.fromJson(item));
        }
        final categories = (resp.data['categories'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        return CreativeIslandItems(
          items,
          categories,
          backgroundImage: resp.data['background_image'],
        );
      },
      queryParameters: <String, dynamic>{"mode": mode},
      duration: const Duration(minutes: 60),
      forceRefresh: !cache,
    );
  }

  /// 创意岛项目
  Future<CreativeIslandItem> creativeIslandItem(String id) async {
    return sendCachedGetRequest(
      '/v1/creative-island/items/$id',
      (resp) => CreativeIslandItem.fromJson(resp.data),
      subKey: _cacheSubKey(),
      duration: const Duration(minutes: 60),
    );
  }

  /// 创作岛生成消耗量预估
  Future<QuotaEvaluated> creativeIslandCompletionsEvaluate(
      String id, Map<String, dynamic> params) async {
    return sendPostRequest(
      '/v1/creative-island/completions/$id/evaluate',
      (resp) => QuotaEvaluated.fromJson(resp.data),
      formData: params,
    );
  }

  /// 创意岛项目生成数据
  Future<List<String>> creativeIslandCompletions(
      String id, Map<String, dynamic> params) async {
    return sendPostRequest(
      '/v1/creative-island/completions/$id',
      (resp) {
        final cicResp = CreativeIslandCompletionResp.fromJson(resp.data);
        switch (cicResp.type) {
          case creativeIslandCompletionTypeURLImage:
            return cicResp.resources;
          default:
            return <String>[cicResp.content];
        }
      },
      formData: params,
    );
  }

  /// 创意岛项目生成数据
  Future<String> creativeIslandCompletionsAsync(
      String id, Map<String, dynamic> params) async {
    params["mode"] = 'async';

    return sendPostRequest(
      '/v1/creative-island/completions/$id',
      (resp) {
        final cicResp = CreativeIslandCompletionAsyncResp.fromJson(resp.data);
        return cicResp.taskId;
      },
      formData: params,
    );
  }

  Future<QuotaEvaluated> creativeIslandCompletionsEvaluateV2(
      Map<String, dynamic> params) async {
    return sendPostRequest(
      '/v2/creative-island/completions/evaluate',
      (resp) => QuotaEvaluated.fromJson(resp.data),
      formData: params,
    );
  }

  Future<String> creativeIslandCompletionsAsyncV2(
      Map<String, dynamic> params) async {
    return sendPostRequest(
      '/v2/creative-island/completions',
      (resp) {
        final cicResp = CreativeIslandCompletionAsyncResp.fromJson(resp.data);
        return cicResp.taskId;
      },
      formData: params,
    );
  }

  Future<String> creativeIslandArtisticTextCompletionsAsyncV2(
      Map<String, dynamic> params) async {
    return sendPostRequest(
      '/v2/creative-island/completions/artistic-text',
      (resp) {
        final cicResp = CreativeIslandCompletionAsyncResp.fromJson(resp.data);
        return cicResp.taskId;
      },
      formData: params,
    );
  }

  Future<String> creativeIslandImageDirectEdit(
    String endpoint,
    Map<String, dynamic> params,
  ) async {
    return sendPostRequest(
      '/v2/creative-island/completions/$endpoint',
      (resp) {
        final cicResp = CreativeIslandCompletionAsyncResp.fromJson(resp.data);
        return cicResp.taskId;
      },
      formData: params,
    );
  }

  /// 模型风格列表
  Future<List<ModelStyle>> modelStylesV2({String? modelId}) async {
    return sendCachedGetRequest(
      '/v2/models/styles',
      (resp) {
        var items = <ModelStyle>[];
        for (var item in resp.data) {
          items.add(ModelStyle.fromJson(item));
        }
        return items;
      },
      queryParameters: {'model_id': modelId},
    );
  }

  /// 创作岛能力
  Future<CreativeIslandCapacity> creativeIslandCapacity(
      {required String mode, required String id}) async {
    return sendCachedGetRequest(
      '/v2/creative-island/capacity',
      (resp) {
        return CreativeIslandCapacity.fromJson(resp.data);
      },
      queryParameters: {'mode': mode, 'id': id},
    );
  }

  /// 异步任务执行状态查询
  Future<AsyncTaskResp> asyncTaskStatus(String taskId) async {
    return sendGetRequest(
      '/v1/tasks/$taskId/status',
      (resp) => AsyncTaskResp.fromJson(resp.data),
    );
  }

  /// 发送重置密码验证码
  Future<String> sendResetPasswordCodeForSignedUser() async {
    return sendPostRequest(
      '/v1/users/reset-password/sms-code',
      (resp) => resp.data['id'],
    );
  }

  /// 用户重置密码
  Future<void> resetPasswordByCodeSignedUser({
    required String password,
    required String verifyCodeId,
    required String verifyCode,
  }) async {
    return sendPostRequest(
      '/v1/users/reset-password',
      (resp) => resp.data['id'],
      formData: Map<String, dynamic>.from({
        'password': password,
        'verify_code_id': verifyCodeId,
        'verify_code': verifyCode,
      }),
    );
  }

  /// 使用邮箱验证码重置密码
  Future<void> resetPasswordByCode({
    required String username,
    required String password,
    required String verifyCodeId,
    required String verifyCode,
  }) async {
    return sendPostRequest(
      '/v1/auth/reset-password',
      (resp) => resp.data['id'],
      formData: Map<String, dynamic>.from({
        'username': username,
        'password': password,
        'verify_code_id': verifyCodeId,
        'verify_code': verifyCode,
      }),
    );
  }

  /// 发送找回密码验证码
  Future<String> sendResetPasswordCode(
    String username, {
    required String verifyType,
  }) async {
    return sendPostRequest(
      '/v1/auth/reset-password/$verifyType-code',
      (resp) => resp.data['id'],
      formData: Map<String, dynamic>.from({
        'username': username,
      }),
    );
  }

  /// 发送注册或者登录短信验证码
  Future<String> sendSigninOrSignupVerifyCode(
    String username, {
    required String verifyType,
    required bool isSignup,
  }) {
    if (isSignup) {
      return sendSignupVerifyCode(username, verifyType: verifyType);
    }

    return sendSigninVerifyCode(username, verifyType: verifyType);
  }

  /// 发送登录验证码
  Future<String> sendSigninVerifyCode(
    String username, {
    required String verifyType,
  }) async {
    return sendPostRequest(
      '/v1/auth/sign-in/$verifyType-code',
      (resp) => resp.data['id'],
      formData: Map<String, dynamic>.from({
        'username': username,
      }),
    );
  }

  /// 发送注册验证码
  Future<String> sendSignupVerifyCode(
    String username, {
    required String verifyType,
  }) async {
    return sendPostRequest(
      '/v1/auth/sign-up/$verifyType-code',
      (resp) => resp.data['id'],
      formData: Map<String, dynamic>.from({
        'username': username,
      }),
    );
  }

  /// 发送绑定手机号码验证码
  Future<String> sendBindPhoneCode(String username) async {
    return sendPostRequest(
      '/v1/auth/bind-phone/sms-code',
      (resp) => resp.data['id'],
      formData: Map<String, dynamic>.from({
        'username': username,
      }),
    );
  }

  /// 绑定手机号
  Future<SignInResp> bindPhone({
    required String username,
    required String verifyCodeId,
    required String verifyCode,
    String? inviteCode,
  }) async {
    return sendPostRequest(
      '/v1/auth/bind-phone',
      (resp) => SignInResp.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'username': username,
        'verify_code_id': verifyCodeId,
        'verify_code': verifyCode,
        'invite_code': inviteCode,
      }),
    );
  }

  /// 注册账号
  Future<SignInResp> signupWithPassword({
    required String username,
    required String password,
    required String verifyCodeId,
    required String verifyCode,
    String? inviteCode,
  }) async {
    return sendPostRequest(
      '/v1/auth/sign-up',
      (resp) => SignInResp.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'username': username,
        'password': password,
        'verify_code_id': verifyCodeId,
        'verify_code': verifyCode,
        'invite_code': inviteCode,
      }),
    );
  }

  /// 发送账号销毁手机验证码
  Future<String> sendDestroyAccountSMSCode() async {
    return sendPostRequest(
      '/v1/users/destroy/sms-code',
      (resp) => resp.data['id'],
    );
  }

  /// 账号销毁
  Future<void> destroyAccount({
    required String verifyCodeId,
    required String verifyCode,
  }) async {
    return sendDeleteRequest(
      '/v1/users/destroy',
      (resp) {},
      formData: Map<String, dynamic>.from({
        'verify_code_id': verifyCodeId,
        'verify_code': verifyCode,
      }),
    );
  }

  /// 版本检查
  Future<VersionCheckResp> versionCheck({bool cache = true}) async {
    return sendCachedGetRequest(
      '/public/info/version-check',
      (resp) => VersionCheckResp.fromJson(resp.data),
      queryParameters: Map<String, dynamic>.from({
        'version': clientVersion,
        'os': PlatformTool.operatingSystem(),
        'os_version': PlatformTool.operatingSystemVersion(),
      }),
      duration: const Duration(minutes: 180),
      forceRefresh: !cache,
    );
  }

  /// Apple 支付项目列表
  Future<ApplePayProducts> applePayProducts() async {
    return sendGetRequest(
      '/v1/payment/apple/products',
      (resp) => ApplePayProducts.fromJson(resp.data),
    );
  }

  /// 其它支付项目列表
  Future<ApplePayProducts> otherPayProducts() async {
    return sendGetRequest(
      '/v1/payment/others/products',
      (resp) => ApplePayProducts.fromJson(resp.data),
    );
  }

  /// 发起 Apple Pay
  Future<String> createApplePay(String productId) async {
    return sendPostRequest(
      '/v1/payment/apple',
      (resp) => resp.data['id'],
      formData: Map<String, dynamic>.from({
        'product_id': productId,
      }),
    );
  }

  /// 发起支付
  Future<OtherPayCreatedReponse> createOtherPay(String productId,
      {required String source}) async {
    return sendPostRequest(
      '/v1/payment/others',
      (resp) => OtherPayCreatedReponse.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'product_id': productId,
        'source': source,
      }),
    );
  }

  /// 其它支付客户端确认
  Future<String> otherPayClientConfirm(Map<String, dynamic> params) async {
    return sendPostRequest(
      '/v1/payment/others/client-confirm',
      (resp) => resp.data['status'],
      formData: params,
    );
  }

  /// 查询支付状态
  Future<PaymentStatus> queryPaymentStatus(String paymentId) async {
    return sendGetRequest(
      '/v1/payment/status/$paymentId',
      (resp) => PaymentStatus.fromJson(resp.data),
    );
  }

  /// 更新 Apple Pay 支付信息
  Future<String> updateApplePay(
    String paymentId, {
    required String productId,
    required String? localVerifyData,
    required String? serverVerifyData,
    required String? verifyDataSource,
  }) async {
    return sendPutRequest(
      '/v1/payment/apple/$paymentId',
      (resp) => resp.data['status'],
      formData: Map<String, dynamic>.from({
        'product_id': productId,
        'local_verify_data': localVerifyData,
        'server_verify_data': serverVerifyData,
        'verify_data_source': verifyDataSource,
      }),
    );
  }

  /// 验证 Apple Pay 支付结果
  Future<String> verifyApplePay(
    String paymentId, {
    required String productId,
    required String? purchaseId,
    required String? transactionDate,
    required String? localVerifyData,
    required String? serverVerifyData,
    required String? verifyDataSource,
    required String status,
  }) async {
    return sendPostRequest(
      '/v1/payment/apple/$paymentId/verify',
      (resp) => resp.data['status'],
      formData: Map<String, dynamic>.from({
        'product_id': productId,
        'purchase_id': purchaseId,
        'transaction_date': transactionDate,
        'local_verify_data': localVerifyData,
        'server_verify_data': serverVerifyData,
        'verify_data_source': verifyDataSource,
        'status': status,
      }),
    );
  }

  /// 取消 Apple Pay
  Future<String> cancelApplePay(String paymentId, {String? reason}) async {
    return sendDeleteRequest(
      '/v1/payment/apple/$paymentId',
      (resp) => resp.data['status'],
      formData: Map<String, dynamic>.from({
        'reason': reason,
      }),
    );
  }

  /// 获取房间列表
  Future<RoomsResponse> rooms({bool cache = true}) async {
    return sendCachedGetRequest(
      '/v2/rooms',
      (resp) {
        return RoomsResponse.fromJson(resp.data);
      },
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
    );
  }

  /// 获取单个房间信息
  Future<RoomInServer> room({required roomId, bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/rooms/$roomId',
      (resp) => RoomInServer.fromJson(resp.data),
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
      duration: const Duration(minutes: 120),
    );
  }

  /// 创建群聊房间
  Future<int> createGroupRoom({
    required String name,
    String? description,
    String? avatarUrl,
    List<GroupMember>? members,
  }) async {
    return sendPostJSONRequest(
      '/v1/group-chat',
      (resp) => resp.data["group_id"],
      data: {
        'name': name,
        'avatar_url': avatarUrl,
        'members': members?.map((e) => e.toJson()).toList(),
      },
      finallyCallback: () {
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v2/rooms', requestMethod: 'GET');
      },
    );
  }

  /// 更新群聊房间
  Future<void> updateGroupRoom({
    required int groupId,
    required String name,
    String? description,
    String? avatarUrl,
    List<GroupMember>? members,
  }) async {
    return sendPutJSONRequest(
      '/v1/group-chat/$groupId',
      (resp) {},
      data: {
        'name': name,
        'avatar_url': avatarUrl,
        'members': members?.map((e) => e.toJson()).toList(),
      },
      finallyCallback: () {
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v2/rooms', requestMethod: 'GET');

        HttpClient.cacheManager.deleteByPrimaryKey(
            '$url/v1/group-chat/$groupId',
            requestMethod: 'GET');
      },
    );
  }

  /// 创建房间
  Future<int> createRoom({
    required String name,
    required String model,
    required String vendor,
    String? description,
    String? systemPrompt,
    String? avatarUrl,
    int? avatarId,
    int? maxContext,
    String? initMessage,
  }) async {
    return sendPostRequest(
      '/v1/rooms',
      (resp) => resp.data["id"],
      formData: Map<String, dynamic>.from({
        'name': name,
        'model': model,
        'vendor': vendor,
        'description': description,
        'system_prompt': systemPrompt,
        'avatar_url': avatarUrl,
        'avatar_id': avatarId,
        'max_context': maxContext,
        'init_message': initMessage,
      }),
      finallyCallback: () {
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v2/rooms', requestMethod: 'GET');
      },
    );
  }

  /// 更新房间信息
  Future<RoomInServer> updateRoom({
    required int roomId,
    required String name,
    required String model,
    required String vendor,
    String? description,
    String? systemPrompt,
    String? avatarUrl,
    int? avatarId,
    int? maxContext,
    String? initMessage,
  }) async {
    return sendPutRequest(
      '/v1/rooms/$roomId',
      (resp) => RoomInServer.fromJson(resp.data),
      formData: Map<String, dynamic>.from({
        'name': name,
        'model': model,
        'vendor': vendor,
        'description': description,
        'system_prompt': systemPrompt,
        'avatar_url': avatarUrl,
        'avatar_id': avatarId,
        'max_context': maxContext,
        'init_message': initMessage,
      }),
      finallyCallback: () {
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v2/rooms', requestMethod: 'GET');
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v1/rooms/$roomId', requestMethod: 'GET');
      },
    );
  }

  /// 删除房间
  Future<void> deleteRoom({required int roomId}) async {
    return sendDeleteRequest(
      '/v1/rooms/$roomId',
      (resp) {},
      finallyCallback: () {
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v2/rooms', requestMethod: 'GET');
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v1/rooms/$roomId', requestMethod: 'GET');
      },
    );
  }

  /// 创作岛 Gallery
  Future<List<CreativeItemInServer>> creativeUserGallery({
    required String mode,
    String? model,
    bool cache = true,
  }) async {
    return sendCachedGetRequest(
      '/v1/creative-island/gallery',
      (resp) {
        var res = <CreativeItemInServer>[];
        for (var item in resp.data['data']) {
          res.add(CreativeItemInServer.fromJson(item));
        }

        return res;
      },
      queryParameters: <String, dynamic>{"mode": mode, "model": model},
      forceRefresh: !cache,
      duration: const Duration(minutes: 30),
    );
  }

  /// 图片模型列表
  Future<List<ImageModel>> imageModels() async {
    return sendCachedGetRequest(
      '/v2/creative-island/models',
      (resp) {
        var res = <ImageModel>[];
        for (var item in resp.data['data']) {
          res.add(ImageModel.fromJson(item));
        }

        return res;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 图片模型滤镜列表（风格）
  Future<List<ImageModelFilter>> imageModelFilters() async {
    return sendCachedGetRequest(
      '/v2/creative-island/filters',
      (resp) {
        var res = <ImageModelFilter>[];
        for (var item in resp.data['data']) {
          res.add(ImageModelFilter.fromJson(item));
        }

        return res;
      },
      subKey: _cacheSubKey(),
    );
  }

  /// 创作岛历史记录（全量）
  Future<PagedData<CreativeItemInServer>> creativeHistories({
    String? mode,
    bool cache = true,
    int? page,
    int? perPage,
  }) async {
    return sendGetRequest(
      '/v2/creative-island/histories',
      (resp) {
        var filters = <int, String>{};
        for (var filter in resp.data['filters']) {
          filters[filter['id']] = filter['name'];
        }

        var res = <CreativeItemInServer>[];
        for (var item in resp.data['data']) {
          final ret = CreativeItemInServer.fromJson(item);
          if (ret.params['filter_id'] != null && filters.isNotEmpty) {
            ret.filterName = filters[ret.params['filter_id']];
          }

          res.add(ret);
        }

        return PagedData(
          data: res,
          page: resp.data['page'] ?? 1,
          perPage: resp.data['per_page'] ?? 20,
          total: resp.data['total'],
          lastPage: resp.data['last_page'],
        );
      },
      queryParameters: <String, dynamic>{
        "mode": mode,
        "page": page,
        "per_page": perPage,
      },
    );
  }

  /// 分享创作岛历史记录到 Gallery
  Future<void> shareCreativeHistoryToGallery({required int historyId}) {
    return sendPostRequest(
      '/v2/creative-island/histories/$historyId/share',
      (resp) {},
    );
  }

  /// 取消分享创作岛历史记录到 Gallery
  Future<void> cancelShareCreativeHistoryToGallery({required int historyId}) {
    return sendDeleteRequest(
      '/v2/creative-island/histories/$historyId/share',
      (resp) {},
    );
  }

  /// 封禁创作岛历史记录
  Future<void> forbidCreativeHistoryItem({required int historyId}) {
    return sendPutRequest(
      '/v1/admin/creative-island/histories/$historyId/forbid',
      (resp) {},
    );
  }

  /// 创作岛历史记录
  Future<List<CreativeItemInServer>> creativeItemHistories(String islandId,
      {bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/creative-island/items/$islandId/histories',
      (resp) {
        var res = <CreativeItemInServer>[];
        for (var item in resp.data['data']) {
          res.add(CreativeItemInServer.fromJson(item));
        }

        return res;
      },
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
      duration: const Duration(minutes: 30),
    );
  }

  /// 获取创作岛项目历史详情
  Future<CreativeItemInServer> creativeHistoryItem({
    required hisId,
    bool cache = true,
  }) async {
    return sendCachedGetRequest(
      '/v2/creative-island/histories/$hisId',
      (resp) => CreativeItemInServer.fromJson(resp.data),
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
      duration: const Duration(minutes: 1),
    );
  }

  /// 删除创作岛项目历史记录
  Future<void> deleteCreativeHistoryItem(String islandId,
      {required hisId}) async {
    return sendDeleteRequest(
      '/v1/creative-island/items/$islandId/histories/$hisId',
      (resp) {},
    );
  }

  /// 获取用户智慧果消耗历史记录
  Future<List<QuotaUsageInDay>> quotaUsedStatistics({bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/users/quota/usage-stat',
      (resp) {
        var res = <QuotaUsageInDay>[];
        for (var item in resp.data['usages']) {
          res.add(QuotaUsageInDay.fromJson(item));
        }

        return res;
      },
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
      duration: const Duration(minutes: 30),
    );
  }

  /// 获取用户智慧果消耗历史记录详情
  Future<List<QuotaUsageDetailInDay>> quotaUsedDetails(
      {required String date}) async {
    return sendGetRequest(
      '/v1/users/quota/usage-stat/$date',
      (resp) {
        var res = <QuotaUsageDetailInDay>[];
        for (var item in resp.data['data']) {
          res.add(QuotaUsageDetailInDay.fromJson(item));
        }

        return res;
      },
    );
  }

  Future<PagedData<CreativeGallery>> creativeGallery({
    bool cache = true,
    int page = 1,
    int perPage = 20,
  }) async {
    return sendCachedGetRequest(
      '/v1/creatives/gallery',
      (resp) {
        var res = <CreativeGallery>[];
        for (var item in resp.data['data']) {
          res.add(CreativeGallery.fromJson(item));
        }

        return PagedData(
          page: resp.data['page'] ?? 1,
          perPage: resp.data['per_page'] ?? 20,
          total: resp.data['total'],
          lastPage: resp.data['last_page'],
          data: res,
        );
      },
      queryParameters: Map.of({
        'page': page,
        'per_page': perPage,
      }),
      forceRefresh: !cache,
      duration: const Duration(minutes: 60),
    );
  }

  Future<CreativeGalleryItemResponse> creativeGalleryItem({
    required int id,
    bool cache = true,
  }) async {
    return sendCachedGetRequest(
      '/v1/creatives/gallery/$id',
      (resp) => CreativeGalleryItemResponse.fromJson(resp.data),
      forceRefresh: !cache,
      duration: const Duration(minutes: 30),
    );
  }

  /// 文本转语音
  Future<List<String>> textToVoice({required String text}) async {
    return sendPostRequest(
      '/v1/voice/text2voice',
      formData: {'text': text},
      (resp) => (resp.data['results'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  /// 故障日志上报
  Future<void> diagnosisUpload({required String data}) async {
    // data 从尾部开始截取 5000 个字符
    if (data.length > 5000) {
      data = data.substring(data.length - 5000);
    }

    return sendPostRequest(
      '/v1/diagnosis/upload',
      formData: {'data': data},
      (resp) {},
    );
  }

  /// 获取分享信息
  Future<ShareInfo> shareInfo() async {
    return sendCachedGetRequest(
      '/public/share/info',
      (resp) => ShareInfo.fromJson(resp.data),
      duration: const Duration(minutes: 30),
      subKey: _cacheSubKey(),
    );
  }

  Future<RoomGalleryResponse> roomGalleries({bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/room-galleries',
      (resp) {
        return RoomGalleryResponse.fromJson(resp.data);
      },
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
    );
  }

  Future<RoomGallery> roomGalleryItem(
      {required int id, bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/room-galleries/$id',
      (resp) => RoomGallery.fromJson(resp.data),
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
    );
  }

  Future<void> copyRoomGallery({required List<int> ids}) async {
    return sendPostRequest(
      '/v1/room-galleries/copy',
      formData: {'ids': ids.join(',')},
      (resp) {},
    );
  }

  Future<List<CreativeIslandItemV2>> creativeIslandItemsV2(
      {bool cache = true}) async {
    return sendCachedGetRequest(
      '/v2/creative/items',
      (resp) {
        var items = <CreativeIslandItemV2>[];
        for (var item in resp.data['data']) {
          items.add(CreativeIslandItemV2.fromJson(item));
        }
        return items;
      },
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
    );
  }

  /// 绘图提示语 Tags
  Future<List<PromptCategory>> drawPromptTags({bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/examples/draw/prompt-tags',
      (resp) {
        var items = <PromptCategory>[];
        for (var item in resp.data['data']) {
          items.add(PromptCategory.fromJson(item));
        }
        return items;
      },
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
    );
  }

  /// 更新用户头像
  Future<void> updateUserAvatar({required String avatarURL}) async {
    return sendPostRequest(
      '/v1/users/current/avatar',
      (resp) {},
      formData: {'avatar_url': avatarURL},
      finallyCallback: () {
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v1/users/current', requestMethod: 'GET');
      },
    );
  }

  /// 更新用户昵称
  Future<void> updateUserRealname({required String realname}) async {
    return sendPostRequest(
      '/v1/users/current/realname',
      (resp) {},
      formData: {'realname': realname},
      finallyCallback: () {
        HttpClient.cacheManager
            .deleteByPrimaryKey('$url/v1/users/current', requestMethod: 'GET');
      },
    );
  }

  /// 服务器支持的能力
  Future<Capabilities> capabilities({bool cache = true}) async {
    return sendCachedGetRequest(
      '/public/info/capabilities',
      (resp) => Capabilities.fromJson(resp.data),
      forceRefresh: !cache,
    );
  }

  /// 用户免费聊天次数统计
  Future<List<FreeModelCount>> userFreeStatistics() async {
    return sendGetRequest(
      '/v1/users/stat/free-chat-counts',
      (resp) {
        var items = <FreeModelCount>[];
        for (var item in resp.data['data']) {
          items.add(FreeModelCount.fromJson(item));
        }
        return items;
      },
    );
  }

  /// 用户免费聊天次数统计(单个模型)
  Future<FreeModelCount> userFreeStatisticsForModel(
      {required String model}) async {
    return sendGetRequest(
      '/v1/users/stat/free-chat-counts/$model',
      (resp) => FreeModelCount.fromJson(resp.data),
    );
  }

  /// 通知信息（促销事件）
  Future<Map<String, List<PromotionEvent>>> notificationPromotionEvents(
      {bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/notifications/promotions',
      (value) {
        var res = <String, List<PromotionEvent>>{};
        for (var item in value.data['data']) {
          if (res[item['id']] == null) {
            res[item['id']] = [];
          }

          res[item['id']] = [
            ...res[item['id']]!,
            PromotionEvent.fromJson(item),
          ];
        }

        return res;
      },
      subKey: _cacheSubKey(),
      forceRefresh: !cache,
    );
  }

  /// 更新自定义模型
  Future<void> updateCustomHomeModels({required List<String> models}) async {
    return sendPostRequest(
      '/v1/users/custom/home-models',
      (value) => {},
      formData: {
        'models': models.join(','),
      },
    );
  }

  /// 群聊 ////////////////////////////////////////////////////////////////////

  /// 群组列表
  Future<List<RoomInServer>> chatGroups({bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/group-chat',
      (value) {
        var res = <RoomInServer>[];
        for (var item in value.data['data']) {
          res.add(RoomInServer.fromJson(item));
        }

        return res;
      },
      forceRefresh: !cache,
    );
  }

  /// 群组详情
  Future<ChatGroup> chatGroup(int groupId, {bool cache = true}) async {
    return sendCachedGetRequest(
      '/v1/group-chat/$groupId',
      (value) => ChatGroup.fromJson(value.data),
      forceRefresh: !cache,
    );
  }

  /// 群组聊天消息列表
  Future<OffsetPageData<GroupMessage>> chatGroupMessages(
    int groupId, {
    int startId = 0,
    int? perPage,
    bool cache = true,
  }) async {
    return sendCachedGetRequest(
      '/v1/group-chat/$groupId/messages',
      (resp) {
        var res = <GroupMessage>[];
        for (var item in resp.data['data']) {
          res.add(GroupMessage.fromJson(item));
        }

        return OffsetPageData(
          data: res,
          lastId: resp.data['last_id'],
          startId: resp.data['start_id'],
          perPage: resp.data['per_page'],
        );
      },
      queryParameters: {
        'start_id': startId,
        'per_page': perPage,
      },
      forceRefresh: !cache,
    );
  }

  /// 发起群聊消息
  Future<GroupChatSendResponse> chatGroupSendMessage(
      int groupId, GroupChatSendRequest req) async {
    return sendPostJSONRequest(
      '/v1/group-chat/$groupId/chat',
      (resp) {
        return GroupChatSendResponse.fromJson(resp.data);
      },
      data: req.toJson(),
    );
  }

  /// 群聊发送系统消息
  Future<GroupMessage> chatGroupSendSystemMessage(
    int groupId, {
    required String messageType,
    String? message,
  }) async {
    return sendPostRequest(
      '/v1/group-chat/$groupId/chat-system',
      (resp) => GroupMessage.fromJson(resp['data']),
      formData: {
        'message_type': messageType,
        'message': message,
      },
    );
  }

  /// 群组聊天消息状态
  Future<List<GroupMessage>> chatGroupMessageStatus(
      int groupId, List<int> messageIds) async {
    return sendGetRequest(
      '/v1/group-chat/$groupId/chat-messages',
      (resp) {
        var res = <GroupMessage>[];
        for (var item in resp.data['data']) {
          res.add(GroupMessage.fromJson(item));
        }

        return res;
      },
      queryParameters: {
        "message_ids": messageIds.join(','),
      },
    );
  }

  /// 清空群组聊天消息
  Future<void> chatGroupDeleteAllMessages(int groupId) async {
    return sendDeleteRequest('/v1/group-chat/$groupId/all-chat', (resp) {});
  }

  /// 删除群组聊天消息
  Future<void> chatGroupDeleteMessage(int groupId, int messageId) async {
    return sendDeleteRequest(
        '/v1/group-chat/$groupId/chat/$messageId', (resp) {});
  }

  /// API 模式 ////////////////////////////////////////////////////////////////////
  /// 查询用户所有的 API Keys
  Future<List<UserAPIKey>> userAPIKeys() async {
    return sendGetRequest('/v1/api-keys', (data) {
      return ((data.data['data'] ?? []) as List<dynamic>)
          .map((e) => UserAPIKey.fromJson(e))
          .toList();
    });
  }

  /// 查询指定 API Key
  Future<UserAPIKey> userAPIKeyDetail({required int id}) async {
    return sendGetRequest('/v1/api-keys/$id', (data) {
      return UserAPIKey.fromJson(data.data['data']);
    });
  }

  /// 创建 API Key
  Future<String> createAPIKey({required String name}) async {
    return sendPostRequest(
      '/v1/api-keys',
      (data) => data.data['key'],
      formData: {'name': name},
    );
  }

  /// 删除 API Key
  Future<void> deleteAPIKey({required int id}) async {
    return sendDeleteRequest('/v1/api-keys/$id', (data) {});
  }

  /// 消息通知 ////////////////////////////////////////////////////////////////////
  /// 消息通知列表
  Future<OffsetPageData<NotifyMessage>> notifications({
    int startId = 0,
    int? perPage = 20,
    bool cache = true,
  }) async {
    return sendCachedGetRequest(
      '/v1/notifications',
      (resp) {
        var res = <NotifyMessage>[];
        for (var item in resp.data['data']) {
          res.add(NotifyMessage.fromJson(item));
        }

        return OffsetPageData(
          data: res,
          lastId: resp.data['last_id'],
          startId: resp.data['start_id'],
          perPage: resp.data['per_page'],
        );
      },
      queryParameters: {
        'start_id': startId,
        'per_page': perPage,
      },
      forceRefresh: !cache,
    );
  }

  /// 文章 ////////////////////////////////////////////////////////////////////
  /// 文章详情
  Future<Article> article({
    required int id,
    bool cache = true,
  }) async {
    return sendCachedGetRequest(
      '/v1/articles/$id',
      (resp) {
        return Article.fromJson(resp.data['data']);
      },
      forceRefresh: !cache,
    );
  }
}
