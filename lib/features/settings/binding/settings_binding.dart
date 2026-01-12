import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/settings/controller/settings_controller.dart';

/// Settings Binding
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}
