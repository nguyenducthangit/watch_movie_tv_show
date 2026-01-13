import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/fade_in_widget.dart';

/// Category Row Widget
/// Horizontal scrollable row of videos with title header
class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.title,
    required this.videos,
    required this.onVideoTap,
    this.onSeeAllTap,
    this.itemWidth = 140,
    this.itemHeight = 210,
    this.showSeeAll = true,
    this.animate = true,
  });

  final String title;
  final List<VideoItem> videos;
  final void Function(VideoItem video) onVideoTap;
  final VoidCallback? onSeeAllTap;
  final double itemWidth;
  final double itemHeight;
  final bool showSeeAll;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: MTextTheme.h4SemiBold.copyWith(color: AppColors.textPrimary)),
              if (showSeeAll && onSeeAllTap != null)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: MTextTheme.body2Medium.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal video list
        SizedBox(
          height: itemHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              final card = _CategoryVideoCard(
                video: video,
                width: itemWidth,
                onTap: () => onVideoTap(video),
              );

              if (animate) {
                return StaggeredItem(
                  index: index,
                  staggerDelay: const Duration(milliseconds: 30),
                  child: card,
                );
              }
              return card;
            },
          ),
        ),
      ],
    );
  }
}

/// Single video card in category row
class _CategoryVideoCard extends StatelessWidget {
  const _CategoryVideoCard({required this.video, required this.width, required this.onTap});

  final VideoItem video;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedImageWidget(imageUrl: video.thumbnailUrl, fit: BoxFit.cover),
                    // Gradient overlay at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                          ),
                        ),
                      ),
                    ),
                    // Play icon on hover/tap area
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onTap,
                          splashColor: AppColors.primary.withValues(alpha: 0.3),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              video.title,
              style: MTextTheme.captionMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Large Category Row - for featured sections
class LargeCategoryRow extends StatelessWidget {
  const LargeCategoryRow({
    super.key,
    required this.title,
    required this.videos,
    required this.onVideoTap,
    this.onSeeAllTap,
  });

  final String title;
  final List<VideoItem> videos;
  final void Function(VideoItem video) onVideoTap;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return CategoryRow(
      title: title,
      videos: videos,
      onVideoTap: onVideoTap,
      onSeeAllTap: onSeeAllTap,
      itemWidth: 200,
      itemHeight: 280,
    );
  }
}
