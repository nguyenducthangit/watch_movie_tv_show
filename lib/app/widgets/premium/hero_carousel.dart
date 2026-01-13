import 'dart:async';

import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_animations.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_effects.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/animated_button.dart';

/// Hero Carousel Widget
/// Auto-rotating featured content carousel with parallax effects
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.videos,
    required this.onVideoTap,
    required this.onPlayTap,
    this.height = 340,
    this.autoRotateInterval = const Duration(seconds: 5),
  });

  final List<VideoItem> videos;
  final void Function(VideoItem video) onVideoTap;
  final void Function(VideoItem video) onPlayTap;
  final double height;
  final Duration autoRotateInterval;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  Timer? _autoRotateTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoRotate();
  }

  @override
  void dispose() {
    _autoRotateTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoRotate() {
    _autoRotateTimer?.cancel();
    _autoRotateTimer = Timer.periodic(widget.autoRotateInterval, (_) {
      if (!mounted || widget.videos.isEmpty) return;

      final nextIndex = (_currentIndex + 1) % widget.videos.length;
      _pageController.animateToPage(
        nextIndex,
        duration: AppAnimations.slow,
        curve: AppAnimations.defaultCurve,
      );
    });
  }

  void _resetAutoRotate() {
    _startAutoRotate(); // Reset timer on manual interaction
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Column(
      children: [
        // Hero PageView
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _resetAutoRotate();
            },
            itemCount: widget.videos.length,
            itemBuilder: (context, index) {
              return _HeroItem(
                video: widget.videos[index],
                onTap: () => widget.onVideoTap(widget.videos[index]),
                onPlayTap: () => widget.onPlayTap(widget.videos[index]),
              );
            },
          ),
        ),

        // Indicator dots
        const SizedBox(height: 16),
        _PageIndicators(
          count: widget.videos.length,
          currentIndex: _currentIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: AppAnimations.normal,
              curve: AppAnimations.defaultCurve,
            );
            _resetAutoRotate();
          },
        ),
      ],
    );
  }
}

/// Single Hero Item
class _HeroItem extends StatelessWidget {
  const _HeroItem({required this.video, required this.onTap, required this.onPlayTap});

  final VideoItem video;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Hero(
            tag: 'hero_${video.id}',
            child: CachedImageWidget(imageUrl: video.thumbnailUrl, fit: BoxFit.cover),
          ),

          // Gradient overlay
          Container(decoration: BoxDecoration(gradient: AppEffects.heroOverlay())),

          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                if (video.tags != null && video.tags!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.tags!.first.toUpperCase(),
                      style: MTextTheme.smallTextMedium.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                // Title
                Text(
                  video.title,
                  style: MTextTheme.h2Bold.copyWith(
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Description
                if (video.description != null)
                  Text(
                    video.description!,
                    style: MTextTheme.body2Regular.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    // Play button
                    PrimaryButton(
                      text: 'Play',
                      icon: Icons.play_arrow_rounded,
                      onPressed: onPlayTap,
                      height: 48,
                      width: 140,
                    ),
                    const SizedBox(width: 12),

                    // More info
                    AnimatedIconButton(
                      icon: Icons.info_outline_rounded,
                      onPressed: onTap,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      iconColor: Colors.white,
                      tooltip: 'More Info',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Page Indicator Dots
class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.count, required this.currentIndex, required this.onTap});

  final int count;
  final int currentIndex;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
