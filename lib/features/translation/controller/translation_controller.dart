import 'package:exo_shared/exo_shared.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/services/translation/translate_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';
import 'package:watch_movie_tv_show/features/language/presentation/enums/language_enums.dart';

/// Translation Controller
/// Orchestrates movie content translation using TranslateService (Google ML Kit)
class TranslationController extends BaseController {
  TranslationController(this._translateService);

  final TranslateService _translateService;

  /// Translation state
  final RxBool isTranslating = false.obs;
  final RxString translationError = ''.obs;
  final RxMap<String, VideoItem> translatedMovies = <String, VideoItem>{}.obs;

  @override
  Future<void> initData() async {
    // Check and download model if needed
    await _translateService.downloadModelIfNeeded();
  }

  /// Translate a single movie
  /// Returns VideoItem with translated fields populated
  Future<VideoItem> translateMovie({
    required VideoItem movie,
    required LanguageCode targetLang,
  }) async {
    // If movie already has translations, return it
    if (movie.translatedTitle != null && movie.translatedDescription != null) {
      return movie;
    }

    try {
      final movieId = movie.id;

      // Ensure service is using correct language
      if (_translateService.targetLanguage != _getLanguageCode(targetLang)) {
        await _translateService.changeLanguage(_getLanguageCode(targetLang));
      }

      // Prepare texts to translate
      final textsToTranslate = <String>[
        movie.title,
        if (movie.description != null && movie.description!.isNotEmpty) movie.description!,
      ];

      // Translate batch
      final translations = await _translateService.translateBatch(textsToTranslate);

      final translatedTitle = translations[movie.title];
      final translatedDesc = movie.description != null ? translations[movie.description!] : null;

      // Return updated movie with translations
      final translated = movie.copyWith(
        translatedTitle: translatedTitle,
        translatedDescription: translatedDesc,
      );

      translatedMovies[movieId] = translated;
      return translated;
    } catch (e) {
      logger.e('Failed to translate movie ${movie.id}: $e');
      translationError.value = 'Translation failed';
      // Return original movie on error
      return movie;
    }
  }

  /// Translate a list of movies
  /// Uses batch processing for efficiency
  Future<List<VideoItem>> translateMovieList({
    required List<VideoItem> movies,
    required LanguageCode targetLang,
    int batchSize = 20,
  }) async {
    if (movies.isEmpty) return movies;

    isTranslating.value = true;
    translationError.value = '';

    try {
      final translatedList = <VideoItem>[];

      // Process in batches
      for (var i = 0; i < movies.length; i += batchSize) {
        final end = (i + batchSize < movies.length) ? i + batchSize : movies.length;
        final batch = movies.sublist(i, end);

        // Translate each movie in batch
        final batchResults = await Future.wait(
          batch.map((movie) => translateMovie(movie: movie, targetLang: targetLang)),
        );

        translatedList.addAll(batchResults);

        // Small delay between batches to avoid overwhelming the API
        if (end < movies.length) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      isTranslating.value = false;
      return translatedList;
    } catch (e) {
      logger.e('Failed to translate movie list: $e');
      translationError.value = 'Batch translation failed';
      isTranslating.value = false;
      // Return original movies on error
      return movies;
    }
  }

  /// Translate only visible movies (lazy loading)
  /// More efficient for large lists with scrolling
  Future<List<VideoItem>> translateVisibleMovies({
    required List<VideoItem> allMovies,
    required List<int> visibleIndices,
    required LanguageCode targetLang,
  }) async {
    final visibleMovies = visibleIndices.map((i) => allMovies[i]).toList();
    final translated = await translateMovieList(
      movies: visibleMovies,
      targetLang: targetLang,
      batchSize: 10, // Smaller batches for visible items
    );

    // Update the original list with translated versions
    final updatedList = List<VideoItem>.from(allMovies);
    for (var i = 0; i < visibleIndices.length; i++) {
      updatedList[visibleIndices[i]] = translated[i];
    }

    return updatedList;
  }

  /// Smart batch translation: Collect all unique texts and translate in one batch
  /// This is more efficient than translating each movie individually
  /// Used for pre-loading in splash screen
  Future<List<VideoItem>> translateMoviesSmartBatch({
    required List<VideoItem> movies,
    required LanguageCode targetLang,
  }) async {
    if (movies.isEmpty) return movies;

    isTranslating.value = true;
    translationError.value = '';

    try {
      // Ensure service is using correct language
      if (_translateService.targetLanguage != _getLanguageCode(targetLang)) {
        await _translateService.changeLanguage(_getLanguageCode(targetLang));
      }

      // Collect all unique texts from all movies
      final allTexts = <String>{};
      final movieTextMap = <VideoItem, List<String>>{};

      for (final movie in movies) {
        final texts = <String>[
          movie.title,
          if (movie.description != null && movie.description!.isNotEmpty) movie.description!,
          if (movie.tags != null) ...movie.tags!,
        ];
        movieTextMap[movie] = texts;
        allTexts.addAll(texts);
      }

      // Remove empty strings
      allTexts.removeWhere((text) => text.isEmpty);

      logger.i('Translating ${allTexts.length} unique texts for ${movies.length} movies');

      // Translate all unique texts in one batch
      final translations = await _translateService.translateBatch(allTexts.toList());

      // Map translations back to movies
      final translatedMovies = <VideoItem>[];
      for (final movie in movies) {
        final texts = movieTextMap[movie]!;
        String? translatedTitle;
        String? translatedDescription;
        List<String>? translatedTags;

        if (texts.isNotEmpty) {
          translatedTitle = translations[texts[0]] ?? movie.title;
          if (texts.length > 1 && movie.description != null) {
            translatedDescription = translations[texts[1]] ?? movie.description;
          }
          if (movie.tags != null && texts.length > (movie.description != null ? 2 : 1)) {
            final tagStartIndex = movie.description != null ? 2 : 1;
            translatedTags = movie.tags!
                .map((tag) => translations[tag] ?? tag)
                .toList();
          }
        }

        translatedMovies.add(
          movie.copyWith(
            translatedTitle: translatedTitle,
            translatedDescription: translatedDescription,
            translatedTags: translatedTags,
          ),
        );
      }

      isTranslating.value = false;
      logger.i('Smart batch translation completed for ${movies.length} movies');
      return translatedMovies;
    } catch (e) {
      logger.e('Failed to translate movies with smart batch: $e');
      translationError.value = 'Smart batch translation failed';
      isTranslating.value = false;
      // Return original movies on error
      return movies;
    }
  }

  /// Clear translation cache
  Future<void> clearCache() async {
    _translateService.clearCache();
    translatedMovies.clear();
  }

  /// Get cache statistics (dummy for now as TranslateService handles internal cache)
  Future<Map<String, int>> getCacheStats() async {
    return {};
  }

  /// Map LanguageCode to string
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
