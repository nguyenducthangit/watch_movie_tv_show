import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_theme.dart';
import 'package:watch_movie_tv_show/app/services/connectivity_service.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/network_service.dart';
import 'package:watch_movie_tv_show/app/services/shared_pref_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
import 'package:watch_movie_tv_show/app/services/watchlist_service.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/features/translation/controller/translation_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize Storage services FIRST
  await StorageService.instance.init();
  await SharedPrefService.init(); // Critical: Initialize before services that use it

  // Register services
  Get.put(ConnectivityService(), permanent: true);
  Get.put(NetworkService(), permanent: true);
  Get.put(DownloadService(), permanent: true);
  await Get.putAsync(() => WatchProgressService().init());
  await Get.putAsync(() => WatchlistService().init());

  // Initialize translation services
  TranslationBindings().dependencies();

  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: L.appName.tr,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Navigation
      initialRoute: MRoutes.initial,
      onGenerateRoute: MRoutes.onGenerateRoute,

      // Default transitions
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 250),

      // Scroll behavior
      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
    );
  }
}
