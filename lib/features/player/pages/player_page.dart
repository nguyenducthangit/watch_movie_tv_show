import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/widgets/error_state_widget.dart';
import 'package:watch_movie_tv_show/features/player/binding/player_binding.dart';
import 'package:watch_movie_tv_show/features/player/controller/player_controller.dart';
import 'package:watch_movie_tv_show/features/player/widgets/player_gesture_layer.dart';
import 'package:watch_movie_tv_show/features/player/widgets/player_menu.dart';
import 'package:watch_movie_tv_show/features/player/widgets/subtitle_overlay.dart';

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
      backgroundColor: AppColors.black,
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
                      color: AppColors.black.withValues(alpha: 0.5),
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
            // Video player with controls overlay
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    // Chewie player
                    Chewie(controller: controller.chewieController!),

                    // Gesture layer for volume/brightness/seek
                    PlayerGestureLayer(
                      onSeekForward: controller.seekForward,
                      onSeekBackward: controller.seekBackward,
                      onTap: controller.toggleControls,
                    ),

                    // Subtitle overlay
                    SubtitleOverlay(controller: controller),

                    // Center controls (10s backward, play/pause, 10s forward)
                    Obx(() {
                      if (!controller.showControls.value) return const SizedBox.shrink();
                      return Center(child: _BottomControls(controller: controller));
                    }),

                    // Fullscreen button (bottom right)
                    Obx(() {
                      if (!controller.showControls.value) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 8,
                        right: 8,
                        child: _ControlIconButton(
                          icon: controller.isFullscreen.value
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          onTap: controller.toggleFullscreen,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Custom top bar (outside video area)
            Positioned(top: 0, left: 0, right: 0, child: _TopBar(controller: controller)),

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
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.5),
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
            const SizedBox(width: 16),
            // 3-dot menu
            PlayerMenu(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// Bottom controls with 10s seek buttons and fullscreen
class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.controller});
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Important: don't expand
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 10s backward
        _ControlIconButton(icon: Icons.replay_10_rounded, onTap: controller.seekBackward),
        const SizedBox(width: 24),
        // Play/Pause
        Obx(
          () => _ControlIconButton(
            icon: controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onTap: controller.togglePlayPause,
            size: 48,
          ),
        ),
        const SizedBox(width: 24),
        // 10s forward
        _ControlIconButton(icon: Icons.forward_10_rounded, onTap: controller.seekForward),
      ],
    );
  }
}

/// Control icon button
class _ControlIconButton extends StatelessWidget {
  const _ControlIconButton({required this.icon, required this.onTap, this.size = 36});

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size == 24 ? 6 : 4),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size == 48 ? 32 : 24),
      ),
    );
  }
}
