import 'package:get/get.dart';

import 'language_controller.dart';
import '../extensions/language_extensions.dart';

class LanguageSettingController extends LanguageController {
  LanguageSettingController(super.languageRepository);

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
