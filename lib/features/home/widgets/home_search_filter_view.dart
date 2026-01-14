import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/widgets/empty_state_widget.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_filterchip.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_video_card.dart';

class HomeSearchFilterView extends GetView<HomeController> {
  const HomeSearchFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        Obx(() {
          if (controller.filteredVideos.isEmpty) {
            return SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.video_library_outlined,
                title: AppStrings.noVideosFound,
                message: controller.searchQuery.value.isNotEmpty
                    ? 'Try a different search'
                    : AppStrings.noVideosDescription,
                buttonText: controller.searchQuery.value.isNotEmpty ? 'Clear Search' : null,
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
      ],
    );
  }
}
