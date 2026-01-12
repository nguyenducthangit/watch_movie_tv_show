import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';

/// Home Binding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
