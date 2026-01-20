import 'package:exo_shared/exo_shared.dart' show BaseController, RateDialog;
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_movie_tv_show/app/config/app_config.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/services/shared_pref_service.dart';

import '../../../app/translations/lang/lang.dart';
import '../settings.dart';

class SettingsController extends BaseController {
  SettingsController({required SettingsRepository repository}) : _repository = repository;
  final _selectedLanguage = ''.obs;
  final _selectedCurrency = ''.obs;
  final SettingsRepository _repository;
  final isRated = false.obs;
  final isSharing = false.obs;

  @override
  Future<void> initData() async {
    initLanguage();
    initRate();
  }

  @override
  void onClose() {
    // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    // super.onClose();
  }

  void initLanguage() {
    final language = _repository.getLanguage() ?? 'en';
    _selectedLanguage.value = 'lang${language.toUpperCase()}';
  }

  void initRate() {
    isRated.value = SharedPrefService.getRated();
  }

  String get selectedLanguage => _selectedLanguage.value;
  String get selectedCurrency => _selectedCurrency.value;

  void handleLanguageSettings() {
    Get.toNamed(MRoutes.languageSetting)?.then((value) {
      initLanguage();
    });
  }

  Future<void> handleRateUs() async {
    if (isRated.value) {
      Get.snackbar(L.rateAlreadyRated.tr, '', duration: const Duration(seconds: 2));
      return;
    }
    Get.dialog(const RateDialog()).then((value) {
      initRate();
    });
  }

  Future<void> handleShare() async {
    if (isSharing.value) return;
    isSharing.value = true;
    // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    Share.share(
      'https://play.google.com/store/apps/details?id=${AppConfig.packageInfo.packageName}',
      subject: L.appName.tr,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    isSharing.value = false;
    // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
  }

  Future<void> handlePrivacyPolicy() async {
    const url = 'https://sites.google.com/zen-s.com/aho-voicechanger/home';
    // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
