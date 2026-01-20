import 'package:get/get.dart';
import '../settings.dart';

class SettingsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingsRepository>(SettingsRepository());
    Get.put<SettingsController>(SettingsController(repository: Get.find<SettingsRepository>()));
  }
}
