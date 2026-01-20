import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

import '../../../../app/config/theme/m_text_theme.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingIndicatorView extends GetView<OnboardingController> {
  const OnboardingIndicatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Obx(() {
      return Visibility(
        visible: !controller.showNativeFull.value,
        maintainState: true,
        replacement: const SizedBox.shrink(),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 24),
                Obx(
                  () => AnimatedSmoothIndicator(
                    activeIndex: controller.currentPage.value,
                    count: controller.pages.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.white,
                    ),
                  ),
                ),

                const Spacer(),
                Obx(() {
                  final isLastPage = controller.isLastPage;
                  final text = isLastPage ? L.letStarted : L.next;
                  return MButton(
                    onPressed: isLastPage ? controller.completeOnboarding : controller.onNextPage,
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Text(
                      text.tr.toUpperCase(),
                      style: MTextTheme.body2SemiBold.copyWith(color: AppColors.primary, height: 1),
                    ),
                  );
                }),
                const SizedBox(width: 24),
              ],
            ),
            // EasyNativeAdReload(
            //   factoryId: AdsConfig.largeNativeAdUpFactory,
            //   adId: AdsIdManager.nativeIntro,
            //   config: AdsConfig.nativeIntro,
            //   height: AdsConfig.largeNativeAdUpHeight,
            //   borderRadius: BorderRadius.circular(12),
            //   refreshRateSec: AdsConfig.timeNativeReload,
            //   visibilityDetectorKey: '${runtimeType}_native_intro',
            //   color: MColors.background1,
            //   shouldReload: false,
            //   margin: const EdgeInsets.only(top: 3),
            // ),
          ],
        ),
      );
    });
  }
}
