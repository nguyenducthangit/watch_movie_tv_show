import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/utils/extensions.dart';

/// Downloads Controller
class DownloadsController extends GetxController {
  final DownloadService _downloadService = DownloadService.to;

  // Edit mode state
  final RxBool isEditMode = false.obs;
  final RxList<String> selectedIds = <String>[].obs;

  // Expose download service observables
  RxList<DownloadTask> get activeDownloads => _downloadService.activeDownloads;
  RxList<DownloadTask> get completedDownloads => _downloadService.completedDownloads;
  RxInt get totalStorageBytes => _downloadService.totalStorageBytes;

  /// Get storage used string
  String get storageUsedString {
    return totalStorageBytes.value.toBytesString();
  }

  /// Toggle edit mode
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      selectedIds.clear();
    }
  }

  /// Toggle selection for a video
  void toggleSelection(String videoId) {
    if (selectedIds.contains(videoId)) {
      selectedIds.remove(videoId);
    } else {
      selectedIds.add(videoId);
    }
  }

  /// Select all completed downloads
  void selectAll() {
    selectedIds.clear();
    selectedIds.addAll(completedDownloads.map((task) => task.videoId));
  }

  /// Unselect all
  void unselectAll() {
    selectedIds.clear();
  }

  /// Check if video is selected
  bool isSelected(String videoId) {
    return selectedIds.contains(videoId);
  }

  /// Get selected count
  int get selectedCount => selectedIds.length;

  /// Delete selected downloads
  void deleteSelected() {
    if (selectedIds.isEmpty) return;

    Get.defaultDialog(
      title: 'Delete ${selectedIds.length} Videos',
      middleText: 'Are you sure you want to delete ${selectedIds.length} video(s)?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onConfirm: () {
        // Delete each selected video
        for (final videoId in selectedIds.toList()) {
          _downloadService.deleteDownload(videoId);
        }
        // Exit edit mode
        toggleEditMode();
        Get.back();
      },
    );
  }

  /// Play downloaded video
  void playVideo(DownloadTask task) {
    Get.toNamed(
      MRoutes.player,
      arguments: {
        'video': null, // We don't have full video item here
        'localPath': task.localPath,
        'title': task.videoTitle,
      },
    );
  }

  /// Pause download
  void pauseDownload(String videoId) {
    _downloadService.pauseDownload(videoId);
  }

  /// Resume download
  void resumeDownload(String videoId) {
    _downloadService.resumeDownload(videoId);
  }

  /// Cancel download
  void cancelDownload(String videoId) {
    _downloadService.cancelDownload(videoId);
  }

  /// Delete downloaded video
  void deleteDownload(String videoId) {
    Get.defaultDialog(
      title: 'Delete Download',
      middleText: 'Are you sure you want to delete this video?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onConfirm: () {
        _downloadService.deleteDownload(videoId);
        Get.back();
      },
    );
  }

  /// Delete all downloads
  void deleteAllDownloads() {
    if (completedDownloads.isEmpty && activeDownloads.isEmpty) return;

    Get.defaultDialog(
      title: 'Delete All',
      middleText: 'Are you sure you want to delete all downloads?',
      textConfirm: 'Delete All',
      textCancel: 'Cancel',
      onConfirm: () {
        _downloadService.deleteAllDownloads();
        Get.back();
      },
    );
  }

  /// Check if has any downloads
  bool get hasDownloads => activeDownloads.isNotEmpty || completedDownloads.isNotEmpty;
}
