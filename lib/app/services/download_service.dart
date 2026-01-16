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
    _calculateStorage();

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

    _refreshLists();
  }

  /// Handle progress update
  void _handleProgressUpdate(bd.TaskProgressUpdate update) {
    final taskId = update.task.taskId;
    final task = _findTaskByTaskId(taskId);
    if (task == null) return;

    task.progress = update.progress;
    _storage.saveDownloadTask(task);
    _refreshLists();
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
    _calculateStorage();
  }

  /// Refresh observable lists
  void _refreshLists() {
    activeDownloads.refresh();
    completedDownloads.refresh();
  }

  /// Calculate storage used
  Future<void> _calculateStorage() async {
    int total = 0;
    for (final task in completedDownloads) {
      if (task.localPath != null) {
        final file = File(task.localPath!);
        if (await file.exists()) {
          total += await file.length();
        }
      }
    }
    totalStorageBytes.value = total;
  }

  // ============ Public Methods ============

  /// Start download
  Future<void> startDownload(VideoItem video, VideoQuality quality) async {
    // Check if already downloading or downloaded
    if (isDownloading(video.id) || isDownloaded(video.id)) {
      logger.w('Video already downloading or downloaded');
      return;
    }

    // Check concurrent downloads limit
    if (activeDownloads.length >= AppConfig.maxConcurrentDownloads) {
      logger.w('Max concurrent downloads reached');
      Get.snackbar('Limit Reached', 'Please wait for current downloads to finish');
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

    if (isHLS) {
      // HLS download
      logger.i('Starting HLS download: ${video.title}');
      await _hlsDownloader.startHLSDownload(
        videoId: video.id,
        videoTitle: video.title,
        m3u8Url: quality.url,
        quality: quality.label,
        task: task,
      );

      // Move to completed
      _moveToCompleted(task);
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
  }

  /// Pause download
  Future<void> pauseDownload(String videoId) async {
    final task = _storage.getDownloadTask(videoId);
    if (task?.taskId == null) return;

    await bd.FileDownloader().pause(
      bd.DownloadTask(
        taskId: task!.taskId!,
        url: task.downloadUrl,
        filename: '${task.videoId}_${task.qualityLabel}.mp4',
      ),
    );
  }

  /// Resume download
  Future<void> resumeDownload(String videoId) async {
    final task = _storage.getDownloadTask(videoId);
    if (task?.taskId == null) return;

    await bd.FileDownloader().resume(
      bd.DownloadTask(
        taskId: task!.taskId!,
        url: task.downloadUrl,
        filename: '${task.videoId}_${task.qualityLabel}.mp4',
      ),
    );
  }

  /// Cancel download
  Future<void> cancelDownload(String videoId) async {
    final task = _storage.getDownloadTask(videoId);
    if (task?.taskId == null) return;

    await bd.FileDownloader().cancelTaskWithId(task!.taskId!);
    await _storage.deleteDownloadTask(videoId);
    activeDownloads.removeWhere((t) => t.videoId == videoId);

    logger.i('Download cancelled: $videoId');
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
    _calculateStorage();

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
  String? getLocalPath(String videoId) {
    final task = _storage.getDownloadTask(videoId);
    if (task == null) return null;

    // Return HLS playlist path or regular video path
    if (task.isHLS) {
      return _hlsDownloader.getLocalPlaylistPath(videoId);
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
