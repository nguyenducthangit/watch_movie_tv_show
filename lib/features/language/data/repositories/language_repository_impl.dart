import 'package:get/get.dart';

import '../../../../app/services/shared_pref_service.dart';
import '../../domain/repositories/language_repository.dart';
import '../../presentation/constants/language_constants.dart';
import '../../presentation/enums/language_enums.dart';

class LanguageRepositoryImpl extends GetxService implements ILanguageRepository {
  LanguageRepositoryImpl();

  @override
  LanguageCode? curLangCode;

  @override
  LanguageCode getCurLangCode() {
    if (curLangCode != null) return curLangCode!;
    final curLang = SharedPrefService.getLang();
    curLangCode = LanguageCode.values.firstWhere(
      (element) => element.name == curLang,
      orElse: () => LanguageConstant.defaultLang,
    );
    return curLangCode!;
  }

  @override
  void setLanguage(LanguageCode langCode) {
    SharedPrefService.setLang(langCode.name);
    curLangCode = langCode;
  }

  @override
  List<LanguageCode> getAvailableLanguages() {
    return LanguageCode.values;
  }
}
