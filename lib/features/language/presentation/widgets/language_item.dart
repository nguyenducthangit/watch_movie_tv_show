import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';

import '../../../../app/config/theme/m_text_theme.dart';
import '../controllers/language_controller.dart';
import '../enums/language_enums.dart';
import '../extensions/language_extensions.dart';

class LanguageItem<T extends LanguageController> extends GetView<T> {
  const LanguageItem({super.key, required this.langCode});
  final LanguageCode langCode;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.curLang.value == langCode;
      return MButton(
        color: AppColors.white.withValues(alpha: 0.9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          width: 1.5,
        ),
        onPressed: () => controller.onChanged(langCode),
        child: Row(
          children: [
            Image.asset(langCode.flag, height: 28, width: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                langCode.langName.tr,
                style: MTextTheme.body1Regular.copyWith(color: AppColors.textBodyNight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }
}
