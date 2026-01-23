/// Ophim API Constants
class OphimApi {
  OphimApi._();

  /// Base API URL
  static const String baseUrl = 'https://ophim1.com/v1/api';

  /// CDN Base URL for images
  static const String cdnBase = 'https://img.ophim.live/uploads/movies/';

  /// API Endpoints
  static const String homeEndpoint = '/home';
  static const String listEndpoint = '/danh-sach'; // Supports pagination
  static String movieDetailEndpoint(String slug) => '/phim/$slug';
  static String countryEndpoint(String slug) => '/quoc-gia/$slug';
  static List<String> countrySlugs = [
    'duc',
    'phap',
    'tay-ban-nha',
    'an-do',
    'bo-dao-nha',
    'indonesia',
    'anh',
  ];
  static const int quantityPagesFilm = 1;
}
