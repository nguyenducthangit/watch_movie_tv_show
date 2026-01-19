// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';

// class NoInternet extends StatelessWidget {
//   const NoInternet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF232326),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF232326),
//         centerTitle: true,
//         title: Text(
//           'No Internet',
//           style: Get.textTheme.headlineMedium?.copyWith(
//             color: AppColors.white,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 270,
//                 width: 270,
//                 child: Image.asset(R.ASSETS_IMAGES_IMG_DISCONECT_WIFI_PNG),
//               ),
//               const SizedBox(height: 25),
//               Text(
//                 MLang.noInternetTitle.tr,
//                 style: Get.textTheme.titleMedium?.copyWith(AppColors.white),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 MLang.noInternetDescription.tr,
//                 textAlign: TextAlign.center,
//                 style: Get.textTheme.labelMedium?.copyWith(AppColors.white),
//               ).marginSymmetric(horizontal: Get.width * 0.1),
//               const SizedBox(height: 52),
//               SizedBox(
//                 width: Get.width * 0.5,
//                 child: MGradientButton(
//                   padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 46),
//                   borderRadius: BorderRadius.circular(8),
//                   AppColors.primaryGradient,
//                   onPressed: () async {
//                     if (Platform.isIOS) {
//                       await AppSettings.openAppSettings().then((value) {
//                         Get.offAllNamed(MRoutes.splash);
//                       });
//                     } else {
//                       await AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi).then((
//                         value,
//                       ) {
//                         Get.offAllNamed(MRoutes.splash);
//                       });
//                     }
//                   },
//                   child: Text(
//                     MLang.tryAgain.tr,
//                     textAlign: TextAlign.center,
//                     style: Get.textTheme.headlineMedium?.copyWith(AppColors.white, fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
