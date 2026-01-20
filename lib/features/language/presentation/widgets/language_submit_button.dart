import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';

import '../../../../app/utils/assets.gen.dart';
import '../controllers/language_controller.dart';

class LanguageSubmitButton<T extends LanguageController> extends GetView<T> {
  const LanguageSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.canShowSubmitButton.value) return const SizedBox();
      final isSelected = controller.curLang.value != null;
      if (!isSelected) return const SizedBox();
      return MButton(
        shape: BoxShape.circle,
        padding: const EdgeInsets.all(18),
        onPressed: controller.onSubmit,
        child: Assets.icons.icCheck.svg(
          height: 20,
          width: 20,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      );
    });
  }
}
