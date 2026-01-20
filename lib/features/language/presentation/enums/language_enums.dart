enum LanguageCode {
  hi,
  de,
  fr,
  id,
  pt,
  en,
  es;

  static LanguageCode? fromLocale(String? locale) {
    final index = values.indexWhere((element) => locale?.contains(element.name) == true);
    if (index == -1) return null;
    return values[index];
  }
}
