import 'package:get/get.dart';

/// Main Navigation Controller
class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  /// Change tab index
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Navigate to home tab
  void goToHome() => changeTab(0);

  /// Navigate to downloads tab
  void goToDownloads() => changeTab(1);

  /// Navigate to watchlist tab
  void goToWatchlist() => changeTab(2);
}
