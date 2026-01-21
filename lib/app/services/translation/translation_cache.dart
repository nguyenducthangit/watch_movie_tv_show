import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Translation Cache using SharedPreferences
/// Caches translated content to minimize API calls and improve performance
class TranslationCache {
  TranslationCache._();

  static final TranslationCache instance = TranslationCache._();

  static const String _prefix = 'translation_cache_';
  static const int _maxCacheEntries = 1000;
  static const int _cacheDurationDays = 30;

  SharedPreferences? _prefs;

  /// Initialize cache
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _evictExpiredEntries();
  }

  /// Get cached translation
  /// Returns null if not found or expired
  Future<String?> get({
    required String movieId,
    required String fieldName,
    required String targetLang,
  }) async {
    if (_prefs == null) await init();

    final key = _buildKey(movieId, fieldName, targetLang);
    final cachedData = _prefs?.getString(key);

    if (cachedData == null) return null;

    try {
      // Check if expired (format: "timestamp|translatedText")
      final parts = cachedData.split('|');
      if (parts.length != 2) return null;

      final timestamp = int.tryParse(parts[0]);
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final age = now.difference(cacheTime).inDays;

      if (age > _cacheDurationDays) {
        // Expired, remove it
        await _prefs?.remove(key);
        return null;
      }

      return parts[1];
    } catch (e) {
      logger.e('Error reading cache for key $key: $e');
      return null;
    }
  }

  /// Set cached translation
  Future<void> set({
    required String movieId,
    required String fieldName,
    required String targetLang,
    required String translatedText,
  }) async {
    if (_prefs == null) await init();

    // Check cache size and evict if needed
    await _evictIfNeeded();

    final key = _buildKey(movieId, fieldName, targetLang);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final value = '$timestamp|$translatedText';

    await _prefs?.setString(key, value);
  }

  /// Clear all cached translations
  Future<void> clear() async {
    if (_prefs == null) await init();

    final keys = _prefs?.getKeys() ?? {};
    final cacheKeys = keys.where((k) => k.startsWith(_prefix));

    for (final key in cacheKeys) {
      await _prefs?.remove(key);
    }

    logger.i('Translation cache cleared');
  }

  /// Invalidate cache for specific movie (when source content changes)
  Future<void> invalidateMovie(String movieId) async {
    if (_prefs == null) await init();

    final keys = _prefs?.getKeys() ?? {};
    final movieKeys = keys.where((k) => k.startsWith('$_prefix$movieId:'));

    for (final key in movieKeys) {
      await _prefs?.remove(key);
    }
  }

  /// Build cache key: "translation_cache_{movieId}:{field}:{lang}"
  String _buildKey(String movieId, String fieldName, String targetLang) {
    return '$_prefix$movieId:$fieldName:$targetLang';
  }

  /// Evict expired entries
  Future<void> _evictExpiredEntries() async {
    if (_prefs == null) return;

    final keys = _prefs?.getKeys() ?? {};
    final cacheKeys = keys.where((k) => k.startsWith(_prefix));
    final now = DateTime.now();

    for (final key in cacheKeys) {
      final cachedData = _prefs?.getString(key);
      if (cachedData == null) continue;

      try {
        final parts = cachedData.split('|');
        if (parts.length != 2) continue;

        final timestamp = int.tryParse(parts[0]);
        if (timestamp == null) continue;

        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final age = now.difference(cacheTime).inDays;

        if (age > _cacheDurationDays) {
          await _prefs?.remove(key);
        }
      } catch (e) {
        logger.e('Error evicting expired entry $key: $e');
      }
    }
  }

  /// Evict least recently used entries if cache exceeds max size
  Future<void> _evictIfNeeded() async {
    if (_prefs == null) return;

    final keys = _prefs?.getKeys() ?? {};
    final cacheKeys = keys.where((k) => k.startsWith(_prefix)).toList();

    if (cacheKeys.length >= _maxCacheEntries) {
      // Sort by timestamp (oldest first)
      final keyTimestamps = <String, int>{};

      for (final key in cacheKeys) {
        final cachedData = _prefs?.getString(key);
        if (cachedData == null) continue;

        try {
          final parts = cachedData.split('|');
          if (parts.length != 2) continue;

          final timestamp = int.tryParse(parts[0]);
          if (timestamp != null) {
            keyTimestamps[key] = timestamp;
          }
        } catch (e) {
          // Skip invalid entries
        }
      }

      // Sort by timestamp and remove oldest 100 entries
      final sortedKeys = keyTimestamps.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

      final keysToRemove = sortedKeys.take(100).map((e) => e.key);

      for (final key in keysToRemove) {
        await _prefs?.remove(key);
      }

      logger.i('Evicted ${keysToRemove.length} old cache entries (LRU)');
    }
  }

  /// Get cache statistics
  Future<Map<String, int>> getStats() async {
    if (_prefs == null) await init();

    final keys = _prefs?.getKeys() ?? {};
    final cacheKeys = keys.where((k) => k.startsWith(_prefix));
    final now = DateTime.now();

    int validEntries = 0;
    int expiredEntries = 0;

    for (final key in cacheKeys) {
      final cachedData = _prefs?.getString(key);
      if (cachedData == null) continue;

      try {
        final parts = cachedData.split('|');
        if (parts.length != 2) continue;

        final timestamp = int.tryParse(parts[0]);
        if (timestamp == null) continue;

        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final age = now.difference(cacheTime).inDays;

        if (age > _cacheDurationDays) {
          expiredEntries++;
        } else {
          validEntries++;
        }
      } catch (e) {
        // Skip invalid entries
      }
    }

    return {'total': cacheKeys.length, 'valid': validEntries, 'expired': expiredEntries};
  }
}
