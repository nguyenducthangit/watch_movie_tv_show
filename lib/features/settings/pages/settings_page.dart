import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/utils/assets.gen.dart';

import '../../../app/translations/lang/lang.dart';
import '../settings.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings routeSettings) {
    return GetPageRoute(
      page: () => const SettingsPage(),
      binding: SettingsBindings(),
      settings: routeSettings,
      routeName: MRoutes.settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    const divider = Divider(color: AppColors.secondary, height: 0);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: const MBackButton(),
        title: Text(L.settings.tr, style: MTextTheme.h3SemiBold),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Assets.images.bgSettings.image(
          //   height: context.height,
          //   width: context.width,
          //   fit: BoxFit.cover,
          // ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20 + 60 + MediaQuery.of(context).padding.top),
                      Obx(
                        () => SettingsItem(
                          icon: Assets.icons.icSettingsLanguage.path,
                          title: L.settingsLanguage.tr,
                          subtitle: controller.selectedLanguage.tr,
                          onTap: controller.handleLanguageSettings,
                        ),
                      ),
                      Obx(() {
                        if (controller.isRated.value) return const SizedBox.shrink();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            divider,
                            SettingsItem(
                              icon: Assets.icons.icSettingsRate.path,
                              title: L.settingsRateUs.tr,
                              onTap: controller.handleRateUs,
                            ),
                          ],
                        );
                      }),

                      divider,
                      SettingsItem(
                        icon: Assets.icons.icSettingsShare.path,
                        title: L.settingsShare.tr,
                        onTap: controller.handleShare,
                      ),
                      divider,
                      SettingsItem(
                        icon: Assets.icons.icSettingsPrivacy.path,
                        title: L.settingsPrivacyPolicy.tr,
                        onTap: controller.handlePrivacyPolicy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
