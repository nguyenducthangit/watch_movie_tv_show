import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/repositories/video_repository.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Home Controller
/// Manages video catalog display and search
class HomeController extends GetxController {
  final VideoRepository _repo = VideoRepository();

  // State
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Data
  final RxList<VideoItem> videos = <VideoItem>[].obs;
  final RxList<VideoItem> filteredVideos = <VideoItem>[].obs;
  final RxList<String> tags = <String>[].obs;

  // Search & Filter
  final RxString searchQuery = ''.obs;
  final RxString selectedTag = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVideos();

    // Listen to search changes
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 300));
  }

  /// Load videos from repository
  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final manifest = await _repo.getManifest();
      videos.value = manifest.items;
      tags.value = manifest.allTags;
      _applyFilters();

      logger.i('Loaded ${videos.length} videos');
    } catch (e) {
      logger.e('Failed to load videos: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh videos
  Future<void> refreshVideos() async {
    try {
      isRefreshing.value = true;
      hasError.value = false;

      final manifest = await _repo.refreshManifest();
      videos.value = manifest.items;
      tags.value = manifest.allTags;
      _applyFilters();

      logger.i('Refreshed ${videos.length} videos');
    } catch (e) {
      logger.e('Failed to refresh videos: $e');
      Get.snackbar('Error', 'Failed to refresh content');
    } finally {
      isRefreshing.value = false;
    }
  }

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

  /// Retry loading
  void retry() {
    loadVideos();
  }
}
