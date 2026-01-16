import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/features/downloads/widgets/quality_sheet.dart';

/// Download Button Widget
/// Handles download state (not downloaded, downloading, downloaded)
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
  void _showQualitySheet() {
    if (video.downloadQualities == null || video.downloadQualities!.isEmpty) {
      Get.snackbar('Error', 'No download options available');
      return;
    }

    Get.bottomSheet(
      QualitySheet(
        qualities: video.downloadQualities!,
        onSelected: (quality) {
          Get.back(); // Close sheet
          DownloadService.to.startDownload(video, quality);
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
