import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watch_movie_tv_show/app/config/app_config.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/video_quality.dart';
import 'package:watch_movie_tv_show/app/services/hls_download_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';

/// Download Service
/// Manages video downloads using background_downloader
class DownloadService extends GetxService {
  static DownloadService get to => Get.find<DownloadService>();

  final _storage = StorageService.instance;
  final _hlsDownloader = HLSDownloadService();

  // Observable state
  final RxList<DownloadTask> activeDownloads = <DownloadTask>[].obs;
  final RxList<DownloadTask> completedDownloads = <DownloadTask>[].obs;
  final RxInt totalStorageBytes = 0.obs;

  String? _downloadDirectory;

  @override
  void onInit() {
    super.onInit();
    _initDownloader();
  }

  /// Initialize downloader
  Future<void> _initDownloader() async {
    // Get download directory
    final appDir = await getApplicationDocumentsDirectory();
    _downloadDirectory = '${appDir.path}/videos';

    // Create directory if not exists
    final dir = Directory(_downloadDirectory!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Configure downloader
    bd.FileDownloader().configureNotification(
      running: const bd.TaskNotification('Downloading', '{filename}'),
      complete: const bd.TaskNotification('Download complete', '{filename}'),
      error: const bd.TaskNotification('Download failed', '{filename}'),
      paused: const bd.TaskNotification('Download paused', '{filename}'),
      progressBar: true,
    );

    // Register listeners
    bd.FileDownloader().updates.listen(_handleDownloadUpdate);

    // Load existing tasks
    _loadExistingTasks();

    // Calculate storage
    calculateStorage();

    logger.i('DownloadService initialized');
  }

  /// Load existing tasks from storage
  void _loadExistingTasks() {
    activeDownloads.value = _storage.getActiveDownloads();
    completedDownloads.value = _storage.getCompletedDownloads();
  }

  /// Handle download updates
  void _handleDownloadUpdate(bd.TaskUpdate update) {
    if (update is bd.TaskStatusUpdate) {
      _handleStatusUpdate(update);
    } else if (update is bd.TaskProgressUpdate) {
      _handleProgressUpdate(update);
    }
  }

  /// Handle status update
  Future<void> _handleStatusUpdate(bd.TaskStatusUpdate update) async {
    final taskId = update.task.taskId;
    final task = _findTaskByTaskId(taskId);
    if (task == null) return;

    switch (update.status) {
      case bd.TaskStatus.complete:
        task.status = DownloadStatus.completed;
        task.progress = 1.0;
        task.localPath = await update.task.filePath();
        _moveToCompleted(task);
        break;
      case bd.TaskStatus.failed:
        task.status = DownloadStatus.failed;
        task.errorMessage = 'Download failed';
        _storage.saveDownloadTask(task);
        break;
      case bd.TaskStatus.paused:
        task.status = DownloadStatus.paused;
        _storage.saveDownloadTask(task);
        break;
      case bd.TaskStatus.running:
        task.status = DownloadStatus.downloading;
        _storage.saveDownloadTask(task);
        break;
      default:
        break;
    }

    // Trigger selective UI update for this specific task
    try {
      Get.find<DownloadsController>().update(['download_task_${task.videoId}']);
    } catch (e) {
      // Controller might not be registered yet, fallback to refresh
      _refreshLists();
    }

    // Recalculate storage on status change (e.g. paused, completed, failed)
    calculateStorage();
  }

  /// Handle progress update
  void _handleProgressUpdate(bd.TaskProgressUpdate update) {
    final taskId = update.task.taskId;
    final task = _findTaskByTaskId(taskId);
    if (task == null) return;

    task.progress = update.progress;
    _storage.saveDownloadTask(task);

    // Trigger selective UI update for this specific task
    try {
      Get.find<DownloadsController>().update(['download_task_${task.videoId}']);
    } catch (e) {
      // Controller might not be registered yet, fallback to refresh
      _refreshLists();
    }
  }

  /// Find task by background downloader task ID
  DownloadTask? _findTaskByTaskId(String taskId) {
    for (final task in activeDownloads) {
      if (task.taskId == taskId) return task;
    }
    return null;
  }

  /// Move task to completed list
  void _moveToCompleted(DownloadTask task) {
    activeDownloads.removeWhere((t) => t.videoId == task.videoId);
    completedDownloads.add(task);
    _storage.saveDownloadTask(task);
    calculateStorage();
  }

  /// Refresh observable lists
  void _refreshLists() {
    activeDownloads.refresh();
    completedDownloads.refresh();
  }

  /// Calculate storage used
  Future<void> calculateStorage() async {
    int total = 0;

    // Helper to add task size
    Future<void> addTaskSize(DownloadTask task) async {
      try {
        if (task.isHLS) {
          // For HLS, optimize by checking directory size
          if (_downloadDirectory != null && task.videoId.isNotEmpty) {
            final videoDir = Directory('$_downloadDirectory/${task.videoId}');
            if (await videoDir.exists()) {
              total += await _getDirectorySize(videoDir);
            }
          }
        } else {
          // For MP4
          if (task.localPath != null) {
            final file = File(task.localPath!);
            if (await file.exists()) {
              total += await file.length();
            }
          } else if (task.status == DownloadStatus.downloading && task.taskId != null) {
            // For active MP4, we might not have access to temp file easily depending on lib,
            // but if we have a path in task (some libs provide it), use it.
            // keeping it simple for now as background_downloader manages temp files internally.
          }
        }
      } catch (e) {
        logger.e('Error calculating size for ${task.videoId}: $e');
      }
    }

    // Calculate for completed
    for (final task in completedDownloads) {
      await addTaskSize(task);
    }

    // Calculate for active (HLS segments are written immediately)
    for (final task in activeDownloads) {
      await addTaskSize(task);
    }

    totalStorageBytes.value = total;
  }

  /// Get directory size recursively
  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (final file in dir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            size += await file.length();
          }
        }
      }
    } catch (e) {
      logger.e('Error getting directory size: $e');
    }
    return size;
  }

  // ============ Public Methods ============

  /// Start download
  Future<void> startDownload(VideoItem video, VideoQuality quality, {int variantIndex = 0}) async {
    // Check if already downloading or downloaded
    if (isDownloading(video.id) || isDownloaded(video.id)) {
      logger.w('Video already downloading or downloaded');
      Get.snackbar(
        'Already Downloaded',
        '${video.title} is already in your downloads',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check concurrent downloads limit
    if (activeDownloads.length >= AppConfig.maxConcurrentDownloads) {
      logger.w('Max concurrent downloads reached');
      Get.snackbar(
        'Download Limit Reached',
        'You have ${activeDownloads.length} active downloads. Please wait for them to finish.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Detect HLS (m3u8) download
    final isHLS = quality.url.contains('.m3u8');

    // Create download task
    final task = DownloadTask(
      videoId: video.id,
      videoTitle: video.title,
      thumbnailUrl: video.thumbnailUrl,
      downloadUrl: quality.url,
      qualityLabel: quality.label,
      status: DownloadStatus.queued,
      isHLS: isHLS,
    );

    // Save and add to list
    await _storage.saveDownloadTask(task);
    activeDownloads.add(task);

    try {
      if (isHLS) {
        // HLS download
        logger.i('Starting HLS download: ${video.title} with variant $variantIndex');
        await _hlsDownloader.startHLSDownload(
          videoId: video.id,
          videoTitle: video.title,
          m3u8Url: quality.url,
          quality: quality.label,
          task: task,
          selectedVariantIndex: variantIndex, // Pass variant index
        );

        // Move to completed
        _moveToCompleted(task);

        Get.snackbar(
          'Download Complete',
          '${video.title} is ready to watch offline',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Regular MP4 download
        final filename = '${video.id}_${quality.label}.mp4';
        final backgroundTask = bd.DownloadTask(
          url: quality.url,
          filename: filename,
          directory: 'videos',
          baseDirectory: bd.BaseDirectory.applicationDocuments,
          retries: AppConfig.downloadRetryCount,
          allowPause: true,
        );

        task.taskId = backgroundTask.taskId;
        await _storage.saveDownloadTask(task);

        // Enqueue download
        await bd.FileDownloader().enqueue(backgroundTask);
        logger.i('Download started: ${video.title}');
      }
    } catch (e) {
      // Handle errors with specific messages
      String errorMessage = 'Failed to start download';

      if (e.toString().contains('Network') || e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Check your connection and try again.';
      } else if (e.toString().contains('space') || e.toString().contains('storage')) {
        errorMessage = 'Not enough storage space. Free up some space and try again.';
      } else if (e.toString().contains('format') || e.toString().contains('playlist')) {
        errorMessage = 'Video format not supported for download.';
      }

      logger.e('Download error: $e');
      task.status = DownloadStatus.failed;
      task.errorMessage = errorMessage;
      await _storage.saveDownloadTask(task);

      Get.snackbar(
        'Download Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Cancel download
  Future<void> cancelDownload(String videoId) async {
    final task = _storage.getDownloadTask(videoId);
    if (task == null) {
      logger.w('cancelDownload: Task not found for videoId: $videoId');
      return;
    }

    try {
      if (task.isHLS) {
        // HLS: Mark as failed (download loop will stop), then delete
        task.status = DownloadStatus.failed;
        task.errorMessage = 'Cancelled by user';
        await _storage.saveDownloadTask(task);

        // Delete partial files
        await _hlsDownloader.deleteHLSDownload(videoId);

        logger.i('HLS download cancelled: $videoId');
      } else {
        // MP4: Use background downloader cancel
        if (task.taskId != null) {
          await bd.FileDownloader().cancelTaskWithId(task.taskId!);
        }
        logger.i('MP4 download cancelled: $videoId');
      }

      // Remove from storage and list
      await _storage.deleteDownloadTask(videoId);
      activeDownloads.removeWhere((t) => t.videoId == videoId);

      // Trigger UI update
      _refreshLists();

      // Recalculate storage
      calculateStorage();
    } catch (e) {
      logger.e('Error cancelling download: $e');
      Get.snackbar(
        'Cancel Failed',
        'Could not cancel download. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Delete downloaded video
  Future<void> deleteDownload(String videoId) async {
    final task = _storage.getDownloadTask(videoId);
    if (task == null) return;

    // Delete HLS or regular
    if (task.isHLS) {
      await _hlsDownloader.deleteHLSDownload(videoId);
    } else {
      // Delete file
      if (task.localPath != null) {
        final file = File(task.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Remove from storage and list
    await _storage.deleteDownloadTask(videoId);
    completedDownloads.removeWhere((t) => t.videoId == videoId);

    // Recalculate storage
    calculateStorage();

    logger.i('Download deleted: $videoId');
  }

  /// Delete all downloads
  Future<void> deleteAllDownloads() async {
    // Cancel active downloads
    for (final task in activeDownloads) {
      if (task.taskId != null) {
        await bd.FileDownloader().cancelTaskWithId(task.taskId!);
      }
    }

    // Delete files
    for (final task in completedDownloads) {
      if (task.localPath != null) {
        final file = File(task.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Clear storage
    await _storage.clearAllDownloads();
    activeDownloads.clear();
    completedDownloads.clear();
    totalStorageBytes.value = 0;

    logger.i('All downloads deleted');
  }

  /// Get local path for video
  Future<String?> getLocalPath(String videoId) async {
    final task = _storage.getDownloadTask(videoId);
    if (task == null) return null;

    // Return HLS playlist path or regular video path
    if (task.isHLS) {
      return await _hlsDownloader.getLocalPlaylistPath(videoId);
    }
    return task.localPath;
  }

  /// Check if video is downloading
  bool isDownloading(String videoId) {
    return activeDownloads.any((t) => t.videoId == videoId);
  }

  /// Check if video is downloaded
  bool isDownloaded(String videoId) {
    return completedDownloads.any((t) => t.videoId == videoId);
  }

  /// Get download task
  DownloadTask? getTask(String videoId) {
    for (final task in activeDownloads) {
      if (task.videoId == videoId) return task;
    }
    for (final task in completedDownloads) {
      if (task.videoId == videoId) return task;
    }
    return null;
  }

  /// Get download progress
  double getProgress(String videoId) {
    return _storage.getDownloadTask(videoId)?.progress ?? 0.0;
  }

  @override
  void onClose() {
    bd.FileDownloader().resetUpdates();
    super.onClose();
  }
}
