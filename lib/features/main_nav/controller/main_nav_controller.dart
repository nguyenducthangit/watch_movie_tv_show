import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';

/// Main Navigation Controller
class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs;
  void changeTab(int index) {
    if (index == 0 && currentIndex.value == 0) {
      try {
        final homeController = Get.find<HomeController>();
        homeController.resetToHome();
      } catch (e) {
        // HomeController not found, ignore
      }
    }
    currentIndex.value = index;
  }

  /// Navigate to home tab
  void goToHome() => changeTab(0);

  /// Navigate to downloads tab
  void goToDownloads() => changeTab(1);

  /// Navigate to watchlist tab
  void goToWatchlist() => changeTab(2);
}
