import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';

class DownloadActiveItem extends StatelessWidget {
  const DownloadActiveItem({
    super.key,
    required this.task,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });
  final DownloadTask task;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 48,
              child: CachedImageWidget(imageUrl: task.thumbnailUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.videoTitle,
                  style: MTextTheme.body2Medium.copyWith(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: task.progress,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            task.isPaused ? AppColors.warning : AppColors.primary,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${task.progressPercent}%',
                      style: MTextTheme.smallTextMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          if (task.isPaused)
            IconButton(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              color: AppColors.primary,
              iconSize: 24,
            )
          else
            IconButton(
              onPressed: onPause,
              icon: const Icon(Icons.pause_rounded),
              color: AppColors.textSecondary,
              iconSize: 24,
            ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.error,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
