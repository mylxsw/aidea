import 'package:askaide/helper/env.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class HttpClient {
  static final cacheManager = DioCacheManager(
    CacheConfig(
      baseUrl: apiServerURL,
    ),
  );
  static final dio = Dio();

  static init() {
    if (!PlatformTool.isWeb()) {
      dio.interceptors.add(cacheManager.interceptor);
    }

    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: 3,
      logPrint: (message) {
        Logger.instance.w(message);
      },
      retryDelays: const [
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 2), // wait 2 sec before second retry
        Duration(seconds: 3), // wait 3 sec before third retry
      ],
    ));
  }

  static Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(url,
        queryParameters: queryParameters, options: options);
  }

  static Future<Response> getCached(
    String url, {
    String? subKey,
    Duration duration = const Duration(days: 1),
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
    Options? options,
  }) async {
    options ??= Options();
    final resp = await dio.get(
      url,
      queryParameters: queryParameters,
      options: buildCacheOptions(
        duration,
        subKey: subKey,
        options: options.copyWith(sendTimeout: 10000, receiveTimeout: 10000),
        forceRefresh: forceRefresh,
        maxStale: const Duration(days: 30),
      ),
    );

    // print("=======================");
    // print("request: $url");
    // print("response: ${resp.data}");

    return resp;
  }

  static Future<Response> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    final resp = await dio.post(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
      options: options,
    );
    // print("=======================");
    // print("request: $url");
    // print("response: ${resp.data}");

    return resp;
  }

  static Future<Response> postJSON(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    final resp = await dio.post(
      url,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
    // print("=======================");
    // print("request: $url");
    // print("response: ${resp.data}");

    return resp;
  }

  static Future<Response> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    return await dio.put(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
      options: options,
    );
  }

  static Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    return await dio.delete(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
      options: options,
    );
  }
}
