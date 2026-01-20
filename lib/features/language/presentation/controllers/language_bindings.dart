import 'package:get/get.dart';

import '../../data/repositories/language_repository_impl.dart';
import '../../domain/repositories/language_repository.dart';
import 'language_first_open_controller.dart';
import 'language_setting_controller.dart';

class LanguageFirstOpenBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ILanguageRepository>(() => LanguageRepositoryImpl());
    Get.lazyPut(() => LanguageFirstOpenController(Get.find<ILanguageRepository>()));
  }
}

class LanguageSettingBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ILanguageRepository>(() => LanguageRepositoryImpl());
    Get.lazyPut(() => LanguageSettingController(Get.find<ILanguageRepository>()));
  }
}
