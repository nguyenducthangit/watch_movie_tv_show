/// Video Quality Model
/// Represents a download quality option
class VideoQuality {
  const VideoQuality({required this.label, required this.url, this.sizeMB});

  /// Create from JSON
  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      label: json['label'] as String,
      url: json['url'] as String,
      sizeMB: (json['sizeMB'] as num?)?.toDouble(),
    );
  }
  final String label;
  final String url;
  final double? sizeMB;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'label': label, 'url': url, 'sizeMB': sizeMB};
  }

  /// Copy with
  VideoQuality copyWith({String? label, String? url, double? sizeMB}) {
    return VideoQuality(
      label: label ?? this.label,
      url: url ?? this.url,
      sizeMB: sizeMB ?? this.sizeMB,
    );
  }

  @override
  String toString() => '$label (${sizeMB?.toStringAsFixed(0) ?? '?'} MB)';
}
