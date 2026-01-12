import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';
import 'package:watch_movie_tv_show/features/main_nav/controller/main_nav_controller.dart';
import 'package:watch_movie_tv_show/features/settings/controller/settings_controller.dart';

/// Main Navigation Binding
class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => DownloadsController());
    Get.lazyPut(() => SettingsController());
  }
}
