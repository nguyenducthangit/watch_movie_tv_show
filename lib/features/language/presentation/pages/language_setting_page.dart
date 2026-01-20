import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

import '../controllers/language_bindings.dart';
import '../controllers/language_setting_controller.dart';
import '../widgets/language_list.dart';
import '../widgets/language_submit_button.dart';

class LanguageSettingPage extends GetView<LanguageSettingController> {
  const LanguageSettingPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const LanguageSettingPage(),
    settings: settings,
    routeName: MRoutes.languageSetting,
    binding: LanguageSettingBindings(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const MBackButton(),
        title: Text(L.language.tr, style: MTextTheme.h3Medium),
        actions: const [LanguageSubmitButton<LanguageSettingController>()],
      ),
      body: const Column(
        children: [
          Expanded(child: LanguageList<LanguageSettingController>()),
          // EasyBannerAd(
          //   type: EasyAdsBannerType.adaptive,
          //   adId: Get.find().banner_all,
          //   config: RemoteConfig.banner_all,
          //   visibilityDetectorKey: runtimeType.toString(),
          //   reloadOnClick: true,
          // ),
        ],
      ),
    );
  }
}
