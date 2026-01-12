import 'package:hive_flutter/hive_flutter.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/data/models/watch_progress.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Storage Service using Hive
class StorageService {
  StorageService._();
  static StorageService? _instance;

  static const String _manifestBoxName = 'manifest_box';
  static const String _downloadBoxName = 'download_box';
  static const String _progressBoxName = 'progress_box';

  static const String _watchlistBoxName = 'watchlist_box';
  static const String _settingsBoxName = 'settings_box';

  static const String _manifestKey = 'cached_manifest';
  static const String _manifestTimestampKey = 'manifest_timestamp';

  late Box<String> _manifestBox;
  late Box<DownloadTask> _downloadBox;
  late Box<WatchProgress> _progressBox;
  late Box<String> _watchlistBox;
  late Box<dynamic> _settingsBox;

  /// Get singleton instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize Hive and all boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(DownloadTaskAdapter());
    Hive.registerAdapter(DownloadStatusAdapter());
    Hive.registerAdapter(WatchProgressAdapter());

    // Open boxes
    _manifestBox = await Hive.openBox<String>(_manifestBoxName);
    _downloadBox = await Hive.openBox<DownloadTask>(_downloadBoxName);
    _progressBox = await Hive.openBox<WatchProgress>(_progressBoxName);
    _watchlistBox = await Hive.openBox<String>(_watchlistBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    logger.i('StorageService initialized');
  }

  // ============ Manifest Cache ============

  /// Save manifest JSON
  Future<void> saveManifest(String manifestJson) async {
    await _manifestBox.put(_manifestKey, manifestJson);
    await _manifestBox.put(_manifestTimestampKey, DateTime.now().toIso8601String());
  }

  /// Get cached manifest JSON
  String? getManifest() {
    return _manifestBox.get(_manifestKey);
  }

  /// Get manifest cache timestamp
  DateTime? getManifestTimestamp() {
    final timestamp = _manifestBox.get(_manifestTimestampKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  /// Check if manifest cache is valid
  bool isManifestCacheValid(Duration expiry) {
    final timestamp = getManifestTimestamp();
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < expiry;
  }

  /// Clear manifest cache
  Future<void> clearManifestCache() async {
    await _manifestBox.clear();
  }

  // ============ Download Tasks ============

  /// Save download task
  Future<void> saveDownloadTask(DownloadTask task) async {
    await _downloadBox.put(task.videoId, task);
  }

  /// Get download task by video ID
  DownloadTask? getDownloadTask(String videoId) {
    return _downloadBox.get(videoId);
  }

  /// Get all download tasks
  List<DownloadTask> getAllDownloadTasks() {
    return _downloadBox.values.toList();
  }

  /// Get active downloads
  List<DownloadTask> getActiveDownloads() {
    return _downloadBox.values.where((t) => t.isActive).toList();
  }

  /// Get completed downloads
  List<DownloadTask> getCompletedDownloads() {
    return _downloadBox.values.where((t) => t.isCompleted).toList();
  }

  /// Delete download task
  Future<void> deleteDownloadTask(String videoId) async {
    await _downloadBox.delete(videoId);
  }

  /// Clear all download tasks
  Future<void> clearAllDownloads() async {
    await _downloadBox.clear();
  }

  /// Check if video is downloaded
  bool isVideoDownloaded(String videoId) {
    final task = _downloadBox.get(videoId);
    return task?.isCompleted ?? false;
  }

  // ============ Watch Progress ============

  /// Save watch progress
  Future<void> saveWatchProgress(WatchProgress progress) async {
    await _progressBox.put(progress.videoId, progress);
  }

  /// Get watch progress by video ID
  WatchProgress? getWatchProgress(String videoId) {
    return _progressBox.get(videoId);
  }

  /// Delete watch progress
  Future<void> deleteWatchProgress(String videoId) async {
    await _progressBox.delete(videoId);
  }

  /// Clear all watch progress
  Future<void> clearAllProgress() async {
    await _progressBox.clear();
  }

  // ============ Watchlist ============

  /// Toggle watchlist
  Future<bool> toggleWatchlist(String videoId) async {
    if (_watchlistBox.containsKey(videoId)) {
      await _watchlistBox.delete(videoId);
      return false; // Removed
    } else {
      await _watchlistBox.put(videoId, videoId);
      return true; // Added
    }
  }

  /// Get all watchlist IDs
  List<String> getWatchlistIds() {
    return _watchlistBox.values.toList();
  }

  /// Check if in watchlist
  bool isInWatchlist(String videoId) {
    return _watchlistBox.containsKey(videoId);
  }

  /// Clear watchlist
  Future<void> clearWatchlist() async {
    await _watchlistBox.clear();
  }

  // ============ Settings ============

  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  // ============ Cleanup ============

  /// Clear all data
  Future<void> clearAll() async {
    await _manifestBox.clear();
    await _downloadBox.clear();
    await _progressBox.clear();
    await _watchlistBox.clear();
    await _settingsBox.clear();
    logger.i('All storage cleared');
  }

  /// Close all boxes
  Future<void> close() async {
    await _manifestBox.close();
    await _downloadBox.close();
    await _progressBox.close();
    await _watchlistBox.close();
    await _settingsBox.close();
  }
}
