import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/quality_mapper.dart';
import 'package:watch_movie_tv_show/app/utils/tag_mapper.dart';

/// Detail Info Header Widget
/// Displays movie metadata: title, year, quality, language, episodes, categories
class DetailInfoHeader extends StatelessWidget {
  const DetailInfoHeader({
    required this.title,
    this.originName,
    this.year,
    this.quality,

    this.episodeCurrent,
    this.episodeTotal,
    this.categories,
    this.view,
    super.key,
  });

  final String title;
  final String? originName;
  final int? year;
  final String? quality;

  final String? episodeCurrent;
  final String? episodeTotal;
  final List<String>? categories;
  final int? view;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(title, style: MTextTheme.h3SemiBold.copyWith(color: AppColors.textPrimary)),

        // Origin name (if different)
        if (originName != null && originName!.isNotEmpty && originName != title) ...[
          const SizedBox(height: 4),
          Text(
            originName!,
            style: MTextTheme.body2Regular.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Metadata badges row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Year badge
            if (year != null)
              _MetadataBadge(label: year.toString(), icon: Icons.calendar_today_rounded),

            // Quality badge (HD, FHD) - Translated
            if (quality != null && quality!.isNotEmpty)
              _MetadataBadge(
                label: QualityMapper.translate(quality),
                icon: Icons.hd_rounded,
                isPremium: true,
              ),

            // Episode progress - Translate episodeCurrent (e.g., "Full" -> "पूर्ण" in Hindi)
            if (episodeCurrent != null && episodeTotal != null)
              _MetadataBadge(
                label: '${TagMapper.getTranslatedTag(episodeCurrent!)}/$episodeTotal',
                icon: Icons.video_library_rounded,
              ),
          ],
        ),

        // Categories chips
        if (categories != null && categories!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: categories!.take(5).map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                ),
                child: Text(
                  TagMapper.getTranslatedTag(category),
                  style: MTextTheme.captionRegular.copyWith(color: AppColors.textSecondary),
                ),
              );
            }).toList(),
          ),
        ],

        // View count
        if (view != null && view! > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.visibility_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${_formatNumber(view!)} ${L.view.tr}',
                style: MTextTheme.captionRegular.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// Metadata Badge Widget
class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({required this.label, required this.icon, this.isPremium = false});

  final String label;
  final IconData icon;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPremium ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: isPremium ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isPremium ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: MTextTheme.captionSemiBold.copyWith(
              color: isPremium ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
