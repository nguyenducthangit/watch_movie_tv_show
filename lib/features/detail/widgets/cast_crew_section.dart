import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';

/// Cast & Crew Section Widget
/// Horizontal scrollable list of actors and directors
class CastCrewSection extends StatelessWidget {
  const CastCrewSection({this.actors, this.directors, super.key});

  final List<String>? actors;
  final List<String>? directors;

  @override
  Widget build(BuildContext context) {
    // Don't show if no data
    if ((actors == null || actors!.isEmpty) && (directors == null || directors!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Diễn viên & Đạo diễn',
          style: MTextTheme.body1SemiBold.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),

        // Directors (if available)
        if (directors != null && directors!.isNotEmpty) ...[
          _buildDirectorSection(),
          const SizedBox(height: 16),
        ],

        // Actors horizontal list
        if (actors != null && actors!.isNotEmpty) _buildActorsList(),
      ],
    );
  }

  Widget _buildDirectorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.movie_creation_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Đạo diễn',
              style: MTextTheme.body2SemiBold.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          directors!.join(', '),
          style: MTextTheme.body2Regular.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildActorsList() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actors!.take(10).length, // Limit to 10 actors
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final actor = actors![index];
          return _CastMemberCard(name: actor);
        },
      ),
    );
  }
}

/// Cast Member Card
class _CastMemberCard extends StatelessWidget {
  const _CastMemberCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.textTertiary, size: 30),
          ),
          const SizedBox(height: 6),

          // Actor name
          Text(
            name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: MTextTheme.captionRegular.copyWith(color: AppColors.textSecondary, height: 1.2),
          ),
        ],
      ),
    );
  }
}
