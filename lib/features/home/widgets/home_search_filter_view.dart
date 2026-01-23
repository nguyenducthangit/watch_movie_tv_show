import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/tag_mapper.dart';
import 'package:watch_movie_tv_show/app/widgets/empty_state_widget.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_filterchip.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_video_card.dart';

class HomeSearchFilterView extends GetView<HomeController> {
  const HomeSearchFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          // Load more when user scrolls to 80% of the list
          if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
            controller.loadMoreMovies();
          }
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
        // Top padding for sticky header
        const SliverToBoxAdapter(child: SizedBox(height: 100)),

        // Tags
        SliverToBoxAdapter(
          child: Obx(
            () => SizedBox(
              height: 36,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  ...controller.tags.map(
                    (tag) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: HomeFilterchip(
                        label: TagMapper.getTranslatedTag(tag),
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

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        Obx(() {
          if (controller.filteredVideos.isEmpty) {
            return SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.video_library_outlined,
                title: L.noVideosFound.tr,
                message: controller.searchQuery.value.isNotEmpty
                    ? L.tryADifferentSearch.tr
                    : L.checkBackLater.tr,
                buttonText: controller.searchQuery.value.isNotEmpty ? L.clearSearch.tr : null,
                onButtonPressed: controller.searchQuery.value.isNotEmpty
                    ? controller.clearSearch
                    : null,
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final video = controller.filteredVideos[index];
                return HomeVideoCard(
                  video: video,
                  isDownloaded: controller.isVideoDownloaded(video.id),
                  onTap: () => controller.openVideoDetail(video),
                );
              }, childCount: controller.filteredVideos.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
            ),
          );
        }),

        // Loading more indicator
        Obx(() {
          if (controller.isLoadingMore.value) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }),
      ],
      ),
    );
  }
}
