import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/services/translation/translate_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

import '../../domain/repositories/language_repository.dart';
import '../enums/language_enums.dart';

class LanguageController extends BaseController {
  LanguageController(this.languageRepository, this.translateService);
  final ILanguageRepository languageRepository;
  final TranslateService translateService;

  /// Current language
  final curLang = Rx<LanguageCode?>(null);
  final availableLangs = RxList<LanguageCode>([]);
  final canShowSubmitButton = false.obs;
  @override
  void onInit() {
    super.onInit();
    availableLangs.value = languageRepository.getAvailableLanguages();
  }

  @override
  Future<void> initData() async {}

  Future<void> onChanged(LanguageCode langCode) async {
    if (curLang.value == langCode) return;
    curLang.value = langCode;
    canShowSubmitButton.value = true; // Enable submit button
    // final updatedLocale = Locale(langCode.name);
    // await Get.updateLocale(updatedLocale);
  }

  Future<void> onSubmit() async {
    if (curLang.value == null) return;
    final updatedLocale = Locale(curLang.value!.name);
    await Get.updateLocale(updatedLocale);
    languageRepository.setLanguage(curLang.value!);

    // Update translation service language
    await translateService.changeLanguage(curLang.value!.name);

    // Trigger translation refresh for home controller if it exists
    try {
      if (Get.isRegistered<dynamic>(tag: 'HomeController')) {
        final homeController = Get.find(tag: 'HomeController');
        if (homeController != null) {
          await (homeController as dynamic).refreshTranslations(curLang.value!);
        }
      }
    } catch (e) {
      // Home controller not registered, that's fine
      logger.e('Could not trigger translation refresh: $e');
    }
  }
}
