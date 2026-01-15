import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';

class DownloadItem extends StatelessWidget {
  const DownloadItem({
    super.key,
    required this.task,
    required this.isEditMode,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onPlay,
    required this.onDelete,
  });
  final DownloadTask task;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEditMode ? onToggleSelect : onPlay,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox (edit mode)
                if (isEditMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelect(),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                ],

                // Thumbnail
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 80,
                        height: 48,
                        child: CachedImageWidget(imageUrl: task.thumbnailUrl, fit: BoxFit.cover),
                      ),
                    ),
                    if (!isEditMode)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.download_done_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.qualityLabel ?? 'Downloaded',
                            style: MTextTheme.smallTextRegular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete (non-edit mode)
                // if (!isEditMode)
                //   IconButton(
                //     onPressed: onDelete,
                //     icon: const Icon(Icons.delete_outline_rounded),
                //     color: AppColors.textTertiary,
                //     iconSize: 22,
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
