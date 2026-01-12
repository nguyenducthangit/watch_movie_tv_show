import 'package:dio/dio.dart';
import 'package:watch_movie_tv_show/app/config/app_config.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Dio HTTP Client Service
class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => logger.d(obj),
      ),
    );
  }
  static DioClient? _instance;
  late final Dio _dio;

  /// Get singleton instance
  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }
}
