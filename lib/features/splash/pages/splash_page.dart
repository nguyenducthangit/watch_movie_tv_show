import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/features/splash/binding/splash_binding.dart';
import 'package:watch_movie_tv_show/features/splash/controller/splash_controller.dart';
import 'package:watch_movie_tv_show/features/splash/widgets/splash_progress_bar.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const SplashPage(),
    settings: settings,
    routeName: MRoutes.splash,
    binding: SplashBinding(),
    transition: Transition.fade,
    transitionDuration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background
          // Assets.images.bgSplash.image(
          //   height: context.height,
          //   width: context.width,
          //   fit: BoxFit.cover,
          // ),
          Column(
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.black, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  // child: Assets.images.iconApp.image(height: 128, width: 128),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: Text(
                  L.appName.tr,
                  style: MTextTheme.h3SemiBold.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              const SplashProgressBar(),
              const SizedBox(height: 16),
              Text(
                L.thisActionMayContainAds.tr,
                style: MTextTheme.body2Regular.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
