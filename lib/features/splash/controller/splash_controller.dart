import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/repositories/manifest_repository.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Splash Controller
/// Handles app initialization and navigation to main screen
class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString statusMessage = 'Initializing...'.obs;
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Initialize app services and data
  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize storage
      statusMessage.value = 'Loading storage...';
      progress.value = 0.2;
      await StorageService.instance.init();
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Load manifest (preload data)
      statusMessage.value = 'Loading content...';
      progress.value = 0.5;
      final repo = ManifestRepository();
      await repo.getManifest();
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Complete
      statusMessage.value = 'Ready!';
      progress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to main
      _navigateToMain();
    } catch (e) {
      logger.e('Splash initialization error: $e');
      statusMessage.value = 'Error loading app';
      isLoading.value = false;

      // Still navigate after delay
      await Future.delayed(const Duration(seconds: 2));
      _navigateToMain();
    }
  }

  /// Navigate to main navigation screen
  void _navigateToMain() {
    Get.offAllNamed(MRoutes.mainNav);
  }

  /// Retry initialization
  void retry() {
    isLoading.value = true;
    progress.value = 0.0;
    _initializeApp();
  }
}
