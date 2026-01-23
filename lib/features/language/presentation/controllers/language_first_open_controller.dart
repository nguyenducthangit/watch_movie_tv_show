import 'package:get/get.dart';

import '../../../../app/config/m_routes.dart';
import '../enums/language_enums.dart';
import 'language_controller.dart';

class LanguageFirstOpenController extends LanguageController {
  LanguageFirstOpenController(super.languageRepository, super.translateService);
  @override
  Future<void> onSubmit() async {
    super.onSubmit();
    Get.offAllNamed(MRoutes.onboarding);
  }

  // static EasyPreloadNativeController easyPreloadNativeBottomController =
  //     EasyPreloadNativeController(
  //       nativeNormalId: adIdManager.native_intro,
  //       nativeHighId: null,
  //       autoReloadOnFinish: true,
  //     );

  // final durationDelay = Duration(seconds: RemoteConfig.time_delay_confirm_language);

  @override
  Future<void> onChanged(LanguageCode langCode) async {
    super.onChanged(langCode);
    await Future.delayed(const Duration(seconds: 10));
    canShowSubmitButton.value = true;
  }

  // void initOnBoardFullCtrl() {
  //   if (RemoteConfig.native_intro_full &&
  //       !EasyAds.instance.isDeviceOffline &&
  //       RemoteConfig.enable_ads) {
  //     final nativeIntroFull = SharedPrefService.isFirstLaunchCached
  //         ? adIdManager.native_intro_full
  //         : adIdManager.native_intro_full_2;
  //     RemoteConfig.onBoardFullCtrl = EasyPreloadNativeController(
  //       autoReloadOnFinish: false,
  //       nativeNormalId: nativeIntroFull,
  //       nativeHighId: nativeIntroFull,
  //     );
  //     RemoteConfig.onBoardFullCtrl!.load();
  //   }
  // }
}
