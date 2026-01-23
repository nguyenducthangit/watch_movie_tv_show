import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Preload Service
/// Manages pre-loaded movies and translations from splash screen
class PreloadService extends GetxService {
  List<VideoItem>? _preloadedMovies;
  bool _isPreloading = false;
  bool _isPreloadComplete = false;

  /// Check if preloading is in progress
  bool get isPreloading => _isPreloading;

  /// Check if preload is complete
  bool get isPreloadComplete => _isPreloadComplete;

  /// Get preloaded movies
  List<VideoItem>? getPreloadedMovies() {
    return _preloadedMovies;
  }

  /// Set preloaded movies
  void setPreloadedMovies(List<VideoItem> movies, {bool isComplete = false}) {
    _preloadedMovies = movies;
    _isPreloadComplete = isComplete;
    _isPreloading = false;
    logger.i('Preloaded ${movies.length} movies, complete: $isComplete');
  }

  /// Mark preloading as started
  void startPreloading() {
    _isPreloading = true;
    _isPreloadComplete = false;
    logger.i('Preloading started');
  }

  /// Mark preloading as complete
  void markPreloadComplete() {
    _isPreloadComplete = true;
    _isPreloading = false;
    logger.i('Preloading completed');
  }

  /// Clear preloaded data
  void clearPreload() {
    _preloadedMovies = null;
    _isPreloading = false;
    _isPreloadComplete = false;
    logger.i('Preload data cleared');
  }

  /// Check if has preloaded data
  bool hasPreloadedData() {
    return _preloadedMovies != null && _preloadedMovies!.isNotEmpty;
  }
}
