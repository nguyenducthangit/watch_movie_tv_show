import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/dialog/delete_watch_list.dart';
import 'package:watch_movie_tv_show/app/utils/tag_mapper.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';

class WatchlistCard extends StatelessWidget {
  const WatchlistCard({
    super.key,
    required this.video,
    required this.onTap,
    required this.onRemove,
  });
  final VideoItem video;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.card),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            DeleteWatchList.show(video: video, onRemove: onRemove);
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedImageWidget(imageUrl: video.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (video.tags != null && video.tags!.isNotEmpty)
                      Text(
                        // Import TagMapper if needed, assuming it's available or need import
                        TagMapper.getTranslatedTag(video.tags!.first),
                        style: MTextTheme.captionMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      video.displayTitle,
                      style: MTextTheme.body1Medium.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (video.displayDescription != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        video.displayDescription!,
                        style: MTextTheme.captionRegular.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
