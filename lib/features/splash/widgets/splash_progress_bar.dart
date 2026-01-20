import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/utils/assets.gen.dart';
import 'package:watch_movie_tv_show/features/splash/controller/splash_controller.dart';

class SplashProgressBar extends GetView<SplashController> {
  const SplashProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double progressBarWidth = min(context.width - 160, 250);
    const iconHeight = 59.0;
    const iconWidth = 40.0;
    const progressHeight = 72.0;
    const progressBarHeight = 4.0;
    return SizedBox(
      height: progressHeight,
      width: progressBarWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(
            () => Positioned(
              bottom: progressBarHeight,
              right: (1 - controller.progress.value) * progressBarWidth,
              child: Transform.rotate(
                angle: (controller.self.value * 2 - 1) * pi / 8,
                child: Assets.icons.icSplashProgress.svg(height: iconHeight, width: iconWidth),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: progressBarHeight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(55),
              ),
            ),
          ),
          Obx(
            () => Positioned(
              left: 0,
              bottom: 0,
              height: progressBarHeight,
              width: controller.progress.value * progressBarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
