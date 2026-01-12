import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/detail/controller/detail_controller.dart';

/// Detail Binding
class DetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DetailController());
  }
}
