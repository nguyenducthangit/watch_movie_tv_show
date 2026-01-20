import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'lang/en_lang.dart';
import 'lang/es_lang.dart';
import 'lang/hi_lang.dart';
import 'lang/de_lang.dart';
import 'lang/fr_lang.dart';
import 'lang/id_lang.dart';
import 'lang/pt_lang.dart';

class MTranslations extends Translations {
  static const fallbackLocale = Locale('en');
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('de'),
    Locale('fr'),
    Locale('id'),
    Locale('pt'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    enCode: enLang,
    esCode: esLang,
    hiCode: hiLang,
    deCode: deLang,
    frCode: frLang,
    idCode: idLang,
    ptCode: ptLang,
  };
}
