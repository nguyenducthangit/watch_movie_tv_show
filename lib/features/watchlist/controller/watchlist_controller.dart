import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/repositories/manifest_repository.dart';
import 'package:watch_movie_tv_show/app/services/watchlist_service.dart';

/// Watchlist Controller
class WatchlistController extends GetxController {
  final WatchlistService _watchlistService = Get.find<WatchlistService>();
  final ManifestRepository _manifestRepository = ManifestRepository();

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
      final manifest = await _manifestRepository.getManifest();
      final allVideos = manifest.items;

      // Filter videos that are in watchlist
      watchlistVideos.value = allVideos.where((video) => watchlistIds.contains(video.id)).toList();
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
