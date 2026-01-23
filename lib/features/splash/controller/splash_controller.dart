import 'package:exo_shared/exo_shared.dart' hide SharedPrefService;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/repositories/ophim_repository.dart';
import 'package:watch_movie_tv_show/app/services/preload_service.dart';
import 'package:watch_movie_tv_show/app/services/shared_pref_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';
import 'package:watch_movie_tv_show/features/language/presentation/enums/language_enums.dart';
import 'package:watch_movie_tv_show/features/translation/controller/translation_controller.dart';

class SplashController extends BaseController {
  final progress = 0.0.obs;
  final self = 0.0.obs;
  late final AnimationController _progressAnimationController;
  late final Animation<double> _progressAnimation;
  late final AnimationController _selfAnimationController;
  late final Animation<double> _selfAnimation;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await StorageService.instance.init();
      await Future.delayed(const Duration(milliseconds: 300));

      // Start preloading movies and translations in background
      _preloadMoviesAndTranslate();
    } catch (e) {
      logger.e('Splash initialization error: $e');
    }
  }

  /// Preload movies and translate in background
  Future<void> _preloadMoviesAndTranslate() async {
    try {
      final preloadService = Get.find<PreloadService>();
      preloadService.startPreloading();

      logger.i('Starting preload: Loading initial movies (5 per country) from API...');
      final repo = OphimRepository();
      final movies = await repo.fetchInitialMovies();

      logger.i('Preload: Loaded ${movies.length} initial movies, starting translation...');

      // Get current language or default to English
      final savedLang = SharedPrefService.getLang();
      LanguageCode targetLang = LanguageCode.en; // Default to English

      if (savedLang != null) {
        try {
          targetLang = LanguageCode.values.firstWhere(
            (code) => code.name == savedLang,
            orElse: () => LanguageCode.en,
          );
        } catch (e) {
          logger.w('Could not parse language code: $savedLang, using English');
        }
      }

      // Translate movies using smart batch translation
      TranslationController? translationController;
      try {
        translationController = Get.find<TranslationController>();
      } catch (e) {
        logger.w('TranslationController not available, skipping translation');
        preloadService.setPreloadedMovies(movies, isComplete: true);
        return;
      }

      final translatedMovies = await translationController.translateMoviesSmartBatch(
        movies: movies,
        targetLang: targetLang,
      );

      logger.i('Preload: Translation completed, saving to PreloadService');
      preloadService.setPreloadedMovies(translatedMovies, isComplete: true);
      logger.i('Preload: Completed successfully');
    } catch (e) {
      logger.e('Preload error: $e');
      // Even if translation fails, save the movies without translation
      try {
        final repo = OphimRepository();
        final movies = await repo.fetchInitialMovies();
        final preloadService = Get.find<PreloadService>();
        preloadService.setPreloadedMovies(movies, isComplete: false);
      } catch (e2) {
        logger.e('Failed to save movies after preload error: $e2');
      }
    }
  }

  /// Retry initialization
  void retry() {
    progress.value = 0.0;
    _initializeApp();
  }

  @override
  Future<void> initData() async {
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: MTickerProvider(),
      lowerBound: 0,
      upperBound: 1,
    );
    _progressAnimationController.addListener(progressAnimationListener);
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOutQuad));
    _progressAnimationController.forward();

    _selfAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: MTickerProvider(),
    );
    _selfAnimationController.addListener(selfAnimationListener);
    _selfAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _selfAnimationController, curve: Curves.linear));
    _selfAnimationController.repeat(reverse: true);

    // Wait for preload to complete with timeout
    // Minimum 2 seconds for smooth animation, maximum 8 seconds total
    await _waitForPreloadWithTimeout();
    onNextScreen();
  }

  /// Wait for preload to complete with timeout
  /// Minimum 2 seconds for smooth UX, maximum 8 seconds total
  Future<void> _waitForPreloadWithTimeout() async {
    final preloadService = Get.find<PreloadService>();
    const minWaitTime = Duration(seconds: 2);
    const maxWaitTime = Duration(seconds: 8);
    final startTime = DateTime.now();

    // Wait minimum time for smooth animation
    await Future.delayed(minWaitTime);

    // Check if preload is already complete
    if (preloadService.isPreloadComplete) {
      logger.i('Preload completed quickly, navigating immediately');
      return;
    }

    // Wait for preload with remaining time as timeout
    final elapsed = DateTime.now().difference(startTime);
    final remainingTime = maxWaitTime - elapsed;
    
    if (remainingTime.isNegative || remainingTime.inMilliseconds <= 0) {
      logger.w('Preload timeout, navigating anyway');
      return;
    }

    logger.i('Waiting for preload to complete (max ${remainingTime.inSeconds}s)...');
    
    // Poll every 200ms until preload complete or timeout
    final endTime = DateTime.now().add(remainingTime);
    while (DateTime.now().isBefore(endTime)) {
      if (preloadService.isPreloadComplete) {
        logger.i('Preload completed, navigating now');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }

    logger.w('Preload timeout after ${maxWaitTime.inSeconds}s, navigating anyway');
  }

  void progressAnimationListener() {
    progress.value = _progressAnimation.value;
  }

  void selfAnimationListener() {
    self.value = _selfAnimation.value;
  }

  void resetAnimation() {
    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.stop();
    _progressAnimationController.removeListener(progressAnimationListener);
    _progressAnimationController.dispose();
    _selfAnimationController.stop();
    _selfAnimationController.removeListener(selfAnimationListener);
    _selfAnimationController.dispose();
    super.dispose();
  }

  Future<void> onNextScreen() async {
    Get.offAllNamed(MRoutes.languageFirstOpen);
  }
}
