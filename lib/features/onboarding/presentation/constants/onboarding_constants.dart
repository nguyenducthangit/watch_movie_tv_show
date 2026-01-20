import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

import '../../data/models/onboarding_model.dart';

class OnboardingConstants {
  static const onboardingPages = [
    OnboardingModel(
      title: L.onboardingTitle1,
      description: L.onboardingDescription1,
      imagePath: 'assets/images/onboarding_1.png',
      padding: EdgeInsets.fromLTRB(50, 105, 38, 60),
    ),
    OnboardingModel(
      title: L.onboardingTitle2,
      description: L.onboardingDescription2,
      imagePath: 'assets/images/onboarding_2.png',
      padding: EdgeInsets.fromLTRB(46, 88, 42, 77),
    ),
    OnboardingModel(
      title: L.onboardingTitle3,
      description: L.onboardingDescription3,
      imagePath: 'assets/images/onboarding_3.png',
      padding: EdgeInsets.fromLTRB(44, 82, 44, 83),
    ),
  ];

//   static const onboardingNativeFull = 'fullscreen_native_ad';
//   static const onboardingNativeFullModel = OnboardingModel(
//     title: onboardingNativeFull,
//     description: onboardingNativeFull,
//     imagePath: onboardingNativeFull,
//     padding: EdgeInsets.zero,
//   );
//   static const onboardingNativeFullIndex = 2;
}
