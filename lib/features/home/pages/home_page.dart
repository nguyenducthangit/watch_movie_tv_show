import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/widgets/error_state_widget.dart';
import 'package:watch_movie_tv_show/features/home/binding/home_binding.dart';
import 'package:watch_movie_tv_show/features/home/controller/home_controller.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_appbar.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_loading.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_premium_browse_view.dart';
import 'package:watch_movie_tv_show/features/home/widgets/home_search_filter_view.dart';

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
    return SafeArea(
      bottom: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Sticky Header (Persistent across states)
              const Positioned(top: 0, left: 0, right: 0, child: HomeAppBar()),
              Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return const HomeLoading();
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
                  return const HomePremiumBrowseView();
                } else {
                  return const HomeSearchFilterView();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
