import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

import '../../../../app/config/m_routes.dart';
import '../../../../app/config/theme/m_text_theme.dart';
import '../controllers/language_bindings.dart';
import '../controllers/language_first_open_controller.dart';
import '../widgets/language_list.dart';
import '../widgets/language_submit_button.dart';

class LanguageFirstOpenPage extends GetView<LanguageFirstOpenController> {
  const LanguageFirstOpenPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const LanguageFirstOpenPage(),
    settings: settings,
    routeName: MRoutes.languageFirstOpen,
    binding: LanguageFirstOpenBindings(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L.language.tr, style: MTextTheme.h3Medium),
        actions: const [LanguageSubmitButton<LanguageFirstOpenController>()],
        centerTitle: false,
      ),
      body: const Column(
        children: [
          Expanded(child: LanguageList<LanguageFirstOpenController>()),
          // SafeArea(
          //   child: SharedPrefService.isFirstLaunchCached
          //       ? EasyNativeAdReload(
          //           factoryId: adIdManager.largeTopNativeFactory,
          //           adId: adIdManager.native_language,
          //           height: adIdManager.largeNativeAdHeight,
          //           config: RemoteConfig.native_language,
          //           visibilityDetectorKey: "${runtimeType.toString()}native_language_1",
          //           color: AppColors.bgAds,
          //           onAdClicked: (adNetwork, adUnitType, data) async {
          //             /// handle no show ads
          //           },
          //           refreshRateSec: RemoteConfig.time_native_reload,
          //           borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          //           shouldReload: false,
          //         )
          //       : EasyNativeAdReload(
          //           factoryId: adIdManager.largeTopNativeFactory,
          //           adId: adIdManager.native_language_2,
          //           height: adIdManager.largeNativeAdHeight,
          //           config: RemoteConfig.native_language_2,
          //           visibilityDetectorKey: "${runtimeType.toString()}native_language_2",
          //           color: AppColors.bgAds,
          //           onAdClicked: (adNetwork, adUnitType, data) async {
          //             /// handle no show ads
          //           },
          //           refreshRateSec: RemoteConfig.time_native_reload,
          //           borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          //           shouldReload: false,
          //         ),
          // ),
        ],
      ),
    );
  }
}
