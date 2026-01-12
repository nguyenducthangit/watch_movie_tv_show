import 'package:hive/hive.dart';

part 'watch_progress.g.dart';

/// Watch Progress Model
/// Tracks video playback position for resume functionality
@HiveType(typeId: 2)
class WatchProgress extends HiveObject {
  WatchProgress({
    required this.videoId,
    required this.positionMs,
    required this.durationMs,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
  @HiveField(0)
  final String videoId;

  @HiveField(1)
  int positionMs;

  @HiveField(2)
  int durationMs;

  @HiveField(3)
  DateTime updatedAt;

  /// Get progress percentage
  double get progressPercent {
    if (durationMs == 0) return 0.0;
    return positionMs / durationMs;
  }

  /// Check if completed (watched > 90%)
  bool get isCompleted => progressPercent > 0.9;

  /// Check if has significant progress (watched > 5%)
  bool get hasProgress => positionMs > 0 && progressPercent > 0.05;

  /// Format remaining time
  String get remainingFormatted {
    final remaining = Duration(milliseconds: durationMs - positionMs);
    final minutes = remaining.inMinutes;
    return '$minutes min left';
  }

  /// Copy with
  WatchProgress copyWith({String? videoId, int? positionMs, int? durationMs, DateTime? updatedAt}) {
    return WatchProgress(
      videoId: videoId ?? this.videoId,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
