import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/repositories/language_repository.dart';
import '../enums/language_enums.dart';

class LanguageController extends BaseController {
  LanguageController(this.languageRepository);
  final ILanguageRepository languageRepository;

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
    // final updatedLocale = Locale(langCode.name);
    // await Get.updateLocale(updatedLocale);
  }

  Future<void> onSubmit() async {
    if (curLang.value == null) return;
    final updatedLocale = Locale(curLang.value!.name);
    await Get.updateLocale(updatedLocale);
    languageRepository.setLanguage(curLang.value!);
  }
}
