import 'package:hive/hive.dart';

part 'download_task.g.dart';

/// Download Status Enum
enum DownloadStatus { queued, downloading, paused, completed, failed }

/// Download Task Model
/// Stored in Hive for persistence
@HiveType(typeId: 0)
class DownloadTask extends HiveObject {
  DownloadTask({
    required this.videoId,
    required this.videoTitle,
    required this.thumbnailUrl,
    required this.downloadUrl,
    this.qualityLabel,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.localPath,
    DateTime? createdAt,
    this.errorMessage,
    this.fileSizeBytes,
    this.taskId,
  }) : createdAt = createdAt ?? DateTime.now();
  @HiveField(0)
  final String videoId;

  @HiveField(1)
  final String videoTitle;

  @HiveField(2)
  final String thumbnailUrl;

  @HiveField(3)
  final String downloadUrl;

  @HiveField(4)
  final String? qualityLabel;

  @HiveField(5)
  DownloadStatus status;

  @HiveField(6)
  double progress;

  @HiveField(7)
  String? localPath;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  String? errorMessage;

  @HiveField(10)
  int? fileSizeBytes;

  @HiveField(11)
  String? taskId;

  /// Check if download is active
  bool get isActive => status == DownloadStatus.queued || status == DownloadStatus.downloading;

  /// Check if download is completed
  bool get isCompleted => status == DownloadStatus.completed;

  /// Check if download failed
  bool get isFailed => status == DownloadStatus.failed;

  /// Check if download is paused
  bool get isPaused => status == DownloadStatus.paused;

  /// Get progress percentage
  int get progressPercent => (progress * 100).toInt();

  /// Copy with
  DownloadTask copyWith({
    String? videoId,
    String? videoTitle,
    String? thumbnailUrl,
    String? downloadUrl,
    String? qualityLabel,
    DownloadStatus? status,
    double? progress,
    String? localPath,
    DateTime? createdAt,
    String? errorMessage,
    int? fileSizeBytes,
    String? taskId,
  }) {
    return DownloadTask(
      videoId: videoId ?? this.videoId,
      videoTitle: videoTitle ?? this.videoTitle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      qualityLabel: qualityLabel ?? this.qualityLabel,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      taskId: taskId ?? this.taskId,
    );
  }
}

/// Hive Type Adapter for DownloadStatus
class DownloadStatusAdapter extends TypeAdapter<DownloadStatus> {
  @override
  final int typeId = 1;

  @override
  DownloadStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return DownloadStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, DownloadStatus obj) {
    writer.writeByte(obj.index);
  }
}
