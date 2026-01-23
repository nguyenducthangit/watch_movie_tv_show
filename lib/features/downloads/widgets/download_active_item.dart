import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';

class DownloadActiveItem extends GetWidget<DownloadsController> {
  const DownloadActiveItem({super.key, required this.task, required this.onCancel});
  final DownloadTask task;
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
            child: GetBuilder<DownloadsController>(
              id: 'download_task_${task.videoId}',
              builder: (_) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final title = controller.translatedTitles[task.videoId] ?? task.videoTitle;
                      return Text(
                        title,
                        style: MTextTheme.body2Medium.copyWith(color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
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
                          style: MTextTheme.smallTextMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          GetBuilder<DownloadsController>(
            id: 'download_task_${task.videoId}',
            builder: (_) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.error,
                    iconSize: 20,
                    tooltip: L.cancel.tr,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
