import 'package:dio/dio.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';
import 'package:watch_movie_tv_show/features/language/presentation/enums/language_enums.dart';

/// Translation Service using LibreTranslate API
/// Provides free translation for movie content (titles, descriptions)
class TranslationService {
  TranslationService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Public LibreTranslate instance - free and no API key required
  static const String _baseUrl = 'https://libretranslate.com';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;

  /// Translate a single text from Vietnamese to target language
  /// Returns original text if translation fails
  Future<String> translateText({
    required String text,
    required LanguageCode targetLang,
    String sourceLang = 'vi',
  }) async {
    if (text.isEmpty) return text;

    // Skip translation if target is same as source
    final targetCode = _getLanguageCode(targetLang);
    if (targetCode == sourceLang) return text;

    try {
      final targetCode = _getLanguageCode(targetLang);
      final result = await _translateWithRetry(text: text, source: sourceLang, target: targetCode);
      return result ?? text;
    } catch (e) {
      logger.e(
        'Translation failed for text: ${text.substring(0, text.length > 50 ? 50 : text.length)}... Error: $e',
      );
      return text; // Fallback to original
    }
  }

  /// Batch translate multiple texts (more efficient than individual calls)
  /// Returns map of original text → translated text
  Future<Map<String, String>> translateBatch({
    required List<String> texts,
    required LanguageCode targetLang,
    String sourceLang = 'vi',
  }) async {
    final results = <String, String>{};
    final targetCode = _getLanguageCode(targetLang);

    // Skip if same language
    if (targetCode == sourceLang) {
      for (final text in texts) {
        results[text] = text;
      }
      return results;
    }

    // LibreTranslate doesn't have batch API, so we'll do sequential calls
    // with small delay to avoid rate limiting
    for (final text in texts) {
      if (text.isEmpty) {
        results[text] = text;
        continue;
      }

      try {
        final translated = await _translateWithRetry(
          text: text,
          source: sourceLang,
          target: targetCode,
        );
        results[text] = translated ?? text;

        // Small delay to avoid rate limiting (100ms between requests)
        if (texts.indexOf(text) < texts.length - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        logger.e('Batch translation failed for text: $text. Error: $e');
        results[text] = text; // Fallback to original
      }
    }

    return results;
  }

  /// Internal method to translate with retry logic
  Future<String?> _translateWithRetry({
    required String text,
    required String source,
    required String target,
    int attempt = 1,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/translate',
        data: {'q': text, 'source': source, 'target': target, 'format': 'text'},
        options: Options(
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['translatedText'] as String?;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Translation API returned status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Retry with exponential backoff
      if (attempt < _maxRetries) {
        final delayMs = 1000 * attempt; // 1s, 2s, 3s
        logger.w('Translation attempt $attempt failed, retrying in ${delayMs}ms...');
        await Future.delayed(Duration(milliseconds: delayMs));
        return _translateWithRetry(
          text: text,
          source: source,
          target: target,
          attempt: attempt + 1,
        );
      } else {
        logger.e('Translation failed after $_maxRetries attempts: ${e.message}');
        rethrow;
      }
    }
  }

  /// Map LanguageCode enum to LibreTranslate language codes
  String _getLanguageCode(LanguageCode code) {
    switch (code) {
      case LanguageCode.en:
        return 'en';
      case LanguageCode.es:
        return 'es';
      case LanguageCode.hi:
        return 'hi';
      case LanguageCode.de:
        return 'de';
      case LanguageCode.fr:
        return 'fr';
      case LanguageCode.id:
        return 'id';
      case LanguageCode.pt:
        return 'pt';
    }
  }
}
