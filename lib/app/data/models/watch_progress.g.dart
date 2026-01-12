// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchProgressAdapter extends TypeAdapter<WatchProgress> {
  @override
  final int typeId = 2;

  @override
  WatchProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchProgress(
      videoId: fields[0] as String,
      positionMs: fields[1] as int,
      durationMs: fields[2] as int,
      updatedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WatchProgress obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.positionMs)
      ..writeByte(2)
      ..write(obj.durationMs)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchProgressAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
