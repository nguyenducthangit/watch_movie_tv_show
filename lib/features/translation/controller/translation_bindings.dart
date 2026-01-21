import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/services/translation/translate_service.dart';
import 'package:watch_movie_tv_show/app/services/translation/translation_cache.dart';
import 'package:watch_movie_tv_show/app/services/translation/translation_service.dart';
import 'package:watch_movie_tv_show/features/translation/controller/translation_controller.dart';

/// Translation Bindings
/// Dependency injection for TranslationController
class TranslationBindings extends Bindings {
  @override
  void dependencies() {
    // Register TranslateService (Google ML Kit) as permanent singleton
    Get.put(TranslateService(), permanent: true);

    // Lazy instantiation of translation services
    Get.lazyPut(() => TranslationService());
    Get.lazyPut(() => TranslationCache.instance);
    Get.lazyPut(() => TranslationController(Get.find<TranslateService>()));
  }
}
