import 'package:watch_movie_tv_show/app/data/models/hls_models.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// HLS Parser Utility
/// Parses m3u8 playlists and extracts segments, encryption info
class HLSParser {
  /// Parse media playlist and extract segments
  static HLSPlaylist parseMediaPlaylist(String content, String baseUrl) {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    final segments = <HLSSegment>[];
    HLSKey? encryptionKey;
    int? targetDuration;

    double? currentDuration;
    int sequence = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip comments não phải tag
      if (line.startsWith('#') && !line.startsWith('#EXT')) {
        continue;
      }

      // Extract target duration
      if (line.startsWith('#EXT-X-TARGETDURATION:')) {
        targetDuration = int.tryParse(line.split(':')[1]);
      }

      // Extract encryption key
      if (line.startsWith('#EXT-X-KEY:')) {
        encryptionKey = _parseKey(line, baseUrl);
      }

      // Extract segment duration
      if (line.startsWith('#EXTINF:')) {
        final durationStr = line.split(':')[1].split(',')[0];
        currentDuration = double.tryParse(durationStr);
      }

      // Segment URL (không bắt đầu bằng #)
      if (!line.startsWith('#') && currentDuration != null) {
        final segmentUrl = _resolveUrl(baseUrl, line);
        segments.add(HLSSegment(url: segmentUrl, duration: currentDuration, sequence: sequence++));
        currentDuration = null;
      }
    }

    logger.i('Parsed ${segments.length} segments from playlist');

    return HLSPlaylist(
      url: baseUrl,
      segments: segments,
      encryptionKey: encryptionKey,
      targetDuration: targetDuration,
    );
  }

  /// Parse master playlist and extract quality variants
  static List<QualityVariant> parseMasterPlaylist(String content, String baseUrl) {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final variants = <QualityVariant>[];

    int? bandwidth;
    String? resolution;
    String? name;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXT-X-STREAM-INF:')) {
        // Parse attributes
        final attrs = _parseAttributes(line);
        bandwidth = int.tryParse(attrs['BANDWIDTH'] ?? '0');
        resolution = attrs['RESOLUTION'];
        name = attrs['NAME'];
      }

      // Next line sau STREAM-INF là URL
      if (!line.startsWith('#') && bandwidth != null) {
        final variantUrl = _resolveUrl(baseUrl, line);
        variants.add(
          QualityVariant(
            url: variantUrl,
            bandwidth: bandwidth,
            resolution: resolution,
            name: name ?? _inferQualityName(resolution),
          ),
        );
        bandwidth = null;
        resolution = null;
        name = null;
      }
    }

    logger.i('Parsed ${variants.length} quality variants from master playlist');
    return variants;
  }

  /// Parse encryption key tag
  static HLSKey? _parseKey(String line, String baseUrl) {
    final attrs = _parseAttributes(line);
    final method = attrs['METHOD'];
    final uri = attrs['URI']?.replaceAll('"', '');
    final iv = attrs['IV'];

    if (method == null || uri == null) return null;

    return HLSKey(method: method, uri: _resolveUrl(baseUrl, uri), iv: iv);
  }

  /// Parse attributes từ tag (e.g., METHOD=AES-128,URI="...")
  static Map<String, String> _parseAttributes(String line) {
    final attrs = <String, String>{};
    final attrString = line.contains(':') ? line.split(':').skip(1).join(':') : line;

    // Simple parsing: split by comma, handle quoted values
    final parts = <String>[];
    var current = '';
    var inQuote = false;

    for (var i = 0; i < attrString.length; i++) {
      final char = attrString[i];
      if (char == '"') {
        inQuote = !inQuote;
        current += char;
      } else if (char == ',' && !inQuote) {
        parts.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    if (current.isNotEmpty) parts.add(current.trim());

    for (final part in parts) {
      final kv = part.split('=');
      if (kv.length == 2) {
        attrs[kv[0].trim()] = kv[1].trim();
      }
    }

    return attrs;
  }

  /// Resolve relative URL to absolute
  static String _resolveUrl(String base, String relative) {
    // Already absolute
    if (relative.startsWith('http://') || relative.startsWith('https://')) {
      return relative;
    }

    // Parse base URL
    final baseUri = Uri.parse(base);

    // Relative path
    if (relative.startsWith('/')) {
      // Absolute path relative to origin
      return '${baseUri.scheme}://${baseUri.host}$relative';
    } else {
      // Relative to current directory
      final basePath = baseUri.path.substring(0, baseUri.path.lastIndexOf('/') + 1);
      return '${baseUri.scheme}://${baseUri.host}$basePath$relative';
    }
  }

  /// Infer quality name từ resolution
  static String? _inferQualityName(String? resolution) {
    if (resolution == null) return null;

    if (resolution.contains('1920x1080')) return '1080p';
    if (resolution.contains('1280x720')) return '720p';
    if (resolution.contains('854x480')) return '480p';
    if (resolution.contains('640x360')) return '360p';

    return resolution;
  }

  /// Check if content is master playlist (has #EXT-X-STREAM-INF)
  static bool isMasterPlaylist(String content) {
    return content.contains('#EXT-X-STREAM-INF');
  }
}
