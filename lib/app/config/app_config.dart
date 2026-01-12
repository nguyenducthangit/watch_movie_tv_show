/// App Configuration
/// Contains all app-level configurations like URLs, timeouts, etc.
class AppConfig {
  AppConfig._();

  // API Configuration
  static const String manifestUrl =
      'https://raw.githubusercontent.com/your-org/video-catalog/main/manifest.json';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Download settings
  static const int maxConcurrentDownloads = 2;
  static const int downloadRetryCount = 3;

  // Cache settings
  static const Duration manifestCacheExpiry = Duration(hours: 1);
  static const int maxCachedImages = 100;

  // Video settings
  static const int videoBufferMs = 5000;
  static const int prefetchThumbnailCount = 20;

  // App info
  static const String appName = 'Video App';
  static const String appVersion = '1.0.0';
}
