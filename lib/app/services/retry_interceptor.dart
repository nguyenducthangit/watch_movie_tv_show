import 'package:dio/dio.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Retry Interceptor with Exponential Backoff
/// Automatically retries failed requests due to network errors
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({this.maxRetries = 3, this.initialDelay = const Duration(seconds: 1)});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Get current retry count
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Check if we should retry
    if (_shouldRetry(err) && retryCount < maxRetries) {
      final nextRetryCount = retryCount + 1;

      // Calculate exponential backoff delay: 1s, 2s, 4s
      final delay = initialDelay * (1 << retryCount);

      logger.w(
        'Retry attempt $nextRetryCount/$maxRetries after ${delay.inSeconds}s for: ${err.requestOptions.uri.path}',
      );

      // Wait before retry
      await Future.delayed(delay);

      // Update retry count
      err.requestOptions.extra['retryCount'] = nextRetryCount;

      try {
        // Retry the request
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        // If retry also fails, continue to next retry or error handler
        return super.onError(e, handler);
      }
    }

    // No more retries or shouldn't retry
    return super.onError(err, handler);
  }

  /// Determine if the error is retryable
  bool _shouldRetry(DioException err) {
    // Retry on connection errors, timeouts, but not on 4xx/5xx HTTP errors
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }
}
