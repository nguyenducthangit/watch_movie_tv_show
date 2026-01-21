import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';

class DownloadAppBar extends StatelessWidget {
  const DownloadAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DownloadsController>();
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            // Left side - Title or Unselect All
            if (controller.isEditMode.value)
              TextButton(
                onPressed: controller.unselectAll,
                child: Text(
                  L.unselectAll,
                  style: MTextTheme.body2Medium.copyWith(color: AppColors.primary),
                ),
              )
            else
              Text(L.downloads, style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary)),
            const Spacer(),

            // Right side - Edit or Cancel
            if (controller.hasDownloads)
              if (controller.isEditMode.value)
                TextButton(
                  onPressed: controller.toggleEditMode,
                  child: Text(
                    L.cancel,
                    style: MTextTheme.body2Medium.copyWith(color: AppColors.textSecondary),
                  ),
                )
              else
                TextButton(
                  onPressed: controller.toggleEditMode,
                  child: Text(
                    L.edit,
                    style: MTextTheme.body2Medium.copyWith(color: AppColors.primary),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
