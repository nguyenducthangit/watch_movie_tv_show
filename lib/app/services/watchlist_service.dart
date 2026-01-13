import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';

/// Watchlist Service
/// Manages user's watchlist using Hive for persistence
class WatchlistService extends GetxService {
  /// Observable watchlist IDs
  final RxList<String> watchlistIds = <String>[].obs;

  /// Initialize service
  Future<WatchlistService> init() async {
    _loadWatchlist();
    return this;
  }

  /// Load watchlist from storage
  void _loadWatchlist() {
    final ids = StorageService.instance.getWatchlistIds();
    watchlistIds.assignAll(ids);
  }

  /// Add video to watchlist
  Future<void> addToWatchlist(String videoId) async {
    if (!watchlistIds.contains(videoId)) {
      await StorageService.instance.toggleWatchlist(videoId);
      watchlistIds.add(videoId);
    }
  }

  /// Remove video from watchlist
  Future<void> removeFromWatchlist(String videoId) async {
    if (watchlistIds.contains(videoId)) {
      await StorageService.instance.toggleWatchlist(videoId);
      watchlistIds.remove(videoId);
    }
  }

  /// Toggle video in watchlist
  Future<void> toggleWatchlist(String videoId) async {
    final result = await StorageService.instance.toggleWatchlist(videoId);
    if (result) {
      if (!watchlistIds.contains(videoId)) watchlistIds.add(videoId);
    } else {
      watchlistIds.remove(videoId);
    }
  }

  /// Check if video is in watchlist
  bool isInWatchlist(String videoId) {
    return watchlistIds.contains(videoId);
  }

  /// Get all watchlist IDs
  List<String> getWatchlistIds() {
    return watchlistIds.toList();
  }

  /// Clear all watchlist
  Future<void> clearWatchlist() async {
    await StorageService.instance.clearWatchlist();
    watchlistIds.clear();
  }

  /// Get watchlist count
  int get count => watchlistIds.length;
}
