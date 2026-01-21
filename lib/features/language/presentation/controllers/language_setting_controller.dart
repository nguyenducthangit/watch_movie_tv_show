import 'package:get/get.dart';

import '../extensions/language_extensions.dart';
import 'language_controller.dart';

class LanguageSettingController extends LanguageController {
  LanguageSettingController(super.languageRepository, super.translateService);

  @override
  Future<void> initView() async {
    super.initView();
    curLang.value = languageRepository.getCurLangCode();
  }

  @override
  Future<void> onSubmit() async {
    super.onSubmit();
    Get.back(result: curLang.value?.langName.tr);
  }
}
