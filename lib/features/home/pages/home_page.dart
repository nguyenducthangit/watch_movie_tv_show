import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/widgets/empty_state_widget.dart';
import 'package:watch_movie_tv_show/app/widgets/error_state_widget.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/category_row.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/continue_watching_card.dart';
import 'package:watch_movie_tv_show/app/widgets/premium/hero_carousel.dart';
import 'package:watch_movie_tv_show/app/widgets/shimmer_loading.dart';
import 'package:watch_movie_tv_show/features/home/binding/home_binding.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_search_bar.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_video_card.dart';

/// Home Page (as standalone route)
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const HomePage(),
    settings: settings,
    routeName: MRoutes.home,
    binding: HomeBinding(),
  );

  @override
  Widget build(BuildContext context) {
    return const HomeContent();
  }
}

/// Home Content (used in MainNav)
class HomeContent extends GetView<HomeController> {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const _LoadingState();
        }

        // Error state
        if (controller.hasError.value) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: controller.retry,
          );
        }

        // Browse mode vs Search/Filter mode
        if (controller.isBrowseMode) {
          return const _PremiumBrowseView();
        } else {
          return const _SearchFilterView();
        }
      }),
    );
  }
}

/// Premium Browse View - Netflix-style layout
class _PremiumBrowseView extends GetView<HomeController> {
  const _PremiumBrowseView();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshVideos,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        slivers: [
          // App bar with search
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      AppStrings.appName,
                      style: MTextTheme.h2Bold.copyWith(
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    // Refresh button
                    Obx(
                      () => controller.isRefreshing.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              onPressed: controller.refreshVideos,
                              icon: const Icon(Icons.refresh_rounded),
                              color: AppColors.textSecondary,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: HomeSearchBar(
                onChanged: controller.setSearch,
                onClear: controller.clearSearch,
              ),
            ),
          ),

          // Tags row
          SliverToBoxAdapter(
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      // My List Filter
                      _FilterChip(
                        label: 'My List',
                        icon: controller.showWatchlistOnly.value
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        isSelected: controller.showWatchlistOnly.value,
                        onTap: controller.toggleWatchlistFilter,
                      ),
                      const SizedBox(width: 8),
                      // Tags
                      ...controller.tags.map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
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

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

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

/// Search/Filter View - Grid layout
class _SearchFilterView extends GetView<HomeController> {
  const _SearchFilterView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  AppStrings.homeTitle,
                  style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary),
                ),
                const Spacer(),
                Obx(
                  () => controller.isRefreshing.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: controller.refreshVideos,
                          icon: const Icon(Icons.refresh_rounded),
                          color: AppColors.textSecondary,
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: HomeSearchBar(onChanged: controller.setSearch, onClear: controller.clearSearch),
        ),
        const SizedBox(height: 16),

        // Tags
        Obx(
          () => SizedBox(
            height: 36,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'My List',
                  icon: controller.showWatchlistOnly.value
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  isSelected: controller.showWatchlistOnly.value,
                  onTap: controller.toggleWatchlistFilter,
                ),
                const SizedBox(width: 8),
                ...controller.tags.map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
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
        const SizedBox(height: 16),

        // Video Grid
        Expanded(
          child: Obx(() {
            // Empty state
            if (controller.filteredVideos.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.video_library_outlined,
                title: AppStrings.noVideosFound,
                message: controller.searchQuery.value.isNotEmpty
                    ? 'Try a different search'
                    : AppStrings.noVideosDescription,
                buttonText: controller.searchQuery.value.isNotEmpty ? 'Clear Search' : null,
                onButtonPressed: controller.searchQuery.value.isNotEmpty
                    ? controller.clearSearch
                    : null,
              );
            }

            // Video grid
            return RefreshIndicator(
              onRefresh: controller.refreshVideos,
              color: AppColors.primary,
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: controller.filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = controller.filteredVideos[index];
                  return HomeVideoCard(
                    video: video,
                    isDownloaded: controller.isVideoDownloaded(video.id),
                    onTap: () => controller.openVideoDetail(video),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Loading State
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 80),
          HeroCarouselSkeleton(),
          SizedBox(height: 32),
          ContinueWatchingSkeleton(),
          SizedBox(height: 32),
          CategoryRowSkeleton(),
          SizedBox(height: 24),
          CategoryRowSkeleton(itemWidth: 200, itemHeight: 280),
        ],
      ),
    );
  }
}

/// Filter Chip
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: MTextTheme.captionMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
