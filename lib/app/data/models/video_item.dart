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
    this.year,
    this.quality,
    this.lang,
    this.episodeCurrent,
    this.episodeTotal,
    this.time,
    this.type,
    this.actor,
    this.director,
    this.country,
    this.trailerUrl,
    this.translatedTitle,
    this.translatedDescription,
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

  // Enhanced Ophim API fields
  final int? year;
  final String? quality; // HD, FHD, CAM
  final String? lang; // Vietsub, Thuyết minh
  final String? episodeCurrent; // Tập 10, Full
  final String? episodeTotal; // 24, 1
  final String? time; // 45 phút/tập, 120 Phút
  final String? type; // series, single, hoathinh
  final List<String>? actor;
  final List<String>? director;
  final List<String>? country;
  final String? trailerUrl;

  // Translation fields
  final String? translatedTitle;
  final String? translatedDescription;

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

  /// Get display title (translated if available, otherwise original)
  String get displayTitle => translatedTitle ?? title;

  /// Get display description (translated if available, otherwise original)
  String? get displayDescription => translatedDescription ?? description;

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
    int? year,
    String? quality,
    String? lang,
    String? episodeCurrent,
    String? episodeTotal,
    String? time,
    String? type,
    List<String>? actor,
    List<String>? director,
    List<String>? country,
    String? trailerUrl,
    String? translatedTitle,
    String? translatedDescription,
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
      year: year ?? this.year,
      quality: quality ?? this.quality,
      lang: lang ?? this.lang,
      episodeCurrent: episodeCurrent ?? this.episodeCurrent,
      episodeTotal: episodeTotal ?? this.episodeTotal,
      time: time ?? this.time,
      type: type ?? this.type,
      actor: actor ?? this.actor,
      director: director ?? this.director,
      country: country ?? this.country,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      translatedDescription: translatedDescription ?? this.translatedDescription,
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
