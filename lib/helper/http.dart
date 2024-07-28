import 'package:askaide/helper/logger.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class HttpClient {
  static final dio = Dio();

  static final cacheStore = MemCacheStore();

  static final cacheOptions = CacheOptions(
    store: cacheStore,
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
    allowPostMethod: false,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );

  static init() {
    dio.interceptors.add(DioCacheInterceptor(
      options: cacheOptions,
    ));
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
      options: options.copyWith(
          extra: cacheOptions
              .copyWith(
                maxStale: Nullable<Duration>(duration),
                policy: forceRefresh
                    ? CachePolicy.refreshForceCache
                    : CachePolicy.forceCache,
              )
              .toExtra()),
    );
    // print("=======================");
    print("request: $url [${resp.statusCode}]");
    // print("response: ${resp.data}");

    return resp;
  }

  // 清空缓存
  static Future<void> cleanCache() async {
    return await cacheStore.clean();
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

  static Future<Response> putJSON(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    return await dio.put(
      url,
      queryParameters: queryParameters,
      data: data,
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
