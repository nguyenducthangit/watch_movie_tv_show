import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';

/// Downloads Binding
class DownloadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DownloadsController());
  }
}
