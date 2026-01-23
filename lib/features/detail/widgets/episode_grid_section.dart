import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/data/models/movie_model.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/features/detail/controller/detail_controller.dart';
import 'package:watch_movie_tv_show/app/utils/quality_mapper.dart';

/// Episode Grid Section Widget
/// Displays episodes in a grid layout with server selection for series
class EpisodeGridSection extends GetView<DetailController> {
  const EpisodeGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final movie = controller.movieDetail.value;

      // Don't show if no valid playable episodes
      if (movie == null || !movie.hasValidEpisodes) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            L.episodeList.tr,
            style: MTextTheme.body1SemiBold.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),

          // Server selector (if multiple servers)
          if (movie.episodes!.length > 1) ...[
            serverSelector(movie.episodes!),
            const SizedBox(height: 12),
          ],

          // Episodes grid
          episodeGrid(movie.episodes![controller.selectedServerIndex.value]),
        ],
      );
    });
  }

  Widget serverSelector(List<EpisodeServerData> servers) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: servers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedServerIndex.value == index;
            return InkWell(
              onTap: () => controller.selectServer(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
                ),
                child: Center(
                  child: Text(
                    'Server ${index + 1}',
                    style: MTextTheme.body2SemiBold.copyWith(
                      color: isSelected ? Colors.black : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget episodeGrid(EpisodeServerData serverData) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: serverData.episodes.length,
      itemBuilder: (context, index) {
        final episode = serverData.episodes[index];
        final isValid = episode.linkM3u8.isNotEmpty;

        return Obx(
          () => _EpisodeCard(
            episode: episode,
            isSelected: controller.selectedEpisode.value?.slug == episode.slug,
            isDisabled: !isValid,
            onTap: isValid ? () => controller.selectEpisode(episode) : () {},
          ),
        );
      },
    );
  }
}

/// Episode Card Widget
class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.episode,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
  });

  final EpisodeItem episode;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.surfaceVariant.withValues(alpha: 0.3)
              : isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDisabled
                ? AppColors.border.withValues(alpha: 0.1)
                : isSelected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            QualityMapper.translate(episode.name),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MTextTheme.captionSemiBold.copyWith(
              color: isDisabled
                  ? AppColors.textTertiary.withValues(alpha: 0.4)
                  : isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
