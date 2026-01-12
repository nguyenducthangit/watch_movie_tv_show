import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/utils/extensions.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';
import 'package:watch_movie_tv_show/features/detail/binding/detail_binding.dart';
import 'package:watch_movie_tv_show/features/detail/controller/detail_controller.dart';
import 'package:watch_movie_tv_show/features/detail/widgets/detail_quality_sheet.dart';

/// Detail Page
class DetailPage extends GetView<DetailController> {
  const DetailPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const DetailPage(),
    settings: settings,
    routeName: MRoutes.detail,
    binding: DetailBinding(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail
                  CachedImageWidget(imageUrl: controller.video.thumbnailUrl, fit: BoxFit.cover),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Play button
                  Center(
                    child: GestureDetector(
                      onTap: controller.playVideo,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    controller.video.title,
                    style: MTextTheme.h3SemiBold.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Meta info
                  Row(
                    children: [
                      if (controller.video.durationSec != null) ...[
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.video.durationSec!.toFormattedDuration(),
                          style: MTextTheme.captionRegular.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (controller.video.tags != null && controller.video.tags!.isNotEmpty)
                        Text(
                          controller.video.tags!.join(' • '),
                          style: MTextTheme.captionRegular.copyWith(color: AppColors.textTertiary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Play button
                      Expanded(
                        flex: 2,
                        child: _PlayButton(
                          onPressed: controller.playVideo,
                          resumeText: controller.watchProgressText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Download button
                      Expanded(
                        child: Obx(
                          () => _DownloadButton(
                            isDownloaded: controller.isDownloaded.value,
                            isDownloading: controller.isDownloading.value,
                            progress: controller.downloadProgress.value,
                            onPressed: () => _showQualitySheet(context),
                            onCancel: controller.cancelDownload,
                            onDelete: controller.deleteDownload,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (controller.video.description != null) ...[
                    Text(
                      'Description',
                      style: MTextTheme.body1SemiBold.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.video.description!,
                      style: MTextTheme.body2Regular.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQualitySheet(BuildContext context) {
    if (controller.isDownloaded.value || controller.isDownloading.value) {
      return;
    }

    if (controller.video.hasDownloadOptions) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => DetailQualitySheet(
          qualities: controller.video.downloadQualities!,
          onSelect: controller.startDownload,
        ),
      );
    } else {
      Get.snackbar('No Download', 'Download not available for this video');
    }
  }
}

/// Play Button Widget
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onPressed, this.resumeText});
  final VoidCallback onPressed;
  final String? resumeText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow_rounded),
      label: Text(resumeText != null ? 'Resume' : AppStrings.play),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Download Button Widget
class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    required this.isDownloaded,
    required this.isDownloading,
    required this.progress,
    required this.onPressed,
    required this.onCancel,
    required this.onDelete,
  });
  final bool isDownloaded;
  final bool isDownloading;
  final double progress;
  final VoidCallback onPressed;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (isDownloaded) {
      return OutlinedButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.download_done_rounded),
        label: const Text('Done'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.success,
          side: const BorderSide(color: AppColors.success),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (isDownloading) {
      return OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
              ),
            ),
            const Icon(Icons.close, size: 12, color: AppColors.textSecondary),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.download_rounded),
      label: const Text('Save'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
