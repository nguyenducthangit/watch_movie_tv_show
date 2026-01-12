import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';
import 'package:watch_movie_tv_show/app/widgets/empty_state_widget.dart';
import 'package:watch_movie_tv_show/features/downloads/binding/downloads_binding.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';

/// Downloads Page (standalone route)
class DownloadsPage extends GetView<DownloadsController> {
  const DownloadsPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const DownloadsPage(),
    settings: settings,
    routeName: MRoutes.downloads,
    binding: DownloadsBinding(),
  );

  @override
  Widget build(BuildContext context) {
    return const DownloadsContent();
  }
}

/// Downloads Content (used in MainNav)
class DownloadsContent extends GetView<DownloadsController> {
  const DownloadsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          // Empty state
          if (!controller.hasDownloads) {
            return Column(
              children: [
                _buildHeader(),
                const Expanded(
                  child: EmptyStateWidget(
                    icon: Icons.download_outlined,
                    title: AppStrings.noDownloads,
                    message: AppStrings.noDownloadsDescription,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              // Storage info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.storage_rounded, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Text(
                      '${AppStrings.storageUsed}: ${controller.storageUsedString}',
                      style: MTextTheme.captionRegular.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Active downloads section
                    if (controller.activeDownloads.isNotEmpty) ...[
                      _SectionHeader(
                        title: AppStrings.activeDownloads,
                        count: controller.activeDownloads.length,
                      ),
                      const SizedBox(height: 12),
                      ...controller.activeDownloads.map(
                        (task) => _ActiveDownloadItem(
                          task: task,
                          onPause: () => controller.pauseDownload(task.videoId),
                          onResume: () => controller.resumeDownload(task.videoId),
                          onCancel: () => controller.cancelDownload(task.videoId),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Completed downloads section
                    if (controller.completedDownloads.isNotEmpty) ...[
                      _SectionHeader(
                        title: AppStrings.completedDownloads,
                        count: controller.completedDownloads.length,
                      ),
                      const SizedBox(height: 12),
                      ...controller.completedDownloads.map(
                        (task) => _CompletedDownloadItem(
                          task: task,
                          onPlay: () => controller.playVideo(task),
                          onDelete: () => controller.deleteDownload(task.videoId),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Text(
            AppStrings.downloads,
            style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary),
          ),
          const Spacer(),
          if (controller.hasDownloads)
            IconButton(
              onPressed: controller.deleteAllDownloads,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}

/// Section Header
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: MTextTheme.body1SemiBold.copyWith(color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: MTextTheme.captionMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Active Download Item
class _ActiveDownloadItem extends StatelessWidget {
  const _ActiveDownloadItem({
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

/// Completed Download Item
class _CompletedDownloadItem extends StatelessWidget {
  const _CompletedDownloadItem({required this.task, required this.onPlay, required this.onDelete});
  final DownloadTask task;
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
          onTap: onPlay,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
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

                // Delete
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.textTertiary,
                  iconSize: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
