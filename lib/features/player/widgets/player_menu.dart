import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/features/player/controller/player_controller.dart';

/// Player 3-Dot Menu
/// Contains Speed and Quality options
class PlayerMenu extends StatelessWidget {
  const PlayerMenu({super.key, required this.controller});

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
      onPressed: () => _showPlayerMenu(context),
    );
  }

  /// Show player menu as bottom sheet
  void _showPlayerMenu(BuildContext context) {
    Get.bottomSheet(
      clipBehavior: Clip.antiAlias,
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Speed option
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.speed_rounded, color: AppColors.primary),
                    title: Text(L.playbackSpeed.tr),
                    trailing: Text(
                      controller.playbackSpeed.value == 1.0
                          ? L.normal.tr
                          : '${controller.playbackSpeed.value} ${L.x.tr}',
                      style: MTextTheme.body2Regular.copyWith(color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      Get.back();
                      _showSpeedPicker(context);
                    },
                  ),
                ),

                // Quality option
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.hd_rounded, color: AppColors.primary),
                    title: Text(L.quality.tr),
                    trailing: Text(
                      controller.currentQuality.value,
                      style: MTextTheme.body2Regular.copyWith(color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      Get.back();
                      _showQualityPicker(context);
                    },
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  /// Show speed picker
  void _showSpeedPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(L.playbackSpeed.tr, style: MTextTheme.h4SemiBold),
                const SizedBox(height: 16),
                ...PlayerController.availableSpeeds.map((speed) {
                  return Obx(
                    () => ListTile(
                      title: Text('${speed}x', textAlign: TextAlign.center),
                      trailing: controller.playbackSpeed.value == speed
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        controller.setPlaybackSpeed(speed);
                        Get.back();
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  /// Show quality picker
  void _showQualityPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(L.videoQuality.tr, style: MTextTheme.h4SemiBold),
                const SizedBox(height: 16),
                ...PlayerController.availableQualities.map((quality) {
                  return Obx(
                    () => ListTile(
                      title: Text(quality, textAlign: TextAlign.center),
                      trailing: controller.currentQuality.value == quality
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        controller.setQuality(quality);
                        Get.back();
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
