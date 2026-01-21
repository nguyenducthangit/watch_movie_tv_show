import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/video_quality.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/features/detail/controller/detail_controller.dart';
import 'package:watch_movie_tv_show/features/downloads/widgets/quality_sheet.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key, required this.video});
  final VideoItem video;

  @override
  @override
  Widget build(BuildContext context) {
    final downloadService = DownloadService.to;

    return Obx(() {
      // 1. Check if downloaded
      if (downloadService.isDownloaded(video.id)) {
        return _buildButton(
          context,
          icon: Icons.download_done_rounded,
          color: AppColors.success,
          onPressed: () => _showDeleteDialog(context),
        );
      }

      // 2. Check if downloading
      final task = downloadService.getTask(video.id);
      if (task != null && task.status != DownloadStatus.failed) {
        return _buildDownloadingButton(context, task);
      }

      // 3. Not downloaded
      return _buildButton(
        context,
        icon: Icons.download_rounded,
        color: AppColors.textSecondary,
        onPressed: () => _showQualitySheet(),
      );
    });
  }

  /// Generic Icon Button Builder
  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  /// State: Downloading (Progress Indicator)
  Widget _buildDownloadingButton(BuildContext context, DownloadTask task) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: task.progress,
            strokeWidth: 3,
            backgroundColor: AppColors.textTertiary.withValues(alpha: 0.2),
            color: AppColors.primary,
          ),
          IconButton(
            onPressed: () => _showDownloadingSheet(context, task),
            icon: const Icon(Icons.stop_rounded, size: 20, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  /// Show Quality Selection Sheet
  Future<void> _showQualitySheet() async {
    // Ensure movie detail is loaded first (to get downloadQualities)
    if (video.downloadQualities == null || video.downloadQualities!.isEmpty) {
      // Try to get DetailController to wait for detail loading
      try {
        final detailController = Get.find<DetailController>();

        // Show loading
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          barrierDismissible: false,
        );

        // Wait for detail loading to complete (if currently loading)
        // The _loadMovieDetail() is already called in onInit()
        if (detailController.isLoadingDetail.value) {
          // Wait for loading to finish (max 10 seconds)
          int attempts = 0;
          while (detailController.isLoadingDetail.value && attempts < 100) {
            await Future.delayed(const Duration(milliseconds: 100));
            attempts++;
          }
        }

        Get.back(); // Close loading

        // Check again after loading - use controller's updated video
        if (detailController.video.downloadQualities == null ||
            detailController.video.downloadQualities!.isEmpty) {
          Get.snackbar(
            'No Download Available',
            'This video cannot be downloaded',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Use controller's updated video with qualities
        final qualities = detailController.video.downloadQualities!;
        _showQualityBottomSheet(qualities);
      } catch (e) {
        Get.back(); // Close loading if error
        Get.snackbar(
          'Error',
          'Failed to load download options',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    _showQualityBottomSheet(video.downloadQualities!);
  }

  void _showQualityBottomSheet(List<VideoQuality> qualities) {
    Get.bottomSheet(
      QualitySheet(
        qualities: qualities,
        onSelected: (quality) {
          Get.back(); // Close sheet

          // Map quality label to HLS variant index
          // HD = 0 (highest), SD = 1 (medium), 360p = 2 (lowest)
          int variantIndex = 0;
          if (quality.label == L.sd.tr) {
            variantIndex = 1;
          } else if (quality.label == '360${L.p.tr}') {
            variantIndex = 2;
          }

          // Start download with variant index (will be used for HLS)
          DownloadService.to.startDownload(video, quality, variantIndex: variantIndex);
        },
      ),
      isScrollControlled: true,
    );
  }

  /// Show Downloading Control Dialog (simplified)
  void _showDownloadingSheet(BuildContext context, DownloadTask task) {
    Get.defaultDialog(
      title: 'Cancel downloading the video?',
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      middleText: 'You can re-download this later.',
      middleTextStyle: const TextStyle(fontSize: 14, color: Colors.white70),
      backgroundColor: const Color(0xFF424242),
      radius: 12,
      textCancel: 'NO, KEEP DOWNLOADING',
      textConfirm: 'YES, CANCEL',
      cancelTextColor: AppColors.primary,
      confirmTextColor: Colors.white70,
      buttonColor: const Color(0xFF616161),
      onConfirm: () {
        DownloadService.to.cancelDownload(video.id);
        Get.back();
      },
      onCancel: () {
        // Just close dialog
      },
    );
  }

  /// Show Delete Confirmation
  void _showDeleteDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Delete Download?',
      middleText: 'Remove this video from your downloads?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        DownloadService.to.deleteDownload(video.id);
        Get.back();
      },
    );
  }
}
