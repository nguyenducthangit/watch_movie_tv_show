import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:watch_movie_tv_show/app/config/app_config.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/services/connectivity_service.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/shared_pref_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
import 'package:watch_movie_tv_show/app/services/watchlist_service.dart';
import 'package:watch_movie_tv_show/features/app.dart';
import 'package:watch_movie_tv_show/features/translation/controller/translation_bindings.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _setSystemUI();
      AppConfig.packageInfo = await PackageInfo.fromPlatform();

      await StorageService.instance.init();
      await SharedPrefService.init();

      Get.put(ConnectivityService(), permanent: true);
      Get.put(DownloadService(), permanent: true);
      await Get.putAsync(() => WatchProgressService().init());
      await Get.putAsync(() => WatchlistService().init());

      TranslationBindings().dependencies();

      final savedLang = SharedPrefService.getLang();
      Locale? initialLocale;
      if (savedLang != null) {
        initialLocale = Locale(savedLang);
      }

      runApp(App(initialLocale: initialLocale));
    },
    ((error, stack) {
      log('error: $error');
      log('stack: $stack');
    }),
  );
}

void _setSystemUI() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
}
