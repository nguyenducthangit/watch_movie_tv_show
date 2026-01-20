import '../enums/language_enums.dart';
import '../constants/language_constants.dart';

extension LanguageCodeExtension on LanguageCode {
  String get langName {
    return LanguageConstant.mapCodeToName[this] ?? '';
  }

  String get flag {
    return LanguageConstant.mapCodeToFlag[this] ?? '';
  }
}
