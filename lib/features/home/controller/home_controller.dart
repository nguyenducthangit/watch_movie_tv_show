import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watch_movie_tv_show/app/config/app_config.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/repositories/ophim_repository.dart';
import 'package:watch_movie_tv_show/app/popups/data_source_policy_.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/preload_service.dart';
import 'package:watch_movie_tv_show/app/services/shared_pref_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';
import 'package:watch_movie_tv_show/features/language/domain/repositories/language_repository.dart';
import 'package:watch_movie_tv_show/features/language/presentation/enums/language_enums.dart';
import 'package:watch_movie_tv_show/features/translation/controller/translation_controller.dart';

/// Home Controller
/// Manages video catalog display, search, and premium browse experience
class HomeController extends GetxController {
  final OphimRepository _repo = OphimRepository();

  // Services
  WatchProgressService get _progressService => Get.find<WatchProgressService>();
  TranslationController? get _translationController {
    try {
      return Get.find<TranslationController>();
    } catch (e) {
      return null; // Translation controller not initialized
    }
  }

  ILanguageRepository? get _languageRepository {
    try {
      return Get.find<ILanguageRepository>();
    } catch (e) {
      return null;
    }
  }

  // State
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSharing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreMovies = true.obs;

  // Data
  final RxList<VideoItem> videos = <VideoItem>[].obs;
  final RxList<VideoItem> filteredVideos = <VideoItem>[].obs;
  final RxList<String> tags = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTag = ''.obs;
  final RxBool isSearchExpanded = false.obs;

  // Premium Features
  final RxList<VideoItem> featuredVideos = <VideoItem>[].obs;
  final RxList<VideoItem> continueWatching = <VideoItem>[].obs;
  final RxList<VideoItem> trendingVideos = <VideoItem>[].obs;
  final RxList<VideoItem> newReleases = <VideoItem>[].obs;
  final RxMap<String, List<VideoItem>> videosByGenre = <String, List<VideoItem>>{}.obs;

  Future<void> handleShare() async {
    if (isSharing.value) return;
    isSharing.value = true;
    SharePlus.instance.share(
      ShareParams(
        text: 'https://play.google.com/store/apps/details?id=${AppConfig.packageInfo.packageName}',
        subject: L.appName.tr,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    isSharing.value = false;
  }

  /// Toggle search expansion
  void toggleSearch() => isSearchExpanded.toggle();

  @override
  void onInit() {
    super.onInit();
    loadVideos();

    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 300));
  }

  @override
  void onReady() {
    logger.i('🔥🔥🔥 HomeController.onReady() called - videos: ${videos.length}');
    super.onReady();
    // Refresh continue watching when returning to home
    ever(_progressService.progressMap, (_) => _updateContinueWatching());

    // Check for language changes when page becomes active (returning from language settings)
    _checkAndRefreshTranslations();
  }

  /// Check if language has changed and refresh translations if needed
  Future<void> _checkAndRefreshTranslations() async {
    logger.i('🔍 _checkAndRefreshTranslations called, videos: ${videos.length}');
    if (videos.isNotEmpty) {
      await _translateMoviesIfNeeded();
    }
  }

  /// Load videos from repository or use preloaded data
  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Check for preloaded data first
      PreloadService? preloadService;
      try {
        preloadService = Get.find<PreloadService>();
      } catch (e) {
        logger.w('PreloadService not available: $e');
      }

      List<VideoItem> movieList;

      if (preloadService != null && preloadService.hasPreloadedData()) {
        final preloaded = preloadService.getPreloadedMovies();
        if (preloaded != null) {
          logger.i('Using preloaded data: ${preloaded.length} movies');
          movieList = preloaded;

          // Extract unique tags from all videos
          final allTags = <String>{};
          for (final video in movieList) {
            if (video.tags != null) {
              allTags.addAll(video.tags!);
            }
          }
          tags.value = allTags.toList();

          if (preloadService.isPreloadComplete) {
            logger.i('Preload complete with translation, showing videos');
            // Preload complete means translation is already done
            // Just verify translations exist, if not translate now
            final hasTranslations = movieList.isNotEmpty && 
                movieList.first.translatedTitle != null && 
                movieList.first.translatedTitle!.isNotEmpty;
            
            if (!hasTranslations) {
              logger.w('Preload complete but no translations found, translating now...');
              // Translate before showing
              movieList = await _translateMoviesList(movieList);
            }
          } else {
            logger.i('Preload in progress, waiting for translation to complete...');
            // Preload not complete - wait for translation to finish
            // Don't show UI until translation is done
            movieList = await _translateMoviesList(movieList);
            logger.i('Translation completed, showing videos');
          }

          // Now show the translated movies
          videos.value = movieList;
          _setupPremiumSections();
          _applyFilters();
          isLoading.value = false;

          // Load more movies in background (since preload only loaded initial 5 per country)
          _loadMoreMoviesInBackground();

          // Show copyright notice popup on first launch after movies load
          _showCopyrightNoticeIfNeeded();
          return;
        }
      }

      // Progressive loading: Load initial 5 movies per country, translate and show immediately
      logger.i('Loading initial movies (5 per country) and translating...');
      
      // Load initial movies (5 per country) - fast
      movieList = await _repo.fetchInitialMovies();
      
      // Extract unique tags from initial videos
      final allTags = <String>{};
      for (final video in movieList) {
        if (video.tags != null) {
          allTags.addAll(video.tags!);
        }
      }
      tags.value = allTags.toList();

      // Translate initial movies immediately
      final translationCtrl = _translationController;
      final langRepo = _languageRepository;
      
      if (translationCtrl != null && langRepo != null && movieList.isNotEmpty) {
        try {
          final currentLang = langRepo.getCurLangCode();
          logger.i('Translating ${movieList.length} initial movies to ${currentLang.name}...');
          
          // Translate using smart batch (faster)
          final translatedList = await translationCtrl.translateMoviesSmartBatch(
            movies: movieList,
            targetLang: currentLang,
          );
          
          movieList = translatedList;
          _lastTranslatedLang = currentLang;
          logger.i('Translation completed for ${movieList.length} initial movies');
        } catch (e) {
          logger.e('Failed to translate initial movies: $e');
        }
      }

      // Show initial movies immediately
      videos.value = movieList;
      _setupPremiumSections();
      _applyFilters();
      isLoading.value = false;
      logger.i('Loaded ${videos.length} initial videos, continuing to load more in background...');

      // Load remaining movies in background
      _loadMoreMoviesInBackground();

      // Show copyright notice popup on first launch after movies load
      _showCopyrightNoticeIfNeeded();
    } catch (e) {
      logger.e('Failed to load videos: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  /// Show copyright notice popup if not shown before
  void _showCopyrightNoticeIfNeeded() {
    if (!SharedPrefService.hasCopyrightNoticeBeenShown()) {
      // Show popup after a short delay to let UI settle
      Future.delayed(const Duration(milliseconds: 500), () {
        DataSourcePolicyPopup.show();
        SharedPrefService.markCopyrightNoticeAsShown();
      });
    }
  }

  /// Refresh videos
  Future<void> refreshVideos() async {
    try {
      isRefreshing.value = true;
      hasError.value = false;

      final movieList = await _repo.fetchHomeMovies();
      videos.value = movieList;

      // Extract unique tags
      final allTags = <String>{};
      for (final video in movieList) {
        if (video.tags != null) {
          allTags.addAll(video.tags!);
        }
      }
      tags.value = allTags.toList();

      // Re-setup premium sections
      _setupPremiumSections();
      _applyFilters();

      logger.i('Refreshed ${videos.length} videos');
    } catch (e) {
      logger.e('Failed to refresh videos: $e');
      Get.snackbar('Error', 'Failed to refresh content');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Fetch videos by countries
  Future<void> fetchMoviesByCountries(List<String> countrySlugs) async {
    if (countrySlugs.isEmpty) {
      loadVideos();
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      videos.clear();

      // Fetch from all countries concurrently (2 pages each for variety)
      final futures = <Future<List<VideoItem>>>[];
      for (final slug in countrySlugs) {
        futures.add(_repo.fetchMoviesByCountry(slug, page: 1));
        futures.add(_repo.fetchMoviesByCountry(slug, page: 2));
      }

      final results = await Future.wait(futures);
      final allMovies = results.expand((list) => list).toList();

      // Updates videos list
      // Remove duplicates based on ID if any
      final uniqueMovies = <String, VideoItem>{};
      for (final movie in allMovies) {
        uniqueMovies[movie.id] = movie;
      }
      videos.value = uniqueMovies.values.toList();

      // Extract unique tags from all videos
      final allTags = <String>{};
      for (final video in videos) {
        if (video.tags != null) {
          allTags.addAll(video.tags!);
        }
      }
      tags.value = allTags.toList();

      // Setup premium sections
      _setupPremiumSections();
      _applyFilters();

      logger.i('Loaded ${videos.length} videos from countries: $countrySlugs');
    } catch (e) {
      logger.e('Failed to load videos from countries: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Setup premium sections (featured, trending, by genre)
  void _setupPremiumSections() {
    final allVideos = videos.toList();

    // Featured: Random 7 videos (different each time for variety!)
    final shuffledForFeatured = List<VideoItem>.from(allVideos)..shuffle();
    featuredVideos.value = shuffledForFeatured.take(7).toList();

    // Trending: Random shuffle of some videos
    final shuffled = List<VideoItem>.from(allVideos)..shuffle();
    trendingVideos.value = shuffled.take(10).toList();

    // New Releases: Could be sorted by date, for now use last items
    newReleases.value = allVideos.reversed.take(10).toList();

    // Videos by genre - shuffle and avoid duplicates between genres
    final genreMap = <String, List<VideoItem>>{};
    final usedVideoIds = <String>{};
    
    // First pass: collect all genres
    for (final video in allVideos) {
      if (video.tags != null) {
        for (final tag in video.tags!) {
          genreMap.putIfAbsent(tag, () => []);
        }
      }
    }
    
    // Shuffle genre keys for random order
    final genreKeys = genreMap.keys.toList()..shuffle();
    
    // Second pass: assign videos to genres, avoiding duplicates
    // Each video appears in maximum 1 genre to avoid repetition
    for (final genre in genreKeys) {
      final genreVideos = <VideoItem>[];
      for (final video in allVideos) {
        if (video.tags != null && 
            video.tags!.contains(genre) && 
            !usedVideoIds.contains(video.id)) {
          genreVideos.add(video);
          usedVideoIds.add(video.id);
        }
      }
      // Shuffle videos within each genre for variety
      genreVideos.shuffle();
      genreMap[genre] = genreVideos;
    }
    
    videosByGenre.value = genreMap;

    // Continue watching
    _updateContinueWatching();
  }

  /// Update continue watching list
  void _updateContinueWatching() {
    final continueIds = _progressService.getContinueWatchingIds();
    final videoMap = {for (final v in videos) v.id: v};

    continueWatching.value = continueIds
        .where((id) => videoMap.containsKey(id))
        .map((id) => videoMap[id]!)
        .toList();
  }

  /// Get watch progress for a video
  double getWatchProgress(String videoId) {
    return _progressService.getProgress(videoId);
  }

  /// Get progress map for continue watching UI
  Map<String, double> get progressMap => _progressService.progressMap;

  /// Apply search and tag filters
  void _applyFilters() {
    List<VideoItem> result = videos.toList();

    // Apply tag filter
    if (selectedTag.value.isNotEmpty) {
      result = result.where((v) => v.tags?.contains(selectedTag.value) ?? false).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((v) => v.title.toLowerCase().contains(query)).toList();
    }

    filteredVideos.value = result;
  }

  /// Set search query

  /// Set search query
  void setSearch(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Set selected tag
  void setTag(String tag) {
    if (selectedTag.value == tag) {
      selectedTag.value = '';
    } else {
      selectedTag.value = tag;
    }
    _applyFilters();
  }

  /// Reset to home initial state
  void resetToHome() {
    selectedTag.value = '';
    searchQuery.value = '';
    _applyFilters();
  }

  /// Clear tag filter
  void clearTagFilter() {
    selectedTag.value = '';
    _applyFilters();
  }

  /// Check if video is downloaded
  bool isVideoDownloaded(String videoId) {
    return DownloadService.to.isDownloaded(videoId);
  }

  /// Navigate to video detail
  /// Prioritize loading movie detail before navigation
  void openVideoDetail(VideoItem video) {
    // Pre-load movie detail in background for faster navigation (fire and forget)
    if (video.slug != null && video.slug!.isNotEmpty) {
      // Start loading detail in background (non-blocking)
      // This will help DetailController load faster
      _preloadMovieDetail(video.slug!);
    }
    
    // Navigate immediately (detail will load again in DetailController)
    Get.toNamed(MRoutes.detail, arguments: video);
  }

  /// Preload movie detail in background
  void _preloadMovieDetail(String slug) {
    _repo.fetchMovieDetail(slug).then((_) {
      logger.i('Preloaded detail for $slug');
    }).catchError((e) {
      logger.e('Failed to preload detail for $slug: $e');
    });
  }

  /// Play video directly - fetch detail to get stream URL
  Future<void> playVideo(VideoItem video) async {
    try {
      // Show loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // Fetch movie detail to get episodes and stream URL
      if (video.slug == null || video.slug!.isEmpty) {
        Get.back(); // Close loading
        Get.snackbar('Error', 'Invalid movie slug');
        return;
      }

      logger.i('Fetching detail for slug: ${video.slug}');
      final detail = await _repo.fetchMovieDetail(video.slug!);

      logger.i('Movie detail fetched: ${detail.name}');
      logger.i('Has episodes: ${detail.hasEpisodes}');

      // Get first episode for series or use movie directly
      VideoItem videoWithStream;
      if (detail.hasEpisodes && detail.episodes!.isNotEmpty) {
        final firstServer = detail.episodes!.first;
        if (firstServer.episodes.isNotEmpty) {
          final firstEpisode = firstServer.episodes.first;
          logger.i('Playing episode: ${firstEpisode.name} from server: ${firstServer.serverName}');

          // Convert to VideoItem with stream URL from first episode
          videoWithStream = await _repo.movieWithEpisodeToVideoItem(
            detail,
            episodeToPlay: firstEpisode,
          );
        } else {
          Get.back(); // Close loading
          Get.snackbar('Error', 'No episodes available');
          return;
        }
      } else {
        // For movies (single file), convert to VideoItem
        videoWithStream = await _repo.movieWithEpisodeToVideoItem(detail);
      }

      logger.i('VideoItem created with streamUrl: ${videoWithStream.streamUrl}');

      if (videoWithStream.streamUrl == null || videoWithStream.streamUrl!.isEmpty) {
        Get.back(); // Close loading
        Get.snackbar('Error', 'No stream available for this video');
        logger.e('Stream URL is null or empty!');
        return;
      }

      // Check if we have a local file
      final localPath = await DownloadService.to.getLocalPath(video.id);

      Get.back(); // Close loading
      logger.i('Navigating to player with stream URL: ${videoWithStream.streamUrl}');
      Get.toNamed(MRoutes.player, arguments: {'video': videoWithStream, 'localPath': localPath});
    } catch (e, stack) {
      Get.back(); // Close loading if still showing
      logger.e('Failed to play video: $e');
      logger.e('Stack trace: $stack');
      Get.snackbar('Error', 'Failed to load video stream: $e');
    }
  }

  /// Load more movies in background (after initial load)
  Future<void> _loadMoreMoviesInBackground() async {
    try {
      logger.i('Loading more movies in background...');
      
      // Load remaining movies
      final moreMovies = await _repo.fetchMoreMovies();
      
      if (moreMovies.isEmpty) {
        hasMoreMovies.value = false;
        logger.i('No more movies to load');
        return;
      }

      // Remove duplicates with existing videos
      final existingIds = videos.map((v) => v.id).toSet();
      final newMovies = moreMovies.where((m) => !existingIds.contains(m.id)).toList();

      if (newMovies.isEmpty) {
        hasMoreMovies.value = false;
        logger.i('No new movies to add');
        return;
      }

      // Translate new movies
      final translatedNewMovies = await _translateMoviesList(newMovies);

      // Add to existing videos
      videos.addAll(translatedNewMovies);

      // Update tags
      final allTags = <String>{};
      for (final video in videos) {
        if (video.tags != null) {
          allTags.addAll(video.tags!);
        }
      }
      tags.value = allTags.toList();

      // Re-setup premium sections
      _setupPremiumSections();
      _applyFilters();

      logger.i('Added ${translatedNewMovies.length} more movies, total: ${videos.length}');
    } catch (e) {
      logger.e('Failed to load more movies: $e');
      hasMoreMovies.value = false;
    }
  }

  /// Load more movies (lazy loading when user scrolls)
  Future<void> loadMoreMovies() async {
    if (isLoadingMore.value || !hasMoreMovies.value) return;

    try {
      isLoadingMore.value = true;
      logger.i('Loading more movies (lazy load)...');

      // Load remaining movies
      final moreMovies = await _repo.fetchMoreMovies();

      if (moreMovies.isEmpty) {
        hasMoreMovies.value = false;
        isLoadingMore.value = false;
        return;
      }

      // Remove duplicates
      final existingIds = videos.map((v) => v.id).toSet();
      final newMovies = moreMovies.where((m) => !existingIds.contains(m.id)).toList();

      if (newMovies.isEmpty) {
        hasMoreMovies.value = false;
        isLoadingMore.value = false;
        return;
      }

      // Translate new movies
      final translatedNewMovies = await _translateMoviesList(newMovies);

      // Add to existing videos
      videos.addAll(translatedNewMovies);

      // Update tags
      final allTags = <String>{};
      for (final video in videos) {
        if (video.tags != null) {
          allTags.addAll(video.tags!);
        }
      }
      tags.value = allTags.toList();

      // Re-setup premium sections
      _setupPremiumSections();
      _applyFilters();

      logger.i('Lazy loaded ${translatedNewMovies.length} more movies, total: ${videos.length}');
    } catch (e) {
      logger.e('Failed to load more movies: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Retry loading
  void retry() {
    loadVideos();
  }

  /// Check if in browse/search mode (no filters active)
  bool get isBrowseMode => searchQuery.value.isEmpty && selectedTag.value.isEmpty;

  /// Check if has any continue watching
  bool get hasContinueWatching => continueWatching.isNotEmpty;

  // Track last translated language to avoid redundant translations
  LanguageCode? _lastTranslatedLang;

  /// Translate a list of movies and return translated list
  Future<List<VideoItem>> _translateMoviesList(List<VideoItem> movies) async {
    final translationCtrl = _translationController;
    final langRepo = _languageRepository;

    if (translationCtrl == null || langRepo == null || movies.isEmpty) {
      logger.w('Translation not available, returning original movies');
      return movies;
    }

    try {
      final currentLang = langRepo.getCurLangCode();
      logger.i('Translating ${movies.length} movies to ${currentLang.name}...');
      
      // Translate using smart batch (faster)
      final translatedList = await translationCtrl.translateMoviesSmartBatch(
        movies: movies,
        targetLang: currentLang,
      );
      
      _lastTranslatedLang = currentLang;
      logger.i('Translation completed for ${translatedList.length} movies');
      return translatedList;
    } catch (e) {
      logger.e('Failed to translate movies: $e');
      return movies; // Return original on error
    }
  }

  /// Translate movies based on current language
  Future<void> _translateMoviesIfNeeded() async {
    final translationCtrl = _translationController;
    final langRepo = _languageRepository;

    if (translationCtrl == null || langRepo == null || videos.isEmpty) {
      logger.w('Translation not available: ctrl=${translationCtrl != null}, repo=${langRepo != null}, videos=${videos.length}');
      return;
    }

    try {
      // Get current language
      final currentLang = langRepo.getCurLangCode();

      // Check if movies already have translations
      final hasTranslations = videos.isNotEmpty && 
          videos.first.translatedTitle != null && 
          videos.first.translatedTitle!.isNotEmpty;

      // Skip if already translated to this language AND has translations
      if (_lastTranslatedLang == currentLang && hasTranslations) {
        logger.i('Movies already translated to ${currentLang.name}, skipping');
        return;
      }

      // If no translations exist, force translation even if language matches
      if (!hasTranslations) {
        logger.i('Movies have no translations, translating to ${currentLang.name}...');
      }

      logger.i('Translating ${videos.length} movies to ${currentLang.name}...');

      // Translate all videos (cache will prevent redundant API calls)
      final translatedList = await translationCtrl.translateMovieList(
        movies: videos.toList(),
        targetLang: currentLang,
        batchSize: 15,
      );

      // Update videos with translations
      videos.value = translatedList;

      // Re-apply filters to update filtered list
      _applyFilters();

      // Re-setup premium sections with translated movies
      _setupPremiumSections();

      // Remember this language to avoid re-translation
      _lastTranslatedLang = currentLang;

      logger.i('Translation completed for ${videos.length} movies');
    } catch (e) {
      logger.e('Failed to translate movies: $e');
      // Don't show error to user, just continue with original text
    }
  }

  /// Refresh translations when language changes (called from LanguageController)
  Future<void> refreshTranslations(LanguageCode targetLang) async {
    final translationCtrl = _translationController;
    if (translationCtrl == null) return;

    try {
      logger.i('Refreshing translations to ${targetLang.name}...');

      // Translate all videos
      final translatedList = await translationCtrl.translateMovieList(
        movies: videos.toList(),
        targetLang: targetLang,
        batchSize: 15,
      );

      // Update videos with new translations
      videos.value = translatedList;

      // Re-apply filters
      _applyFilters();

      // Re-setup premium sections
      _setupPremiumSections();

      // Update tracking
      _lastTranslatedLang = targetLang;

      logger.i('Translations refreshed');
    } catch (e) {
      logger.e('Failed to refresh translations: $e');
    }
  }
}
