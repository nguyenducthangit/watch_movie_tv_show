import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/repositories/ophim_repository.dart';
import 'package:watch_movie_tv_show/app/services/watchlist_service.dart';
import 'package:watch_movie_tv_show/features/language/domain/repositories/language_repository.dart';
import 'package:watch_movie_tv_show/features/translation/controller/translation_controller.dart';

/// Watchlist Controller
class WatchlistController extends GetxController {
  final WatchlistService _watchlistService = Get.find<WatchlistService>();
  final OphimRepository _repository = OphimRepository();

  TranslationController? get _translationController {
    try {
      return Get.find<TranslationController>();
    } catch (e) {
      return null;
    }
  }

  ILanguageRepository? get _languageRepository {
    try {
      return Get.find<ILanguageRepository>();
    } catch (e) {
      return null;
    }
  }

  final RxList<VideoItem> watchlistVideos = <VideoItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWatchlist();

    // Listen to changes in watchlist service
    ever(_watchlistService.watchlistIds, (_) => loadWatchlist());
  }

  /// Load watchlist videos
  Future<void> loadWatchlist() async {
    isLoading.value = true;
    try {
      final watchlistIds = _watchlistService.getWatchlistIds();

      // Fetch all videos from repository to find the ones in watchlist
      final allVideos = await _repository.fetchHomeMovies();

      // Filter videos that are in watchlist
      var filtered = allVideos.where((video) => watchlistIds.contains(video.id)).toList();

      // Translate movies
      final translationCtrl = _translationController;
      final langRepo = _languageRepository;

      if (translationCtrl != null && langRepo != null) {
        final currentLang = langRepo.getCurLangCode();
        filtered = await translationCtrl.translateMovieList(
          movies: filtered,
          targetLang: currentLang,
        );
      }

      watchlistVideos.value = filtered;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load watchlist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove video from watchlist
  Future<void> removeFromWatchlist(String videoId) async {
    await _watchlistService.removeFromWatchlist(videoId);
    // UI update handled by listener in onInit

    Get.snackbar(
      'Removed from Watchlist',
      'Video removed from your watchlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Refresh watchlist
  @override
  Future<void> refresh() async {
    // Force reload manifest if needed, or just re-filter
    await loadWatchlist();
  }

  /// Check if watchlist is empty
  bool get isEmpty => watchlistVideos.isEmpty;

  /// Get watchlist count
  int get count => watchlistVideos.length;
}
