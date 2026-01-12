import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/features/splash/binding/splash_binding.dart';
import 'package:watch_movie_tv_show/features/splash/controller/splash_controller.dart';

/// Splash Page
/// Initial screen with loading animation
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
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                );
              },
              child: Text(
                AppStrings.appName,
                style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 60),

            // Progress indicator
            Obx(
              () => AnimatedOpacity(
                opacity: controller.isLoading.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    // Progress bar
                    SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: controller.progress.value,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status message
                    Text(
                      controller.statusMessage.value,
                      style: MTextTheme.captionRegular.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
