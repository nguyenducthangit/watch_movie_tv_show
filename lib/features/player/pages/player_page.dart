import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/widgets/error_state_widget.dart';
import 'package:watch_movie_tv_show/features/player/binding/player_binding.dart';
import 'package:watch_movie_tv_show/features/player/controller/player_controller.dart';
import 'package:watch_movie_tv_show/features/player/widgets/player_gesture_layer.dart';
import 'package:watch_movie_tv_show/features/player/widgets/player_selectors.dart';

/// Player Page
/// Enhanced with gesture controls, quality/speed selection
class PlayerPage extends GetView<PlayerController> {
  const PlayerPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const PlayerPage(),
    settings: settings,
    routeName: MRoutes.player,
    binding: PlayerBinding(),
    transition: Transition.fade,
    transitionDuration: const Duration(milliseconds: 200),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Error state
        if (controller.hasError.value) {
          return Stack(
            children: [
              Center(
                child: ErrorStateWidget(
                  title: 'Playback Error',
                  message: controller.errorMessage.value,
                  onRetry: controller.retry,
                ),
              ),
              // Close button
              SafeArea(
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }

        // Loading state
        if (!controller.isInitialized.value || controller.chewieController == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // Player
        return Stack(
          children: [
            // Chewie player
            Center(child: Chewie(controller: controller.chewieController!)),

            // Gesture layer for volume/brightness/seek
            PlayerGestureLayer(
              onSeekForward: controller.seekForward,
              onSeekBackward: controller.seekBackward,
              onTap: controller.toggleControls,
            ),

            // Custom top bar
            Positioned(top: 0, left: 0, right: 0, child: _TopBar(controller: controller)),

            // Custom bottom controls (quality/speed)
            Obx(() {
              if (!controller.showControls.value) return const SizedBox.shrink();
              return Positioned(
                bottom: 80, // Above Chewie controls
                left: 0,
                right: 0,
                child: _ExtraControls(controller: controller),
              );
            }),

            // Buffering indicator
            if (controller.isBuffering.value)
              const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
          ],
        );
      }),
    );
  }
}

/// Top bar with back button and title
class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                controller.video.title,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extra controls for quality and speed
class _ExtraControls extends StatelessWidget {
  const _ExtraControls({required this.controller});
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Playback speed
          Obx(
            () => _ControlButton(
              icon: Icons.speed_rounded,
              label: controller.playbackSpeed.value == 1.0
                  ? 'Speed'
                  : '${controller.playbackSpeed.value}x',
              onTap: () async {
                final speed = await SpeedSelector.show(
                  context,
                  currentSpeed: controller.playbackSpeed.value,
                );
                if (speed != null) {
                  controller.setPlaybackSpeed(speed);
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          // Quality
          Obx(
            () => _ControlButton(
              icon: Icons.hd_rounded,
              label: controller.currentQuality.value,
              onTap: () async {
                final quality = await QualitySelector.show(
                  context,
                  currentQuality: controller.currentQuality.value,
                );
                if (quality != null) {
                  controller.setQuality(quality);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual control button
class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: MTextTheme.captionMedium.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
