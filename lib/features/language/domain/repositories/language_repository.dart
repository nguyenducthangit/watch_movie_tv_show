import '../../presentation/enums/language_enums.dart';

abstract class ILanguageRepository {
  LanguageCode? curLangCode;
  void setLanguage(LanguageCode langCode);
  LanguageCode getCurLangCode();
  List<LanguageCode> getAvailableLanguages();
}
