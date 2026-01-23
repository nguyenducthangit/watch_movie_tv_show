import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/features/downloads/pages/downloads_page.dart';
import 'package:watch_movie_tv_show/features/home/pages/home_page.dart';
import 'package:watch_movie_tv_show/features/main_nav/binding/main_nav_binding.dart';
import 'package:watch_movie_tv_show/features/main_nav/controller/main_nav_controller.dart';
import 'package:watch_movie_tv_show/features/main_nav/widgets/nav_item.dart';
import 'package:watch_movie_tv_show/features/watchlist/pages/watchlist_page.dart';

/// Main Navigation Page
/// Bottom navigation with 3 tabs: Home, Downloads, Settings
class MainNavPage extends GetView<MainNavController> {
  const MainNavPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const MainNavPage(),
    settings: settings,
    routeName: MRoutes.mainNav,
    binding: MainNavBinding(),
    transition: Transition.fade,
    transitionDuration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [HomeContent(), DownloadsContent(), WatchlistContent()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    icon: Icons.home_rounded,
                    label: L.home.tr,
                    isSelected: controller.currentIndex.value == 0,
                    onTap: () => controller.changeTab(0),
                  ),
                  NavItem(
                    icon: Icons.download_rounded,
                    label: L.downloads.tr,
                    isSelected: controller.currentIndex.value == 1,
                    onTap: () => controller.changeTab(1),
                  ),
                  NavItem(
                    icon: Icons.bookmark_rounded,
                    label: L.watchlist.tr,
                    isSelected: controller.currentIndex.value == 2,
                    onTap: () => controller.changeTab(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
