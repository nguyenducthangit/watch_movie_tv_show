import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/player/controller/player_controller.dart';

/// Player Binding
class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlayerController());
  }
}
