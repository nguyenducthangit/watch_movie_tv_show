import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/translations/m_translations.dart';

class App extends StatelessWidget {
  const App({super.key, this.initialLocale});

  final Locale? initialLocale;

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      translations: MTranslations(),
      fallbackLocale: MTranslations.fallbackLocale,
      supportedLocales: MTranslations.supportedLocales,
      locale: initialLocale ?? Get.locale,
      onGenerateTitle: (context) => L.appName.tr,
    );
  }
}
