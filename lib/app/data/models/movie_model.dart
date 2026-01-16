/// Movie Model for Ophim API Response
/// Represents a movie or TV series from the Ophim catalog
class MovieModel {
  const MovieModel({
    required this.slug,
    required this.name,
    this.originName,
    this.content,
    this.thumbUrl,
    this.posterUrl,
    this.year,
    this.categories,
    this.episodes,
  });

  /// Create from JSON
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'movie' object if present
    final movieData = json['movie'] ?? json;

    return MovieModel(
      slug: movieData['slug'] as String? ?? '',
      name: movieData['name'] as String? ?? '',
      originName: movieData['origin_name'] as String?,
      content: _cleanHtmlDescription(movieData['content'] as String?),
      thumbUrl: movieData['thumb_url'] as String?,
      posterUrl: movieData['poster_url'] as String?,
      year: movieData['year'] as int?,
      categories: (movieData['category'] as List<dynamic>?)
          ?.map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList(),
      episodes: (movieData['episodes'] as List<dynamic>?)
          ?.map((e) => EpisodeServerData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Clean HTML tags from description
  static String? _cleanHtmlDescription(String? html) {
    if (html == null || html.isEmpty) return null;

    // Remove HTML tags
    String cleaned = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    return cleaned.trim();
  }

  final String slug;
  final String name;
  final String? originName;
  final String? content;
  final String? thumbUrl;
  final String? posterUrl;
  final int? year;
  final List<String>? categories;
  final List<EpisodeServerData>? episodes;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'origin_name': originName,
      'content': content,
      'thumb_url': thumbUrl,
      'poster_url': posterUrl,
      'year': year,
      'category': categories?.map((name) => {'name': name}).toList(),
      'episodes': episodes?.map((e) => e.toJson()).toList(),
    };
  }

  /// Get full thumbnail URL with CDN base
  String getFullThumbnailUrl() {
    if (thumbUrl == null || thumbUrl!.isEmpty) return '';
    const cdnBase = 'https://img.ophim.live/uploads/movies/';
    return '$cdnBase$thumbUrl';
  }

  /// Get full poster URL with CDN base
  String getFullPosterUrl() {
    if (posterUrl == null || posterUrl!.isEmpty) return '';
    const cdnBase = 'https://img.ophim.live/uploads/movies/';
    return '$cdnBase$posterUrl';
  }

  /// Check if has episodes (TV series)
  bool get hasEpisodes => episodes != null && episodes!.isNotEmpty;

  /// Get total episode count
  int get episodeCount {
    if (!hasEpisodes) return 0;
    return episodes!.fold(0, (total, server) => total + server.episodes.length);
  }
}

/// Episode Server Data
/// Represents a server with its episode list
class EpisodeServerData {
  const EpisodeServerData({required this.serverName, required this.episodes});

  factory EpisodeServerData.fromJson(Map<String, dynamic> json) {
    return EpisodeServerData(
      serverName: json['server_name'] as String? ?? '',
      episodes:
          (json['server_data'] as List<dynamic>?)
              ?.map((e) => EpisodeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String serverName;
  final List<EpisodeItem> episodes;

  Map<String, dynamic> toJson() {
    return {'server_name': serverName, 'server_data': episodes.map((e) => e.toJson()).toList()};
  }
}

/// Episode Item
/// Represents a single episode with its stream URL
class EpisodeItem {
  const EpisodeItem({required this.name, required this.slug, required this.linkM3u8});

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      linkM3u8: json['link_m3u8'] as String? ?? json['link_embed'] as String? ?? '',
    );
  }

  final String name;
  final String slug;
  final String linkM3u8;

  Map<String, dynamic> toJson() {
    return {'name': name, 'slug': slug, 'link_m3u8': linkM3u8};
  }
}
