/// Ophim API Constants
class OphimApi {
  OphimApi._();

  /// Base API URL
  static const String baseUrl = 'https://ophim1.com/v1/api';

  /// CDN Base URL for images
  static const String cdnBase = 'https://img.ophim.live/uploads/movies/';

  /// API Endpoints
  static const String homeEndpoint = '/home';
  static String movieDetailEndpoint(String slug) => '/phim/$slug';
}
