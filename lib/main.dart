import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/network_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/subtitle_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
import 'package:watch_movie_tv_show/app/services/watchlist_service.dart';

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

  // Initialize Storage
  await StorageService.instance.init();

  // Register services
  Get.put(NetworkService(), permanent: true);
  Get.put(DownloadService(), permanent: true);
  Get.put(SubtitleService(), permanent: true);
  await Get.putAsync(() => WatchProgressService().init());
  await Get.putAsync(() => WatchlistService().init());

  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
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
