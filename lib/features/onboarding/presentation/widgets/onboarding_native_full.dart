// import 'package:easy_ads_flutter/easy_ads_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../app/config/configs.dart';

// class OnboardingNativeFull extends StatefulWidget {
//   const OnboardingNativeFull({super.key});

//   @override
//   State<OnboardingNativeFull> createState() => _OnboardingNativeFullState();
// }

// class _OnboardingNativeFullState extends State<OnboardingNativeFull>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Stack(
//       children: [
//         EasyPreloadNativeAd(
//           controller: AdsConfig.onBoardFullCtrl!,
//           borderRadius: BorderRadius.zero,
//           factoryId: AdsConfig.fullScreenNativeAdFactory,
//           height: Get.height,
//         ),
//       ],
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
