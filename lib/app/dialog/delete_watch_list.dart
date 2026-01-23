import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

class DeleteWatchList {
  static void show({
    required VideoItem video,
    required VoidCallback onRemove,
  }) {
    Get.dialog(
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:  Text(
          L.removeFromWatchlist.tr,
          style: MTextTheme.subTitle1Medium,
          textAlign: TextAlign.center,
        ),
        content: Text(
          '${L.remove.tr} "${video.title}" ${L.fromYourWatchList.tr}',
          style: MTextTheme.body1SemiBold.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(L.cancel.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onRemove();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(L.remove.tr),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
