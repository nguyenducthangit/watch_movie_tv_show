import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/video_quality.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/extensions.dart';

/// Quality Selection Bottom Sheet

class QualitySheet extends StatelessWidget {
  const QualitySheet({super.key, required this.qualities, required this.onSelected});
  final List<VideoQuality> qualities;
  final ValueChanged<VideoQuality> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              L.selectQuality.tr,
              style: MTextTheme.h4SemiBold.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),

          // Quality options
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: qualities.length,
            separatorBuilder: (_, _) => const Divider(color: AppColors.divider, height: 1),
            itemBuilder: (context, index) {
              final quality = qualities[index];
              return _QualityItem(quality: quality, onTap: () => onSelected(quality));
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _QualityItem extends StatelessWidget {
  const _QualityItem({required this.quality, required this.onTap});
  final VideoQuality quality;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            quality.label,
            style: MTextTheme.body2Medium.copyWith(color: AppColors.primary),
          ),
        ),
      ),
      title: Text(
        quality.label,
        style: MTextTheme.body1Medium.copyWith(color: AppColors.textPrimary),
      ),
      subtitle: quality.sizeMB != null
          ? Text(
              quality.sizeMB!.toFileSizeString(),
              style: MTextTheme.captionRegular.copyWith(color: AppColors.textTertiary),
            )
          : null,
      trailing: const Icon(Icons.download_rounded, color: AppColors.textSecondary),
    );
  }
}
