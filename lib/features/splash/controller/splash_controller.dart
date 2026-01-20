import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/repositories/ophim_repository.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

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
      final repo = OphimRepository();
      await repo.fetchHomeMovies();
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      logger.e('Splash initialization error: $e');
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

    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 10));
    onNextScreen();
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
