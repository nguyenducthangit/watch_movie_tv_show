import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';

import '../../data/models/onboarding_model.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._repository);
  final IOnboardingRepository _repository;
  final RxInt currentPage = 0.obs;
  final RxList<OnboardingModel> pages = <OnboardingModel>[].obs;
  final _pageController = PageController();
  PageController get pageController => _pageController;
  final showNativeFull = false.obs;
  bool containNativeFull = false;

  @override
  void onInit() {
    super.onInit();
    pages.value = _repository.getOnboardingPages();
    final listPage = <OnboardingModel>[..._repository.getOnboardingPages()];
    // if (AdsConfig.onBoardFullCtrl != null) {
    //   listPage.insert(
    //     OnboardingConstants.onboardingNativeFullIndex,
    //     OnboardingConstants.onboardingNativeFullModel,
    //   );
    //   containNativeFull = true;
    // }
    pages.value = listPage;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    // if (containNativeFull) {
    //   showNativeFull.value = index == OnboardingConstants.onboardingNativeFullIndex;
    // } else {
    //   showNativeFull.value = false;
    // }
  }

  void onNextPage() {
    // if (showNativeFull.value) {
    //   showNativeFull.value = false;
    // } else if (containNativeFull &&
    //     currentPage.value == OnboardingConstants.onboardingNativeFullIndex - 1) {
    //   showNativeFull.value = true;
    // }
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> completeOnboarding() async {
    Get.offAllNamed(MRoutes.mainNav);
  }

  // void showInter() {
  //   EasyAds.instance.showInterstitialAd(
  //     adId: AdsIdManager.interIntro,
  //     config: AdsConfig.interIntro,
  //     onAdShowed: (adNetwork, adUnitType, data) {
  //       AdsConfig.setLastTimeShowInter();
  //     },
  //     onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) => completeOnboarding(),
  //     onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) => completeOnboarding(),
  //     onDisabled: () => completeOnboarding(),
  //     onAdDismissed: (adNetwork, adUnitType, data) => completeOnboarding(),
  //   );
  // }

  bool get isLastPage => currentPage.value == pages.length - 1;
}
