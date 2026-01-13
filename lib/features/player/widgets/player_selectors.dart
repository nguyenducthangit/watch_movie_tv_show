import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/glass_card.dart';

/// Quality Selector Widget
/// Modal for selecting video playback quality
class QualitySelector extends StatelessWidget {
  const QualitySelector({
    super.key,
    required this.currentQuality,
    required this.availableQualities,
    required this.onQualitySelected,
  });

  final String currentQuality;
  final List<String> availableQualities;
  final void Function(String quality) onQualitySelected;

  static Future<String?> show(
    BuildContext context, {
    required String currentQuality,
    List<String> availableQualities = const ['Auto', '1080p', '720p', '480p', '360p'],
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QualitySelector(
        currentQuality: currentQuality,
        availableQualities: availableQualities,
        onQualitySelected: (q) => Navigator.pop(context, q),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        blur: 20,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.hd_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Video Quality',
                    style: MTextTheme.h4SemiBold.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Quality options
            ...availableQualities.map((quality) {
              final isSelected = quality == currentQuality;
              return InkWell(
                onTap: () => onQualitySelected(quality),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        quality,
                        style: MTextTheme.body1Medium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (quality == 'Auto')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Recommended',
                            style: MTextTheme.smallTextMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Speed Selector Widget
/// Modal for selecting video playback speed
class SpeedSelector extends StatelessWidget {
  const SpeedSelector({super.key, required this.currentSpeed, required this.onSpeedSelected});

  final double currentSpeed;
  final void Function(double speed) onSpeedSelected;

  static const List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  static Future<double?> show(BuildContext context, {required double currentSpeed}) {
    return showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SpeedSelector(
        currentSpeed: currentSpeed,
        onSpeedSelected: (s) => Navigator.pop(context, s),
      ),
    );
  }

  String _formatSpeed(double speed) {
    if (speed == 1.0) return 'Normal';
    return '${speed}x';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        blur: 20,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Playback Speed',
                    style: MTextTheme.h4SemiBold.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Speed options
            ...speeds.map((speed) {
              final isSelected = speed == currentSpeed;
              return InkWell(
                onTap: () => onSpeedSelected(speed),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatSpeed(speed),
                        style: MTextTheme.body1Medium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
