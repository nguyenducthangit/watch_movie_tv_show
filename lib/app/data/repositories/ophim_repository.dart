import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/constants/ophim_api.dart';
import 'package:watch_movie_tv_show/app/data/models/movie_model.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/services/dio_client.dart';
import 'package:watch_movie_tv_show/app/services/translation/translate_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Ophim Repository
/// Handles API calls to Ophim API for movie catalog and details
class OphimRepository {
  OphimRepository({TranslateService? translateService}) {
    _dio = DioClient.instance.dio;
    _translateService = translateService ?? Get.find<TranslateService>();
  }

  late final Dio _dio;
  late final TranslateService _translateService;

  /// Fetch initial movies (5 per country) for fast display
  /// Returns first 5 movies from each country
  Future<List<VideoItem>> fetchInitialMovies() async {
    try {
      final countrySlugs = OphimApi.countrySlugs;
      final hasCountryFilter = countrySlugs.isNotEmpty;

      logger.i('Fetching initial movies (5 per country)...');

      final futures = <Future<List<VideoItem>>>[];

      if (hasCountryFilter) {
        // Fetch first page from each country (usually ~20 movies, we'll take first 5)
        for (final slug in countrySlugs) {
          futures.add(fetchMoviesByCountry(slug, page: 1, limit: 5));
        }
      } else {
        // Fetch first page from default list
        futures.add(
          _fetchMoviePage(1).then((models) async {
            final limitedModels = models.take(5).toList();
            final videoItems = await Future.wait(limitedModels.map((movie) => _movieToVideoItem(movie)));
            return videoItems;
          }),
        );
      }

      final results = await Future.wait(futures);
      final allMovies = results.expand((list) => list).toList();

      // Remove duplicates
      final uniqueMovies = <String, VideoItem>{};
      for (final movie in allMovies) {
        uniqueMovies[movie.id] = movie;
      }
      final uniqueList = uniqueMovies.values.toList();

      logger.i('Fetched ${uniqueList.length} initial movies');
      return uniqueList;
    } catch (e) {
      logger.e('Error fetching initial movies: $e');
      rethrow;
    }
  }

  /// Fetch remaining movies (load more)
  /// Skips first 5 movies from page 1 (already loaded in fetchInitialMovies)
  Future<List<VideoItem>> fetchMoreMovies({
    int quantityPagesFilm = OphimApi.quantityPagesFilm,
  }) async {
    try {
      final countrySlugs = OphimApi.countrySlugs;
      final hasCountryFilter = countrySlugs.isNotEmpty;

      logger.i('Fetching more movies from countries...');

      final futures = <Future<List<VideoItem>>>[];

      if (hasCountryFilter) {
        // Fetch from each country
        for (final slug in countrySlugs) {
          // Page 1: Skip first 5 (already loaded), take the rest
          futures.add(
            fetchMoviesByCountry(slug, page: 1).then((movies) {
              // Skip first 5 movies
              return movies.length > 5 ? movies.sublist(5) : <VideoItem>[];
            }),
          );
          
          // Other pages: load all
          for (var i = 2; i <= quantityPagesFilm; i++) {
            futures.add(fetchMoviesByCountry(slug, page: i));
          }
        }
      } else {
        // Fetch from default list
        // Page 1: Skip first 5
        futures.add(
          _fetchMoviePage(1).then((models) async {
            final limitedModels = models.length > 5 ? models.sublist(5) : <MovieModel>[];
            final videoItems = await Future.wait(limitedModels.map((movie) => _movieToVideoItem(movie)));
            return videoItems;
          }),
        );
        
        // Other pages: load all
        for (var i = 2; i <= quantityPagesFilm; i++) {
          futures.add(
            _fetchMoviePage(i).then((models) async {
              final videoItems = await Future.wait(models.map((movie) => _movieToVideoItem(movie)));
              return videoItems;
            }),
          );
        }
      }

      final results = await Future.wait(futures);
      final allMovies = results.expand((list) => list).toList();

      // Remove duplicates
      final uniqueMovies = <String, VideoItem>{};
      for (final movie in allMovies) {
        uniqueMovies[movie.id] = movie;
      }
      final uniqueList = uniqueMovies.values.toList();

      logger.i('Fetched ${uniqueList.length} more movies');
      return uniqueList;
    } catch (e) {
      logger.e('Error fetching more movies: $e');
      rethrow;
    }
  }

  /// Fetch home movie list with pagination
  /// If countries are defined in OphimApi, fetches from those countries.
  /// Otherwise fetches from the default latest list.
  Future<List<VideoItem>> fetchHomeMovies({
    int quantityPagesFilm = OphimApi.quantityPagesFilm,
  }) async {
    try {
      final countrySlugs = OphimApi.countrySlugs;
      final hasCountryFilter = countrySlugs.isNotEmpty;

      logger.i(
        hasCountryFilter
            ? 'Fetching movies from countries: $countrySlugs ($quantityPagesFilm pages each)...'
            : 'Fetching $quantityPagesFilm pages of latest movies...',
      );

      final futures = <Future<List<VideoItem>>>[];

      if (hasCountryFilter) {
        // Fetch from specified countries
        for (final slug in countrySlugs) {
          for (var i = 1; i <= quantityPagesFilm; i++) {
            futures.add(fetchMoviesByCountry(slug, page: i));
          }
        }
      } else {
        // Fetch from default list
        for (var i = 1; i <= quantityPagesFilm; i++) {
          futures.add(
            _fetchMoviePage(i).then((models) async {
              final videoItems = await Future.wait(models.map((movie) => _movieToVideoItem(movie)));
              return videoItems;
            }),
          );
        }
      }

      final results = await Future.wait(futures);
      final allMovies = results.expand((list) => list).toList();

      // Remove duplicates (possible overlap if multiple countries or pagination issues)
      final uniqueMovies = <String, VideoItem>{};
      for (final movie in allMovies) {
        uniqueMovies[movie.id] = movie;
      }
      final uniqueList = uniqueMovies.values.toList();

      logger.i('Fetched ${uniqueList.length} unique movies from Ophim API');

      return uniqueList;
    } catch (e) {
      logger.e('Error fetching home movies: $e');
      rethrow;
    }
  }

  /// Fetch movies by country
  Future<List<VideoItem>> fetchMoviesByCountry(String countrySlug, {int page = 1, int? limit}) async {
    try {
      final response = await _dio.get(
        '${OphimApi.baseUrl}${OphimApi.countryEndpoint(countrySlug)}',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>?;

        if (data == null) {
          logger.e('No data field in response for country $countrySlug page $page');
          return [];
        }

        // Parse items from response
        final items =
            (data['items'] as List<dynamic>?)
                ?.map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [];

        logger.i('Fetched ${items.length} movies for country $countrySlug page $page');

        // Apply limit if specified
        final limitedItems = limit != null && limit > 0 
            ? items.take(limit).toList() 
            : items;

        // Convert movies to video items with translation
        final videoItems = await Future.wait(limitedItems.map((movie) => _movieToVideoItem(movie)));

        return videoItems;
      } else {
        logger.e('Failed to load country $countrySlug page $page: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.e('Error fetching movies for country $countrySlug: $e');
      return [];
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

        final movie = MovieModel.fromJson(item);

        // Translate logic if enabled
        if (_translateService.isTranslationEnabled) {
          try {
            final tags = movie.categories ?? <String>[];
            final textsToTranslate = <String>[
              movie.name,
              if (movie.content != null && movie.content!.isNotEmpty) movie.content!,
              ...tags,
            ];

            final translations = await _translateService.translateBatch(textsToTranslate);

            return movie.copyWith(
              name: translations[movie.name] ?? movie.name,
              content: movie.content != null ? translations[movie.content!] : null,
              translatedCategories: tags.isNotEmpty
                  ? tags.map((t) => translations[t] ?? t).toList()
                  : null,
            );
          } catch (e) {
            logger.e('Error translating detail for ${movie.name}: $e');
            return movie;
          }
        }

        return movie;
      } else {
        throw Exception('Failed to load movie detail: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching movie detail for slug $slug: $e');

      // Provide user-friendly error messages
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          logger.e('Network error fetching $slug: Connection failed after retries');
          throw Exception('Unable to connect. Please check your internet connection.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Server took too long to respond. Please try again.');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Movie not found');
        } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }
      }

      // Generic error message
      throw Exception('Failed to load movie details. Please try again.');
    }
  }

  /// Convert MovieModel to VideoItem for UI compatibility
  /// Returns VideoItem with original Vietnamese text (no translation here)
  /// Translation will be handled in Splash or Home Controller
  Future<VideoItem> _movieToVideoItem(MovieModel movie) async {
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

      episodeCurrent: movie.episodeCurrent,
      episodeTotal: movie.episodeTotal,
      time: movie.time,
      type: movie.type,
      actor: movie.actor,
      director: movie.director,
      country: movie.country,
      trailerUrl: movie.trailerUrl,
      // Translation fields will be set by Splash or Home Controller
      translatedTitle: null,
      translatedDescription: null,
      translatedTags: null,
    );
  }

  /// Convert MovieModel with episode to VideoItem with stream URL
  Future<VideoItem> movieWithEpisodeToVideoItem(
    MovieModel movie, {
    int episodeIndex = 0,
    EpisodeItem? episodeToPlay,
  }) async {
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

    // Translate title and description if translation is enabled
    String? translatedTitle;
    String? translatedDescription;
    List<String>? translatedTags;

    if (_translateService.isTranslationEnabled) {
      try {
        final tags = movie.categories ?? <String>[];
        final textsToTranslate = <String>[
          movie.name,
          if (movie.content != null && movie.content!.isNotEmpty) movie.content!,
          ...tags,
        ];

        final translations = await _translateService.translateBatch(textsToTranslate);
        translatedTitle = translations[movie.name];
        translatedDescription = movie.content != null ? translations[movie.content!] : null;
        translatedTags = tags.isNotEmpty ? tags.map((t) => translations[t] ?? t).toList() : null;
      } catch (e) {
        logger.e('Error translating movie ${movie.name}: $e');
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

      episodeCurrent: movie.episodeCurrent,
      episodeTotal: movie.episodeTotal,
      time: movie.time,
      type: movie.type,
      actor: movie.actor,
      director: movie.director,
      country: movie.country,
      trailerUrl: movie.trailerUrl,
      translatedTitle: translatedTitle,
      translatedDescription: translatedDescription,
      translatedTags: translatedTags,
    );
  }
}
