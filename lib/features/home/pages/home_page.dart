import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/widgets/empty_state_widget.dart';
import 'package:watch_movie_tv_show/app/widgets/error_state_widget.dart';
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    AppStrings.homeTitle,
                    style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary),
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
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeSearchBar(
                onChanged: controller.setSearch,
                onClear: controller.clearSearch,
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => SizedBox(
                height: 36,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  children: [
                    // My List Filter
                    GestureDetector(
                      onTap: controller.toggleWatchlistFilter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: controller.showWatchlistOnly.value
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: controller.showWatchlistOnly.value
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              controller.showWatchlistOnly.value
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 16,
                              color: controller.showWatchlistOnly.value
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'My List',
                              style: MTextTheme.captionMedium.copyWith(
                                color: controller.showWatchlistOnly.value
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tags
                    ...controller.tags.map((tag) {
                      final isSelected = controller.selectedTag.value == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => controller.setTag(tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: MTextTheme.captionMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Video Grid
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return const GridSkeleton(aspectRatio: 0.65);
                }

                // Error state
                if (controller.hasError.value) {
                  return ErrorStateWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.retry,
                  );
                }

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
        ),
      ),
    );
  }
}
