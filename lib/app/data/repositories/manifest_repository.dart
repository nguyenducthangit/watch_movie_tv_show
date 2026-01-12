import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:watch_movie_tv_show/app/config/app_config.dart';
import 'package:watch_movie_tv_show/app/constants/app_assets.dart';
import 'package:watch_movie_tv_show/app/data/models/manifest.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/services/dio_client.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Video Repository
/// Handles fetching and caching of video catalog
class ManifestRepository {
  final _dio = DioClient.instance;
  final _storage = StorageService.instance;

  Manifest? _cachedManifest;

  /// Get manifest (from cache or remote)
  Future<Manifest> getManifest({bool forceRefresh = false}) async {
    // Return cached if available and not forcing refresh
    if (!forceRefresh && _cachedManifest != null) {
      return _cachedManifest!;
    }

    // Check local cache first
    if (!forceRefresh && _storage.isManifestCacheValid(AppConfig.manifestCacheExpiry)) {
      final cachedJson = _storage.getManifest();
      if (cachedJson != null) {
        try {
          _cachedManifest = Manifest.fromJson(jsonDecode(cachedJson));
          logger.i('Loaded manifest from cache');
          return _cachedManifest!;
        } catch (e) {
          logger.e('Failed to parse cached manifest: $e');
        }
      }
    }

    // Fetch from remote
    try {
      final manifest = await _fetchRemoteManifest();
      _cachedManifest = manifest;
      return manifest;
    } catch (e) {
      logger.e('Failed to fetch remote manifest: $e');

      // Fallback to cached data
      final cachedJson = _storage.getManifest();
      if (cachedJson != null) {
        _cachedManifest = Manifest.fromJson(jsonDecode(cachedJson));
        logger.i('Using stale cache as fallback');
        return _cachedManifest!;
      }

      // Fallback to mock data
      return _loadMockManifest();
    }
  }

  /// Fetch manifest from remote URL
  Future<Manifest> _fetchRemoteManifest() async {
    final response = await _dio.get<Map<String, dynamic>>(AppConfig.manifestUrl);

    final manifest = Manifest.fromJson(response.data!);

    // Cache the result
    await _storage.saveManifest(jsonEncode(response.data));
    logger.i('Fetched and cached manifest from remote');

    return manifest;
  }

  /// Load mock manifest from assets
  Future<Manifest> _loadMockManifest() async {
    try {
      final jsonString = await rootBundle.loadString(AppAssets.mockManifest);
      final manifest = Manifest.fromJson(jsonDecode(jsonString));
      _cachedManifest = manifest;
      logger.i('Loaded mock manifest from assets');
      return manifest;
    } catch (e) {
      logger.e('Failed to load mock manifest: $e');
      // Return empty manifest as last resort
      return Manifest(version: 1, updatedAt: DateTime.now(), items: []);
    }
  }

  /// Get video by ID
  Future<VideoItem?> getVideoById(String id) async {
    final manifest = await getManifest();
    return manifest.items.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('Video not found'),
    );
  }

  /// Search videos by title
  Future<List<VideoItem>> searchVideos(String query) async {
    final manifest = await getManifest();
    return manifest.searchByTitle(query);
  }

  /// Get videos by tag
  Future<List<VideoItem>> getVideosByTag(String tag) async {
    final manifest = await getManifest();
    return manifest.filterByTag(tag);
  }

  /// Get all tags
  Future<List<String>> getAllTags() async {
    final manifest = await getManifest();
    return manifest.allTags;
  }

  /// Refresh manifest
  Future<Manifest> refreshManifest() async {
    return getManifest(forceRefresh: true);
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _storage.clearManifestCache();
    _cachedManifest = null;
    logger.i('Manifest cache cleared');
  }
}
