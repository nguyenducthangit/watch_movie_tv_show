import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/video_quality.dart';
import 'package:watch_movie_tv_show/app/data/repositories/ophim_repository.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/watchlist_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Detail Controller
class DetailController extends GetxController {
  late VideoItem video;

  final RxBool isDownloading = false.obs;
  final RxBool isDownloaded = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  final Rx<VideoQuality?> selectedQuality = Rx<VideoQuality?>(null);
  final RxBool isInWatchlist = false.obs;
  final RxList<VideoItem> relatedVideos = <VideoItem>[].obs;
  final RxBool isLoadingDetail = false.obs;

  WatchlistService get _watchlistService => Get.find<WatchlistService>();
  final OphimRepository _repository = OphimRepository();

  @override
  void onInit() {
    super.onInit();
    // Get video from arguments
    video = Get.arguments as VideoItem;
    _loadMovieDetail();
    _loadRelatedVideos();
  }

  /// Load full movie detail from API
  Future<void> _loadMovieDetail() async {
    try {
      if (video.slug == null || video.slug!.isEmpty) return;

      isLoadingDetail.value = true;
      final movieDetail = await _repository.fetchMovieDetail(video.slug!);

      // Update video with full details (description, etc.)
      video = video.copyWith(
        description: movieDetail.content,
        // Can add more fields here if needed
      );

      logger.i('Loaded movie detail: ${movieDetail.name}');
    } catch (e) {
      logger.e('Failed to load movie detail: $e');
      // Continue anyway with basic info from list
    } finally {
      isLoadingDetail.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _checkDownloadStatus();
  }

  /// Check download status
  void _checkDownloadStatus() {
    final downloadService = DownloadService.to;
    isDownloaded.value = downloadService.isDownloaded(video.id);
    isDownloading.value = downloadService.isDownloading(video.id);
    downloadProgress.value = downloadService.getProgress(video.id);

    // Listen to active downloads changes
    ever(downloadService.activeDownloads, (_) {
      isDownloading.value = downloadService.isDownloading(video.id);
      downloadProgress.value = downloadService.getProgress(video.id);
    });

    ever(downloadService.completedDownloads, (_) {
      isDownloaded.value = downloadService.isDownloaded(video.id);
    });

    // Check watchlist
    isInWatchlist.value = _watchlistService.isInWatchlist(video.id);

    // Listen to watchlist changes
    ever(_watchlistService.watchlistIds, (_) {
      isInWatchlist.value = _watchlistService.isInWatchlist(video.id);
    });
  }

  /// Load related videos (videos with same tags)
  void _loadRelatedVideos() {
    // Get all videos from storage/service
    // For now, we'll leave this empty - it will be populated by the video service
    // In a real app, this would fetch videos with matching tags
    relatedVideos.clear();
  }

  /// Toggle watchlist
  Future<void> toggleWatchlist() async {
    await _watchlistService.toggleWatchlist(video.id);
    // State is updated automatically via 'ever' listener above

    final result = _watchlistService.isInWatchlist(video.id);
    Get.snackbar(
      result ? 'Added to List' : 'Removed from List',
      result
          ? '${video.title} added to your watchlist'
          : '${video.title} removed from your watchlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Share video
  void shareVideo() {
    final movieUrl = video.slug != null
        ? 'Check out this movie: ${video.title}'
        : 'Check out this video: ${video.title}';
    Share.share(movieUrl);
  }

  /// Play video - fetch detail with stream URL if not already loaded
  Future<void> playVideo() async {
    try {
      isLoadingDetail.value = true;

      // Fetch movie detail to get episodes and stream URL
      if (video.slug == null || video.slug!.isEmpty) {
        Get.snackbar('Error', 'Invalid movie slug');
        return;
      }

      final movieDetail = await _repository.fetchMovieDetail(video.slug!);

      // Convert to VideoItem with stream URL
      final videoWithStream = _repository.movieWithEpisodeToVideoItem(movieDetail);

      if (videoWithStream.streamUrl == null || videoWithStream.streamUrl!.isEmpty) {
        Get.snackbar('Error', 'No stream available for this video');
        return;
      }

      // Check if we have a local file
      final localPath = DownloadService.to.getLocalPath(video.id);

      Get.toNamed(
        MRoutes.player,
        arguments: {
          'video': videoWithStream, // Pass video with stream URL
          'localPath': localPath,
        },
      );
    } catch (e) {
      logger.e('Failed to play video: $e');
      Get.snackbar('Error', 'Failed to load video stream');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Show quality picker and start download
  void startDownload(VideoQuality quality) {
    DownloadService.to.startDownload(video, quality);
    Get.back(); // Close bottom sheet
    logger.i('Started download: ${video.title} - ${quality.label}');
  }

  /// Cancel download
  void cancelDownload() {
    DownloadService.to.cancelDownload(video.id);
  }

  /// Delete download
  void deleteDownload() {
    Get.defaultDialog(
      title: 'Delete Download',
      middleText: 'Are you sure you want to delete this video?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onConfirm: () {
        DownloadService.to.deleteDownload(video.id);
        Get.back();
      },
    );
  }

  /// Get download button text
  String get downloadButtonText {
    if (isDownloaded.value) return 'Downloaded';
    if (isDownloading.value) {
      return 'Downloading ${(downloadProgress.value * 100).toInt()}%';
    }
    return 'Download';
  }

  /// Check if has watch progress
  bool get hasWatchProgress {
    final progress = StorageService.instance.getWatchProgress(video.id);
    return progress?.hasProgress ?? false;
  }

  /// Get watch progress text
  String? get watchProgressText {
    final progress = StorageService.instance.getWatchProgress(video.id);
    if (progress?.hasProgress ?? false) {
      return progress!.remainingFormatted;
    }
    return null;
  }
}
