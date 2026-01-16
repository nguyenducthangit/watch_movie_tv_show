/// HLS Models
/// Data structures for HLS playlist parsing

/// HLS Playlist representation
class HLSPlaylist {
  const HLSPlaylist({
    required this.url,
    required this.segments,
    this.encryptionKey,
    this.targetDuration,
  });

  final String url;
  final List<HLSSegment> segments;
  final HLSKey? encryptionKey;
  final int? targetDuration;

  bool get isEncrypted => encryptionKey != null;
  int get totalSegments => segments.length;
}

/// HLS Segment
class HLSSegment {
  const HLSSegment({required this.url, required this.duration, required this.sequence});

  final String url;
  final double duration;
  final int sequence;

  @override
  String toString() => 'Segment #$sequence: $url (${duration}s)';
}

/// HLS Encryption Key
class HLSKey {
  const HLSKey({required this.method, required this.uri, this.iv});

  final String method; // e.g., "AES-128"
  final String uri;
  final String? iv;

  bool get isAES128 => method == 'AES-128';

  @override
  String toString() => 'Key: $method, URI: $uri';
}

/// Quality Variant from master playlist
class QualityVariant {
  const QualityVariant({required this.url, required this.bandwidth, this.resolution, this.name});

  final String url;
  final int bandwidth;
  final String? resolution; // e.g., "1920x1080"
  final String? name; // e.g., "1080p", "720p"

  String get displayName {
    if (name != null) return name!;
    if (resolution != null) return resolution!;
    return '${(bandwidth / 1000000).toStringAsFixed(1)} Mbps';
  }

  @override
  String toString() => 'Quality: $displayName ($url)';
}
