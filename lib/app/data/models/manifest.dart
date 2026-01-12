import 'video_item.dart';

/// Manifest Model
/// Root model for video catalog
class Manifest {
  const Manifest({required this.version, required this.updatedAt, required this.items});

  /// Create from JSON
  factory Manifest.fromJson(Map<String, dynamic> json) {
    return Manifest(
      version: json['version'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  final int version;
  final DateTime updatedAt;
  final List<VideoItem> items;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  /// Get total video count
  int get videoCount => items.length;

  /// Get all unique tags
  List<String> get allTags {
    final tags = <String>{};
    for (final item in items) {
      if (item.tags != null) {
        tags.addAll(item.tags!);
      }
    }
    return tags.toList()..sort();
  }

  /// Filter videos by tag
  List<VideoItem> filterByTag(String tag) {
    return items.where((item) => item.tags?.contains(tag) ?? false).toList();
  }

  /// Search videos by title
  List<VideoItem> searchByTitle(String query) {
    final lowerQuery = query.toLowerCase();
    return items.where((item) => item.title.toLowerCase().contains(lowerQuery)).toList();
  }
}
