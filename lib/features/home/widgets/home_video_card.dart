import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/utils/extensions.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';

/// Home Video Card Widget
/// Display video thumbnail with title and duration
class HomeVideoCard extends StatelessWidget {
  const HomeVideoCard({super.key, required this.video, this.isDownloaded = false, this.onTap});
  final VideoItem video;
  final bool isDownloaded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: CachedImageWidget(imageUrl: video.thumbnailUrl, fit: BoxFit.cover),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Duration badge
                if (video.durationSec != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video.durationSec!.toFormattedDuration(),
                        style: MTextTheme.smallTextMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                // Downloaded badge
                if (isDownloaded)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download_done_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                // Play button overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      splashColor: AppColors.primary.withValues(alpha: 0.3),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: MTextTheme.body2Medium.copyWith(color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Tags
                    if (video.tags != null && video.tags!.isNotEmpty)
                      Text(
                        video.tags!.take(2).join(' • '),
                        style: MTextTheme.smallTextRegular.copyWith(color: AppColors.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
