import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/assets.gen.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232326),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232326),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          L.noInternetTitle.tr,
          style: Get.textTheme.headlineMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 270, width: 270, child: Assets.images.imgDisconectWifi.image()),
              const SizedBox(height: 25),
              Text(
                L.noInternet.tr,
                style: Get.textTheme.titleMedium?.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              Text(
                L.checkConnection.tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.labelMedium?.copyWith(color: AppColors.white),
              ).marginSymmetric(horizontal: Get.width * 0.1),
              const SizedBox(height: 52),
              SizedBox(
                width: Get.width * 0.5,
                child: MGradientButton(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 46),
                  borderRadius: BorderRadius.circular(8),
                  gradient: AppColors.primaryGradient,
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      await AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
                    } else {
                      await AppSettings.openAppSettings();
                    }
                  },

                  child: Text(
                    L.tryAgain.tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
