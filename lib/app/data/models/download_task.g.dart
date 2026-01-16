// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadTaskAdapter extends TypeAdapter<DownloadTask> {
  @override
  final int typeId = 0;

  @override
  DownloadTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadTask(
      videoId: fields[0] as String,
      videoTitle: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      downloadUrl: fields[3] as String,
      qualityLabel: fields[4] as String?,
      status: fields[5] as DownloadStatus,
      progress: fields[6] as double,
      localPath: fields[7] as String?,
      createdAt: fields[8] as DateTime?,
      errorMessage: fields[9] as String?,
      fileSizeBytes: fields[10] as int?,
      taskId: fields[11] as String?,
      isHLS: fields[12] as bool,
      totalSegments: fields[13] as int?,
      downloadedSegments: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadTask obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.videoTitle)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.downloadUrl)
      ..writeByte(4)
      ..write(obj.qualityLabel)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.progress)
      ..writeByte(7)
      ..write(obj.localPath)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.errorMessage)
      ..writeByte(10)
      ..write(obj.fileSizeBytes)
      ..writeByte(11)
      ..write(obj.taskId)
      ..writeByte(12)
      ..write(obj.isHLS)
      ..writeByte(13)
      ..write(obj.totalSegments)
      ..writeByte(14)
      ..write(obj.downloadedSegments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
