import 'dart:ui';

import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Translation Service using Google ML Kit
/// Handles automatic translation of movie content to user's preferred language
class TranslateService extends GetxService {
  OnDeviceTranslator? _translator;
  String _currentTargetLanguage = 'en';
  final _translationCache = <String, String>{};
  bool _isInitialized = false;

  /// Initialize the service
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeTranslator();
  }

  /// Initialize translator based on current locale
  Future<void> _initializeTranslator() async {
    try {
      // Get current app locale
      final locale = Get.locale ?? PlatformDispatcher.instance.locale;
      _currentTargetLanguage = _getLanguageCode(locale.languageCode);

      logger.i('Initializing translator: vi → $_currentTargetLanguage');

      // If target language is Vietnamese, no translation needed
      if (_currentTargetLanguage == 'vi') {
        _isInitialized = true;
        logger.i('Target language is Vietnamese, skipping translator initialization');
        return;
      }

      // Create translator (Vietnamese to target language)
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.vietnamese,
        targetLanguage: _getTranslateLanguage(_currentTargetLanguage),
      );

      _isInitialized = true;
      logger.i('Translation service initialized successfully');
    } catch (e) {
      logger.e('Error initializing translation service: $e');
      _isInitialized = false;
    }
  }

  /// Translate a single text
  /// Returns original text if translation fails or target language is Vietnamese
  Future<String?> translateText(String? text) async {
    if (text == null || text.isEmpty) return text;

    // No translation needed if target is Vietnamese
    if (_currentTargetLanguage == 'vi') return text;

    // Check cache first
    if (_translationCache.containsKey(text)) {
      return _translationCache[text];
    }

    // Check if translator is initialized
    if (!_isInitialized || _translator == null) {
      logger.w('Translator not initialized, returning original text');
      return text;
    }

    try {
      final translated = await _translator!.translateText(text);

      // Cache the translation
      _translationCache[text] = translated;

      return translated;
    } catch (e) {
      logger.e('Translation error: $e');
      return text; // Fallback to original text
    }
  }

  /// Translate a batch of texts efficiently
  /// Returns map of original → translated text
  Future<Map<String, String>> translateBatch(List<String> texts) async {
    final results = <String, String>{};

    // No translation needed if target is Vietnamese
    if (_currentTargetLanguage == 'vi') {
      for (final text in texts) {
        results[text] = text;
      }
      return results;
    }

    if (!_isInitialized || _translator == null) {
      logger.w('Translator not initialized, returning original texts');
      for (final text in texts) {
        results[text] = text;
      }
      return results;
    }

    // Process each text
    for (final text in texts) {
      if (text.isEmpty) {
        results[text] = text;
        continue;
      }

      // Check cache
      if (_translationCache.containsKey(text)) {
        results[text] = _translationCache[text]!;
        continue;
      }

      // Translate
      try {
        final translated = await _translator!.translateText(text);
        _translationCache[text] = translated;
        results[text] = translated;
      } catch (e) {
        logger.e('Error translating "$text": $e');
        results[text] = text; // Fallback
      }
    }

    return results;
  }

  /// Get current target language code
  String get targetLanguage => _currentTargetLanguage;

  /// Check if translation is enabled (target language is not Vietnamese)
  bool get isTranslationEnabled => _currentTargetLanguage != 'vi';

  /// Change target language and reinitialize translator
  Future<void> changeLanguage(String languageCode) async {
    final newLanguageCode = _getLanguageCode(languageCode);

    if (newLanguageCode == _currentTargetLanguage) {
      return; // No change needed
    }

    logger.i('Changing translation language: $_currentTargetLanguage → $newLanguageCode');

    // Close current translator
    await _translator?.close();
    _translator = null;

    // Clear cache
    _translationCache.clear();

    // Update target language
    _currentTargetLanguage = newLanguageCode;

    // Reinitialize
    await _initializeTranslator();
  }

  /// Map language code to supported codes
  String _getLanguageCode(String code) {
    // Map common language codes to supported ones
    switch (code.toLowerCase()) {
      case 'en':
      case 'en_us':
      case 'en_gb':
        return 'en';
      case 'vi':
      case 'vi_vn':
        return 'vi';
      case 'zh':
      case 'zh_cn':
      case 'zh_tw':
        return 'zh';
      case 'ja':
      case 'ja_jp':
        return 'ja';
      case 'ko':
      case 'ko_kr':
        return 'ko';
      case 'th':
      case 'th_th':
        return 'th';
      default:
        // Default to English if unsupported
        logger.w('Unsupported language code: $code, defaulting to English');
        return 'en';
    }
  }

  /// Get TranslateLanguage enum from language code
  TranslateLanguage _getTranslateLanguage(String code) {
    switch (code) {
      case 'en':
        return TranslateLanguage.english;
      case 'zh':
        return TranslateLanguage.chinese;
      case 'ja':
        return TranslateLanguage.japanese;
      case 'ko':
        return TranslateLanguage.korean;
      case 'th':
        return TranslateLanguage.thai;
      case 'vi':
        return TranslateLanguage.vietnamese;
      default:
        return TranslateLanguage.english;
    }
  }

  /// Download language model if not available
  Future<bool> downloadModelIfNeeded() async {
    if (_translator == null || _currentTargetLanguage == 'vi') {
      return true;
    }

    try {
      final modelManager = OnDeviceTranslatorModelManager();

      // Check if model is downloaded
      final isDownloaded = await modelManager.isModelDownloaded(
        _getTranslateLanguage(_currentTargetLanguage).bcpCode,
      );

      if (!isDownloaded) {
        logger.i('Downloading translation model for $_currentTargetLanguage...');

        final success = await modelManager.downloadModel(
          _getTranslateLanguage(_currentTargetLanguage).bcpCode,
        );

        if (success) {
          logger.i('Model downloaded successfully');
        } else {
          logger.e('Failed to download model');
        }

        return success;
      }

      return true;
    } catch (e) {
      logger.e('Error downloading model: $e');
      return false;
    }
  }

  /// Clear translation cache
  void clearCache() {
    _translationCache.clear();
    logger.i('Translation cache cleared');
  }

  @override
  void onClose() {
    _translator?.close();
    _translationCache.clear();
    super.onClose();
  }
}
