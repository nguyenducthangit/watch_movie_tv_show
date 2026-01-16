import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/widgets/cached_image_widget.dart';
import 'package:watch_movie_tv_show/features/detail/binding/detail_binding.dart';
import 'package:watch_movie_tv_show/features/detail/controller/detail_controller.dart';
import 'package:watch_movie_tv_show/features/detail/widgets/cast_crew_section.dart';
import 'package:watch_movie_tv_show/features/detail/widgets/description_section.dart';
import 'package:watch_movie_tv_show/features/detail/widgets/detail_info_header.dart';
import 'package:watch_movie_tv_show/features/detail/widgets/episode_grid_section.dart';
import 'package:watch_movie_tv_show/features/detail/widgets/play_button.dart';
import 'package:watch_movie_tv_show/features/detail/widgets/up_next_section.dart';
import 'package:watch_movie_tv_show/features/downloads/widgets/download_button.dart';

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
                  color: AppColors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail - Reactive to handle dynamic updates
                  Obx(() {
                    final movieThumbnail = controller.movieDetail.value?.getFullThumbnailUrl();
                    final thumbnailUrl = (movieThumbnail != null && movieThumbnail.isNotEmpty)
                        ? movieThumbnail
                        : controller.video.thumbnailUrl;

                    return Hero(
                      tag: 'video_thumb_${controller.video.id}',
                      child: CachedImageWidget(imageUrl: thumbnailUrl, fit: BoxFit.cover),
                    );
                  }),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.black.withValues(alpha: 0.3),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Play button with smooth animations
                  Center(child: _PlayButtonWithAnimation(onTap: controller.playVideo)),
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
                  // Info Header (Title, Metadata, Categories) - Reactive
                  Obx(() {
                    final movie = controller.movieDetail.value;
                    return DetailInfoHeader(
                      title: movie?.name ?? controller.video.title,
                      originName: movie?.originName,
                      year: movie?.year ?? controller.video.year,
                      quality: movie?.quality ?? controller.video.quality,
                      lang: movie?.lang ?? controller.video.lang,
                      episodeCurrent: movie?.episodeCurrent ?? controller.video.episodeCurrent,
                      episodeTotal: movie?.episodeTotal ?? controller.video.episodeTotal,
                      categories: movie?.categories ?? controller.video.tags,
                      view: movie?.view,
                    );
                  }),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Play button
                      Expanded(
                        flex: 2,
                        child: PlayButton(
                          onPressed: controller.playVideo,
                          resumeText: controller.watchProgressText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Download button
                      DownloadButton(video: controller.video),
                      const SizedBox(width: 12),
                      // Watchlist button
                      Obx(
                        () => IconButton(
                          onPressed: controller.toggleWatchlist,
                          icon: Icon(
                            controller.isInWatchlist.value
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: controller.isInWatchlist.value
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceVariant,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Share button
                      IconButton(
                        onPressed: controller.shareVideo,
                        icon: const Icon(Icons.share_rounded, color: AppColors.textSecondary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceVariant,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section - Reactive
                  Obx(() {
                    final description =
                        controller.movieDetail.value?.content ?? controller.video.description;
                    if (description != null && description.isNotEmpty) {
                      return Column(
                        children: [
                          DescriptionSection(description: description),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Cast & Crew Section - Reactive
                  Obx(() {
                    final actors = controller.movieDetail.value?.actor ?? controller.video.actor;
                    final directors =
                        controller.movieDetail.value?.director ?? controller.video.director;
                    final hasActors = actors != null && actors.isNotEmpty;
                    final hasDirectors = directors != null && directors.isNotEmpty;

                    if (hasActors || hasDirectors) {
                      return Column(
                        children: [
                          CastCrewSection(actors: actors, directors: directors),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Episode Grid Section - Only show if movie has valid playable episodes
                  Obx(() {
                    final movie = controller.movieDetail.value;
                    final hasValidEpisodes = movie != null && movie.hasValidEpisodes;

                    if (!hasValidEpisodes) {
                      return const SizedBox.shrink();
                    }

                    return const Column(children: [EpisodeGridSection(), SizedBox(height: 24)]);
                  }),

                  // Up Next section
                  UpNextSection(
                    videos: controller.relatedVideos,
                    onVideoTap: (video) {
                      // Navigate to new detail page
                      Get.toNamed(MRoutes.detail, arguments: video);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium Play Button with smooth animations
class _PlayButtonWithAnimation extends StatefulWidget {
  const _PlayButtonWithAnimation({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_PlayButtonWithAnimation> createState() => _PlayButtonWithAnimationState();
}

class _PlayButtonWithAnimationState extends State<_PlayButtonWithAnimation> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact(); // Tactile feedback
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    HapticFeedback.mediumImpact(); // Stronger feedback on actual tap
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          customBorder: const CircleBorder(),
          splashColor: AppColors.primary.withValues(alpha: 0.3),
          highlightColor: AppColors.primary.withValues(alpha: 0.2),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: _isPressed ? 15 : 20,
                  offset: Offset(0, _isPressed ? 6 : 8),
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
