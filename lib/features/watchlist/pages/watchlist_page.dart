import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/widgets/empty_state_widget.dart';
import 'package:watch_movie_tv_show/features/watchlist/binding/watchlist_binding.dart';
import 'package:watch_movie_tv_show/features/watchlist/controller/watchlist_controller.dart';
import 'package:watch_movie_tv_show/features/watchlist/widgets/watch_list_card.dart';

/// Watchlist Page (standalone route)
class WatchlistPage extends GetView<WatchlistController> {
  const WatchlistPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const WatchlistPage(),
    settings: settings,
    routeName: MRoutes.watchlist,
    binding: WatchlistBinding(),
  );

  @override
  Widget build(BuildContext context) {
    return const WatchlistContent();
  }
}

/// Watchlist Content (used in MainNav)
class WatchlistContent extends GetView<WatchlistController> {
  const WatchlistContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                L.watchlist.tr,
                style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary),
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                // Empty state
                if (controller.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.bookmark_border_rounded,
                    title: L.yourWatchlistisEmpty.tr,
                    message: L.addVideoToWatchThemLater.tr,
                  );
                }

                // Watchlist grid
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.watchlistVideos.length,
                    itemBuilder: (context, index) {
                      final video = controller.watchlistVideos[index];
                      return WatchlistCard(
                        video: video,
                        onTap: () => Get.toNamed(MRoutes.detail, arguments: video),
                        onRemove: () => controller.removeFromWatchlist(video.id),
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
