import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/widgets/animations/sninning_settingicon.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_search_bar.dart';

class HomeAppBar extends GetView<HomeController> {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              // 1. Title + Settings (Fade out when expanded)
              Obx(() {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: controller.isSearchExpanded.value ? 0.0 : 1.0,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.resetToHome();
                        },
                        child: Text(
                          L.appName.tr,
                          style: MTextTheme.h2Bold.copyWith(
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Reserve space for collapsed search icon (48px) + gap (8px)
                      const SizedBox(width: 56),
                      // Settings Icon
                      SpinningSettingIcon(
                        onTap: () {
                          Get.toNamed(MRoutes.settings);
                        },
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                );
              }),

              // 2. Search Bar (Always visible overlay)
              Obx(() {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  // When expanded, align to right edge (0).
                  // When collapsed, shift left by ~56px to sit next to settings.
                  right: controller.isSearchExpanded.value ? 0 : 56,
                  top: 0,
                  bottom: 0,
                  child: ExpandableSearchBar(
                    isExpanded: controller.isSearchExpanded.value,
                    onExpand: controller.toggleSearch,
                    onCollapse: () {
                      controller.toggleSearch();
                      controller.clearSearch();
                    },
                    onChanged: controller.setSearch,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
