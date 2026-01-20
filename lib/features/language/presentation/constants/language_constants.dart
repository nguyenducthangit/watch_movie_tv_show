import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/assets.gen.dart';

import '../enums/language_enums.dart';

class LanguageConstant {
  static const defaultLang = LanguageCode.en;

  static const Map<LanguageCode, String> mapCodeToName = {
    LanguageCode.en: L.langEN,
    LanguageCode.es: L.langES,
    LanguageCode.hi: L.langHI,
    LanguageCode.de: L.langDE,
    LanguageCode.fr: L.langFR,
    LanguageCode.id: L.langID,
    LanguageCode.pt: L.langPT,
  };

  static final Map<LanguageCode, String> mapCodeToFlag = {
    LanguageCode.en: Assets.icons.icFlags.en.path,
    LanguageCode.es: Assets.icons.icFlags.es.path,
    LanguageCode.hi: Assets.icons.icFlags.hi.path,
    LanguageCode.de: Assets.icons.icFlags.de.path,
    LanguageCode.fr: Assets.icons.icFlags.fr.path,
    LanguageCode.id: Assets.icons.icFlags.id.path,
    LanguageCode.pt: Assets.icons.icFlags.pt.path,
  };
}
