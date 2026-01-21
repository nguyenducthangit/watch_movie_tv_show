import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/repositories/ophim_repository.dart';
import 'package:watch_movie_tv_show/app/popups/copyright_notice_popup.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/shared_pref_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
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

  // Data
  final RxList<VideoItem> videos = <VideoItem>[].obs;
  final RxList<VideoItem> filteredVideos = <VideoItem>[].obs;
  final RxList<String> tags = <String>[].obs;

  // Premium Features
  final RxList<VideoItem> featuredVideos = <VideoItem>[].obs;
  final RxList<VideoItem> continueWatching = <VideoItem>[].obs;
  final RxList<VideoItem> trendingVideos = <VideoItem>[].obs;
  final RxList<VideoItem> newReleases = <VideoItem>[].obs;
  final RxMap<String, List<VideoItem>> videosByGenre = <String, List<VideoItem>>{}.obs;

  // Search & Filter
  final RxString searchQuery = ''.obs;
  final RxString selectedTag = ''.obs;
  final RxBool isSearchExpanded = false.obs;

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

  /// Load videos from repository
  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final movieList = await _repo.fetchHomeMovies();
      videos.value = movieList;

      // Extract unique tags from all videos
      final allTags = <String>{};
      for (final video in movieList) {
        if (video.tags != null) {
          allTags.addAll(video.tags!);
        }
      }
      tags.value = allTags.toList();

      _setupPremiumSections();
      _applyFilters();

      // Translate movies if translation is available
      await _translateMoviesIfNeeded();

      logger.i('Loaded ${videos.length} videos');

      // Show copyright notice popup on first launch after movies load
      _showCopyrightNoticeIfNeeded();
    } catch (e) {
      logger.e('Failed to load videos: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Show copyright notice popup if not shown before
  void _showCopyrightNoticeIfNeeded() {
    if (!SharedPrefService.hasCopyrightNoticeBeenShown()) {
      // Show popup after a short delay to let UI settle
      Future.delayed(const Duration(milliseconds: 500), () {
        CopyrightNoticePopup.show();
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

    // Videos by genre
    final genreMap = <String, List<VideoItem>>{};
    for (final video in allVideos) {
      if (video.tags != null) {
        for (final tag in video.tags!) {
          genreMap.putIfAbsent(tag, () => []).add(video);
        }
      }
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
  void openVideoDetail(VideoItem video) {
    Get.toNamed(MRoutes.detail, arguments: video);
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

  /// Translate movies based on current language
  Future<void> _translateMoviesIfNeeded() async {
    final translationCtrl = _translationController;
    final langRepo = _languageRepository;

    if (translationCtrl == null || langRepo == null || videos.isEmpty) return;

    try {
      // Get current language
      final currentLang = langRepo.getCurLangCode();

      // Skip if already translated to this language
      if (_lastTranslatedLang == currentLang) {
        logger.i('Movies already translated to ${currentLang.name}, skipping');
        return;
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
