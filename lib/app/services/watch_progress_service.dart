import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Watch Progress Service
/// Manages video watch progress for Continue Watching feature
class WatchProgressService extends GetxService {
  static const String _progressKey = 'watch_progress';
  static const String _historyKey = 'watch_history';

  late final SharedPreferences _prefs;

  /// Video progress map: videoId -> progress (0.0 to 1.0)
  final RxMap<String, double> _progressMap = <String, double>{}.obs;

  /// Watch history: videoId -> timestamp (most recent first)
  final RxMap<String, int> _historyMap = <String, int>{}.obs;

  /// Continue watching threshold
  static const double minProgressThreshold = 0.05; // 5% watched
  static const double maxProgressThreshold = 0.95; // 95% watched

  /// Initialize service
  Future<WatchProgressService> init() async {
    await _loadData();
    return this;
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();

    // Load progress
    final progressJson = _prefs.getString(_progressKey);
    if (progressJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(progressJson);
      _progressMap.value = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    // Load history
    final historyJson = _prefs.getString(_historyKey);
    if (historyJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(historyJson);
      _historyMap.value = decoded.map((k, v) => MapEntry(k, v as int));
    }
  }

  Future<void> _saveProgress() async {
    await _prefs.setString(_progressKey, jsonEncode(_progressMap));
  }

  Future<void> _saveHistory() async {
    await _prefs.setString(_historyKey, jsonEncode(_historyMap));
  }

  /// Update watch progress for a video
  /// [progress] should be between 0.0 and 1.0
  Future<void> updateProgress(String videoId, double progress) async {
    _progressMap[videoId] = progress.clamp(0.0, 1.0);
    _historyMap[videoId] = DateTime.now().millisecondsSinceEpoch;

    await Future.wait([_saveProgress(), _saveHistory()]);
  }

  /// Get progress for a video (0.0 if never watched)
  double getProgress(String videoId) {
    return _progressMap[videoId] ?? 0.0;
  }

  /// Get progress as percentage string (e.g., "45%")
  String getProgressPercent(String videoId) {
    final progress = getProgress(videoId);
    return '${(progress * 100).round()}%';
  }

  /// Check if video was watched (progress > 0)
  bool wasWatched(String videoId) {
    return _progressMap.containsKey(videoId) && _progressMap[videoId]! > 0;
  }

  /// Check if video should appear in Continue Watching
  bool shouldContinueWatching(String videoId) {
    final progress = getProgress(videoId);
    return progress >= minProgressThreshold && progress < maxProgressThreshold;
  }

  /// Get list of video IDs that should appear in Continue Watching
  /// Sorted by most recently watched
  List<String> getContinueWatchingIds() {
    final eligibleIds = _progressMap.entries
        .where((e) => e.value >= minProgressThreshold && e.value < maxProgressThreshold)
        .map((e) => e.key)
        .toList();

    // Sort by most recent
    eligibleIds.sort((a, b) {
      final timeA = _historyMap[a] ?? 0;
      final timeB = _historyMap[b] ?? 0;
      return timeB.compareTo(timeA); // Descending
    });

    return eligibleIds;
  }

  /// Get full watch history IDs (most recent first)
  List<String> getWatchHistoryIds() {
    final ids = _historyMap.keys.toList();
    ids.sort((a, b) {
      final timeA = _historyMap[a] ?? 0;
      final timeB = _historyMap[b] ?? 0;
      return timeB.compareTo(timeA);
    });
    return ids;
  }

  /// Get last watched timestamp for a video
  DateTime? getLastWatched(String videoId) {
    final timestamp = _historyMap[videoId];
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Remove video from continue watching (mark as complete)
  Future<void> markAsComplete(String videoId) async {
    _progressMap[videoId] = 1.0;
    await _saveProgress();
  }

  /// Remove video from history
  Future<void> removeFromHistory(String videoId) async {
    _progressMap.remove(videoId);
    _historyMap.remove(videoId);
    await Future.wait([_saveProgress(), _saveHistory()]);
  }

  /// Clear all watch history
  Future<void> clearAllHistory() async {
    _progressMap.clear();
    _historyMap.clear();
    await Future.wait([_saveProgress(), _saveHistory()]);
  }

  /// Get count of continue watching items
  int get continueWatchingCount => getContinueWatchingIds().length;

  /// Observable for reactive UI updates
  RxMap<String, double> get progressMap => _progressMap;
}
