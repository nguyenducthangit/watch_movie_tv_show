import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/language_controller.dart';
import 'language_item.dart';

class LanguageList<T extends LanguageController> extends GetView<T> {
  const LanguageList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final listLang = controller.availableLangs;
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        itemBuilder: (context, index) {
          final lang = listLang[index];
          return LanguageItem<T>(key: Key('${index}_${lang.name}'), langCode: lang);
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemCount: listLang.length,
      );
    });
  }
}
