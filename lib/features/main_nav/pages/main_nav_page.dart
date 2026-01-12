import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/features/downloads/pages/downloads_page.dart';
import 'package:watch_movie_tv_show/features/home/pages/home_page.dart';
import 'package:watch_movie_tv_show/features/main_nav/binding/main_nav_binding.dart';
import 'package:watch_movie_tv_show/features/main_nav/controller/main_nav_controller.dart';
import 'package:watch_movie_tv_show/features/settings/pages/settings_page.dart';

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
          children: const [HomeContent(), DownloadsContent(), SettingsContent()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
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
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: AppStrings.home,
                    isSelected: controller.currentIndex.value == 0,
                    onTap: () => controller.changeTab(0),
                  ),
                  _NavItem(
                    icon: Icons.download_rounded,
                    label: AppStrings.downloads,
                    isSelected: controller.currentIndex.value == 1,
                    onTap: () => controller.changeTab(1),
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: AppStrings.settings,
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

/// Navigation Item Widget
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textTertiary, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
