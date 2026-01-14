import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/category_row.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/continue_watching_card.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/hero_carousel.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_filterchip.dart';

class HomePremiumBrowseView extends GetView<HomeController> {
  const HomePremiumBrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshVideos,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      edgeOffset: 80,
      child: CustomScrollView(
        slivers: [
          // Hero Carousel
          SliverToBoxAdapter(
            child: Obx(() {
              final videos = controller.featuredVideos.toList();
              return HeroCarousel(
                videos: videos,
                onVideoTap: controller.openVideoDetail,
                onPlayTap: controller.playVideo,
              );
            }),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // Tags row
          SliverToBoxAdapter(
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.only(top: 0),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Tags
                      ...controller.tags.map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: HomeFilterchip(
                            label: tag,
                            isSelected: controller.selectedTag.value == tag,
                            onTap: () => controller.setTag(tag),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Continue Watching
          SliverToBoxAdapter(
            child: Obx(() {
              final videos = controller.continueWatching.toList();
              final progress = Map<String, double>.from(controller.progressMap);
              if (videos.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  ContinueWatchingSection(
                    videos: videos,
                    progressMap: progress,
                    onVideoTap: controller.openVideoDetail,
                  ),
                  const SizedBox(height: 32),
                ],
              );
            }),
          ),

          // Trending Now
          SliverToBoxAdapter(
            child: Obx(() {
              final videos = controller.trendingVideos.toList();
              return CategoryRow(
                title: 'Trending Now',
                videos: videos,
                onVideoTap: controller.openVideoDetail,
              );
            }),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // New Releases
          SliverToBoxAdapter(
            child: Obx(() {
              final videos = controller.newReleases.toList();
              return LargeCategoryRow(
                title: 'New Releases',
                videos: videos,
                onVideoTap: controller.openVideoDetail,
              );
            }),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // By Genre sections
          SliverToBoxAdapter(
            child: Obx(() {
              final genreMap = Map<String, List<VideoItem>>.from(controller.videosByGenre);
              final genres = genreMap.keys.take(3).toList();
              if (genres.isEmpty) return const SizedBox.shrink();
              return Column(
                children: genres.map((genre) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: CategoryRow(
                      title: genre,
                      videos: genreMap[genre] ?? [],
                      onVideoTap: controller.openVideoDetail,
                    ),
                  );
                }).toList(),
              );
            }),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
