import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/detail/pages/detail_page.dart';
import 'package:watch_movie_tv_show/features/downloads/pages/downloads_page.dart';
import 'package:watch_movie_tv_show/features/home/pages/home_page.dart';
import 'package:watch_movie_tv_show/features/language/presentation/pages/language_first_open_page.dart';
import 'package:watch_movie_tv_show/features/language/presentation/pages/language_setting_page.dart';
import 'package:watch_movie_tv_show/features/main_nav/pages/main_nav_page.dart';
import 'package:watch_movie_tv_show/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:watch_movie_tv_show/features/player/pages/player_page.dart';
import 'package:watch_movie_tv_show/features/settings/pages/settings_page.dart';
// Feature imports
import 'package:watch_movie_tv_show/features/splash/pages/splash_page.dart';
import 'package:watch_movie_tv_show/features/watchlist/pages/watchlist_page.dart';

/// Route Constants
class MRoutes {
  MRoutes._();

  // Route paths
  static const String splash = '/splash';
  static const String mainNav = '/main';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String player = '/player';
  static const String downloads = '/downloads';
  static const String watchlist = '/watchlist';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String languageFirstOpen = '/language_first_open';
  static const String languageSetting = '/language_setting';
  static const String onboarding = '/onboarding';

  /// Initial route
  static const String initial = splash;

  /// Generate route
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return SplashPage.getPageRoute(settings);
      case mainNav:
        return MainNavPage.getPageRoute(settings);
      case home:
        return HomePage.getPageRoute(settings);
      case detail:
        return DetailPage.getPageRoute(settings);
      case player:
        return PlayerPage.getPageRoute(settings);
      case downloads:
        return DownloadsPage.getPageRoute(settings);
      case MRoutes.settings:
        return SettingsPage.getPageRoute(settings);
      case MRoutes.watchlist:
        return WatchlistPage.getPageRoute(settings);
      case languageFirstOpen:
        return LanguageFirstOpenPage.getPageRoute(settings);
      case languageSetting:
        return LanguageSettingPage.getPageRoute(settings);
      case onboarding:
        return OnboardingPage.getPageRoute(settings);
      default:
        return _errorRoute(settings);
    }
  }

  /// Error route for unknown routes
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return GetPageRoute(
      settings: settings,
      page: () => Scaffold(
        body: Center(
          child: Text(
            'Route not found: ${settings.name}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Custom page transitions
class MPageTransitions {
  MPageTransitions._();

  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// Slide from right transition
  static Widget slideRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  /// Slide from bottom transition
  static Widget slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }
}
