import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/video_quality.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Detail Controller
class DetailController extends GetxController {
  late VideoItem video;

  final RxBool isDownloading = false.obs;
  final RxBool isDownloaded = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final Rx<VideoQuality?> selectedQuality = Rx<VideoQuality?>(null);

  @override
  void onInit() {
    super.onInit();
    // Get video from arguments
    video = Get.arguments as VideoItem;
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
  }

  /// Play video
  void playVideo() {
    // Check if we have a local file
    final localPath = DownloadService.to.getLocalPath(video.id);

    Get.toNamed(MRoutes.player, arguments: {'video': video, 'localPath': localPath});
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
