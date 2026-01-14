import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:subtitle/subtitle.dart';
import 'package:translator/translator.dart';
import 'package:watch_movie_tv_show/app/data/models/subtitle_data.dart';
import 'package:watch_movie_tv_show/app/data/models/subtitle_entry.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Subtitle Service
/// Handles fetching, parsing, and translating subtitles
class SubtitleService extends GetxService {
  static SubtitleService get to => Get.find<SubtitleService>();

  final Dio _dio = Dio();
  final GoogleTranslator _translator = GoogleTranslator();

  // Cache for translated subtitles (key: url_language)
  final Map<String, SubtitleData> _cache = {};

  /// Fetch subtitle file from URL
  Future<String> fetchSubtitle(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data as String;
    } catch (e) {
      logger.e('Failed to fetch subtitle: $e');
      rethrow;
    }
  }

  /// Parse subtitle content (auto-detects SRT or VTT)
  SubtitleData parseSubtitle(String content, String language) {
    try {
      // Use subtitle package to parse
      final controller = SubtitleController(
        provider: SubtitleProvider.fromString(
          data: content,
          type: SubtitleType.srt, // Default to SRT, package auto-detects
        ),
      );

      // Convert to our model
      final entries = controller.subtitles.map((subtitle) {
        return SubtitleEntry(startTime: subtitle.start, endTime: subtitle.end, text: subtitle.data);
      }).toList();

      logger.i('Parsed ${entries.length} subtitle entries');
      return SubtitleData(language: language, entries: entries);
    } catch (e) {
      logger.e('Failed to parse subtitle: $e');
      rethrow;
    }
  }

  /// Load subtitle from URL
  Future<SubtitleData> loadSubtitle(String url, String language) async {
    // Check cache
    final cacheKey = '${url}_$language';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final content = await fetchSubtitle(url);
    final subtitleData = parseSubtitle(content, language);

    // Cache it
    _cache[cacheKey] = subtitleData;
    return subtitleData;
  }

  /// Translate entire subtitle to target language
  Future<SubtitleData> translateSubtitle(SubtitleData data, String targetLanguage) async {
    // Check cache
    final cacheKey = '${data.language}_$targetLanguage';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      logger.i('Translating ${data.entries.length} entries to $targetLanguage...');

      // Translate entries in batches to avoid API limits
      const batchSize = 10;
      final translatedEntries = <SubtitleEntry>[];

      for (int i = 0; i < data.entries.length; i += batchSize) {
        final end = (i + batchSize < data.entries.length) ? i + batchSize : data.entries.length;
        final batch = data.entries.sublist(i, end);

        // Translate batch
        for (final entry in batch) {
          try {
            final translation = await _translator.translate(
              entry.text,
              from: data.language == 'auto' ? 'auto' : data.language,
              to: targetLanguage,
            );

            translatedEntries.add(entry.copyWith(translatedText: translation.text));
          } catch (e) {
            logger.w('Failed to translate entry: ${entry.text}. Error: $e');
            // Keep original text if translation fails
            translatedEntries.add(entry);
          }
        }

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final translatedData = SubtitleData(
        language: data.language,
        entries: translatedEntries,
        translatedLanguage: targetLanguage,
      );

      // Cache it
      _cache[cacheKey] = translatedData;
      logger.i('Translation complete!');

      return translatedData;
    } catch (e) {
      logger.e('Failed to translate subtitle: $e');
      return data; // Return original if translation fails
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }
}
