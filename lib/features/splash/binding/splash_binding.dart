import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/splash/controller/splash_controller.dart';

/// Splash Binding
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}
