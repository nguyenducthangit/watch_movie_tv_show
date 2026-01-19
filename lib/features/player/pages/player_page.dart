import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/widgets/error_state_widget.dart';
import 'package:watch_movie_tv_show/features/player/binding/player_binding.dart';
import 'package:watch_movie_tv_show/features/player/controller/player_controller.dart';
import 'package:watch_movie_tv_show/features/player/widgets/player_menu.dart';

/// Player Page - HLS Video Player with info below
class PlayerPage extends GetView<PlayerController> {
  const PlayerPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const PlayerPage(),
    settings: settings,
    routeName: MRoutes.player,
    binding: PlayerBinding(),
    transition: Transition.downToUp,
    transitionDuration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    return _DismissiblePlayerWrapper(
      onDismiss: () => Get.back(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(() {
            // Error state
            if (controller.hasError.value) {
              return _buildErrorState();
            }

            // Loading state
            if (!controller.isInitialized.value || controller.chewieController == null) {
              return _buildLoadingState();
            }

            // Main player layout
            return Column(
              children: [
                // Video player section
                _buildVideoPlayer(),

                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: Get.height),
                      child: Container(
                        color: const Color(0xFF212936),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Action buttons row
                            _buildActionButtons(),

                            const Divider(color: AppColors.textBody, height: 1),

                            // About section
                            _buildAboutSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Stack(
      children: [
        Center(
          child: ErrorStateWidget(
            title: 'Playback Error',
            message: controller.errorMessage.value,
            onRetry: controller.retry,
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Placeholder for video area
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: AppColors.black,
            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Chewie(controller: controller.chewieController!),

          // PlayerGestureLayer(
          //   onSeekForward: controller.seekForward,
          //   onSeekBackward: controller.seekBackward,
          //   onTap: controller.toggleControls,
          // ),
          Obx(() {
            if (!controller.showControls.value) return const SizedBox.shrink();
            return _buildTopBar();
          }),

          // Obx(() {
          //   if (!controller.showControls.value) return const SizedBox.shrink();
          //   return const _CenterControls();
          // }),
          Obx(() {
            if (!controller.showControls.value) return const SizedBox.shrink();
            return Positioned(left: 0, right: 0, bottom: 0, child: _buildProgressBar());
          }),

          Obx(() {
            if (!controller.isBuffering.value) return const SizedBox.shrink();
            return const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          // Dismiss button (down arrow)
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
          ),
          // Title
          Expanded(
            child: Text(
              controller.video.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 3-dot menu
          PlayerMenu(controller: controller),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [AppColors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Obx(() {
        final current = controller.currentPosition.value;
        final total = controller.totalDuration.value;
        final progress = total.inMilliseconds > 0
            ? current.inMilliseconds / total.inMilliseconds
            : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatDuration(current)} / ${_formatDuration(total)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                // Fullscreen button
                GestureDetector(
                  onTap: controller.toggleFullscreen,
                  child: Obx(
                    () => Icon(
                      controller.isFullscreen.value
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress slider
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * total.inMilliseconds).round(),
                  );
                  controller.videoPlayerController?.seekTo(newPosition);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Download button
          _ActionButton(
            icon: Icons.download_outlined,
            label: 'Download',
            onTap: () {
              Get.snackbar('Download', 'Download feature coming soon');
            },
          ),
          const SizedBox(width: 32),
          // Share button
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              final movieInfo = 'Check out this movie: ${controller.video.title}';
              SharePlus.instance.share(ShareParams(text: movieInfo));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "About" label
          const Text(
            'About',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Video title
          Text(
            controller.video.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            controller.video.description ?? 'No description available.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          // Tags
          if (controller.video.tags != null && controller.video.tags!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.video.tags!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// /// Center controls - Play/Pause with seek buttons
// class _CenterControls extends GetView<PlayerController> {
//   const _CenterControls();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Seek backward 10s
//           _ControlButton(icon: Icons.replay_10_rounded, onTap: controller.seekBackward),
//           const SizedBox(width: 32),
//           // Play/Pause
//           Obx(
//             () => _ControlButton(
//               icon: controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
//               onTap: controller.togglePlayPause,
//               size: 56,
//             ),
//           ),
//           const SizedBox(width: 32),
//           // Seek forward 10s
//           _ControlButton(icon: Icons.forward_10_rounded, onTap: controller.seekForward),
//         ],
//       ),
//     );
//   }
// }

/// Action button (Download, Share)
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Control button widget
class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onTap, this.size = 40});

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size == 56 ? 8 : 6),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size == 56 ? 40 : 28),
      ),
    );
  }
}

/// Wrapper that allows dismissing the player by dragging down
class _DismissiblePlayerWrapper extends StatefulWidget {
  const _DismissiblePlayerWrapper({required this.child, required this.onDismiss});

  final Widget child;
  final VoidCallback onDismiss;

  @override
  State<_DismissiblePlayerWrapper> createState() => _DismissiblePlayerWrapperState();
}

class _DismissiblePlayerWrapperState extends State<_DismissiblePlayerWrapper> {
  double _dragOffset = 0;
  bool _isDragging = false;

  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragOffset = 0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += details.delta.dy;
      // Only allow dragging down
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;
    final screenHeight = MediaQuery.of(context).size.height;

    // If dragged more than half screen, dismiss
    if (_dragOffset > screenHeight * 0.3) {
      widget.onDismiss();
    } else {
      // Animate back to original position
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        child: widget.child,
      ),
    );
  }
}
