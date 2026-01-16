import 'video_quality.dart';

/// Video Item Model
/// Represents a video in the catalog
class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    this.description,
    this.durationSec,
    required this.thumbnailUrl,
    this.slug,
    this.streamUrl,
    this.downloadQualities,
    this.tags,
  });

  /// Create from JSON
  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationSec: json['durationSec'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String,
      slug: json['slug'] as String?,
      streamUrl: json['streamUrl'] as String?,
      downloadQualities: json['download'] != null
          ? (json['download']['qualities'] as List<dynamic>?)
                ?.map((e) => VideoQuality.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
  final String id;
  final String title;
  final String? description;
  final int? durationSec;
  final String thumbnailUrl;
  final String? slug; // Ophim movie slug for detail API
  final String? streamUrl; // HLS stream URL (.m3u8)
  final List<VideoQuality>? downloadQualities;
  final List<String>? tags;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationSec': durationSec,
      'thumbnailUrl': thumbnailUrl,
      'slug': slug,
      'streamUrl': streamUrl,
      'download': downloadQualities != null
          ? {'qualities': downloadQualities!.map((e) => e.toJson()).toList()}
          : null,
      'tags': tags,
    };
  }

  /// Check if has download options
  bool get hasDownloadOptions => downloadQualities != null && downloadQualities!.isNotEmpty;

  /// Get best quality for download
  VideoQuality? get bestQuality {
    if (downloadQualities == null || downloadQualities!.isEmpty) return null;
    return downloadQualities!.reduce((a, b) => (a.sizeMB ?? 0) > (b.sizeMB ?? 0) ? a : b);
  }

  /// Get lowest quality for download
  VideoQuality? get lowestQuality {
    if (downloadQualities == null || downloadQualities!.isEmpty) return null;
    return downloadQualities!.reduce((a, b) => (a.sizeMB ?? 0) < (b.sizeMB ?? 0) ? a : b);
  }

  /// Copy with
  VideoItem copyWith({
    String? id,
    String? title,
    String? description,
    int? durationSec,
    String? thumbnailUrl,
    String? slug,
    String? streamUrl,
    List<VideoQuality>? downloadQualities,
    List<String>? tags,
  }) {
    return VideoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSec: durationSec ?? this.durationSec,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      slug: slug ?? this.slug,
      streamUrl: streamUrl ?? this.streamUrl,
      downloadQualities: downloadQualities ?? this.downloadQualities,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
