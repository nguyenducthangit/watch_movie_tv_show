import 'package:dio/dio.dart';
import 'package:watch_movie_tv_show/app/constants/ophim_api.dart';
import 'package:watch_movie_tv_show/app/data/models/movie_model.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/services/dio_client.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Ophim Repository
/// Handles API calls to Ophim API for movie catalog and details
class OphimRepository {
  OphimRepository() {
    _dio = DioClient.instance.dio;
  }

  late final Dio _dio;

  /// Fetch home movie list with pagination
  /// Fetches multiple pages concurrently for better variety
  Future<List<VideoItem>> fetchHomeMovies({
    int quantityPagesFilm = OphimApi.quantityPagesFilm,
  }) async {
    try {
      logger.i('Fetching $quantityPagesFilm pages of movies...');

      // Fetch multiple pages concurrently
      final futures = List.generate(quantityPagesFilm, (i) => _fetchMoviePage(i + 1));

      final results = await Future.wait(futures);
      final allMovies = results.expand((list) => list).toList();

      logger.i('Fetched ${allMovies.length} movies from Ophim API $quantityPagesFilm pages');

      // Convert MovieModel to VideoItem
      return allMovies.map(_movieToVideoItem).toList();
    } catch (e) {
      logger.e('Error fetching home movies: $e');
      rethrow;
    }
  }

  /// Fetch a single page of movies
  Future<List<MovieModel>> _fetchMoviePage(int page) async {
    try {
      final response = await _dio.get(
        '${OphimApi.baseUrl}${OphimApi.listEndpoint}',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>?;

        if (data == null) {
          logger.e('No data field in response for page $page');
          return [];
        }

        // Parse items from response
        final items =
            (data['items'] as List<dynamic>?)
                ?.map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [];

        logger.i('Fetched ${items.length} movies from page $page');
        return items;
      } else {
        logger.e('Failed to load page $page: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.e('Error fetching page $page: $e');
      return []; // Return empty list instead of throwing to not break other pages
    }
  }

  /// Fetch movie detail with episodes
  Future<MovieModel> fetchMovieDetail(String slug) async {
    try {
      final response = await _dio.get('${OphimApi.baseUrl}${OphimApi.movieDetailEndpoint(slug)}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // API structure: {status: "success", data: {item: {...}}}
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data == null) {
          logger.e('No data field in detail response');
          throw Exception('Invalid API response structure');
        }

        final item = data['item'] as Map<String, dynamic>?;
        if (item == null) {
          logger.e('No item field in data');
          throw Exception('Movie not found');
        }

        logger.i('Fetched movie detail for: ${item['name']}');
        return MovieModel.fromJson(item);
      } else {
        throw Exception('Failed to load movie detail: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching movie detail for slug $slug: $e');
      rethrow;
    }
  }

  /// Convert MovieModel to VideoItem for UI compatibility
  VideoItem _movieToVideoItem(MovieModel movie) {
    return VideoItem(
      id: movie.slug,
      title: movie.name,
      description: movie.content,
      thumbnailUrl: movie.getFullThumbnailUrl(),
      slug: movie.slug,
      streamUrl: null, // Will be set when fetching detail
      tags: movie.categories,
      durationSec: null, // Not available from list API
      year: movie.year,
      quality: movie.quality,
      lang: movie.lang,
      episodeCurrent: movie.episodeCurrent,
      episodeTotal: movie.episodeTotal,
      time: movie.time,
      type: movie.type,
      actor: movie.actor,
      director: movie.director,
      country: movie.country,
      trailerUrl: movie.trailerUrl,
    );
  }

  /// Convert MovieModel with episode to VideoItem with stream URL
  VideoItem movieWithEpisodeToVideoItem(
    MovieModel movie, {
    int episodeIndex = 0,
    EpisodeItem? episodeToPlay,
  }) {
    String? streamUrl;

    // Get stream URL from specific episode or by index
    if (movie.hasEpisodes && movie.episodes!.isNotEmpty) {
      if (episodeToPlay != null) {
        // Use provided episode directly
        streamUrl = episodeToPlay.linkM3u8;
      } else {
        // Use episode by index (fallback)
        final firstServer = movie.episodes!.first;
        if (firstServer.episodes.isNotEmpty) {
          final episode = episodeIndex < firstServer.episodes.length
              ? firstServer.episodes[episodeIndex]
              : firstServer.episodes.first;
          streamUrl = episode.linkM3u8;
        }
      }
    }

    return VideoItem(
      id: movie.slug,
      title: movie.name,
      description: movie.content,
      thumbnailUrl: movie.getFullThumbnailUrl(),
      slug: movie.slug,
      streamUrl: streamUrl,
      tags: movie.categories,
      durationSec: null,
      year: movie.year,
      quality: movie.quality,
      lang: movie.lang,
      episodeCurrent: movie.episodeCurrent,
      episodeTotal: movie.episodeTotal,
      time: movie.time,
      type: movie.type,
      actor: movie.actor,
      director: movie.director,
      country: movie.country,
      trailerUrl: movie.trailerUrl,
    );
  }
}
