import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/features/player/controller/player_controller.dart';

/// Subtitle Overlay Widget
/// Displays subtitles at the bottom of the video player
class SubtitleOverlay extends StatelessWidget {
  const SubtitleOverlay({super.key, required this.controller});

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // If subtitle disabled, don't show anything
      if (!controller.subtitleEnabled.value) {
        return const SizedBox.shrink();
      }

      // If no subtitle loaded at all
      if (controller.currentSubtitle.value == null) {
        return Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'No subtitle file found for this video',
                style: MTextTheme.captionMedium.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      // If subtitle loaded but no entry at current position, don't show anything
      if (controller.currentSubtitleEntry.value == null) {
        return const SizedBox.shrink();
      }

      // Show subtitle text
      final entry = controller.currentSubtitleEntry.value!;

      return Positioned(
        bottom: 100, // Above controls
        left: 20,
        right: 20,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.displayText,
              style: MTextTheme.body1Medium.copyWith(color: Colors.white, height: 1.4),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    });
  }
}
