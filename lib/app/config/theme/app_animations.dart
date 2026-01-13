import 'package:flutter/material.dart';

/// Premium animation constants and curves
/// Consistent timing across the app for smooth UX
class AppAnimations {
  AppAnimations._();

  // ============================================
  // DURATION CONSTANTS
  // ============================================

  /// Instant feedback (button taps, micro-interactions)
  static const Duration instant = Duration(milliseconds: 100);

  /// Fast transitions (ripples, small state changes)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal transitions (page elements, cards)
  static const Duration normal = Duration(milliseconds: 300);

  /// Medium transitions (modals, overlays)
  static const Duration medium = Duration(milliseconds: 400);

  /// Slow transitions (page routes, hero animations)
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow (complex animations, carousel auto-rotate)
  static const Duration extraSlow = Duration(milliseconds: 800);

  /// Hero carousel auto-rotate interval
  static const Duration carouselInterval = Duration(seconds: 5);

  // ============================================
  // CURVES
  // ============================================

  /// Default curve for most animations - smooth deceleration
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// For entrance animations
  static const Curve enterCurve = Curves.easeOutQuart;

  /// For exit animations
  static const Curve exitCurve = Curves.easeInQuart;

  /// For scale/bounce effects
  static const Curve bounceCurve = Curves.elasticOut;

  /// For spring-like animations
  static const Curve springCurve = Curves.easeOutBack;

  /// For smooth continuous animations
  static const Curve smoothCurve = Curves.easeInOutCubic;

  /// For fade animations
  static const Curve fadeCurve = Curves.easeInOut;

  // ============================================
  // ANIMATION HELPERS
  // ============================================

  /// Stagger delay calculator for list items
  /// [index] - Item index in list
  /// [baseDelay] - Base delay between items (default: 50ms)
  /// [maxDelay] - Maximum total delay to prevent long waits
  static Duration staggerDelay(
    int index, {
    Duration baseDelay = const Duration(milliseconds: 50),
    Duration maxDelay = const Duration(milliseconds: 400),
  }) {
    final delay = Duration(milliseconds: baseDelay.inMilliseconds * index);
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Get stagger interval for AnimationController
  static double staggerInterval(int index, int totalItems) {
    if (totalItems <= 1) return 0.0;
    final interval = index / totalItems;
    return interval.clamp(0.0, 0.8); // Cap at 80% to ensure all items animate
  }

  // ============================================
  // TWEEN DEFAULTS
  // ============================================

  /// Fade in tween (0 -> 1)
  static Tween<double> fadeInTween = Tween<double>(begin: 0.0, end: 1.0);

  /// Fade out tween (1 -> 0)
  static Tween<double> fadeOutTween = Tween<double>(begin: 1.0, end: 0.0);

  /// Scale up tween (0.8 -> 1.0)
  static Tween<double> scaleUpTween = Tween<double>(begin: 0.8, end: 1.0);

  /// Scale down tween (1.0 -> 0.95) for tap feedback
  static Tween<double> scaleTapTween = Tween<double>(begin: 1.0, end: 0.95);

  /// Slide from bottom tween
  static Tween<Offset> slideFromBottomTween = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  );

  /// Slide from right tween
  static Tween<Offset> slideFromRightTween = Tween<Offset>(
    begin: const Offset(0.3, 0),
    end: Offset.zero,
  );

  // ============================================
  // PAGE TRANSITIONS
  // ============================================

  /// Premium page route transition
  static PageRouteBuilder<T> premiumPageRoute<T>({required Widget page, RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: defaultCurve,
          reverseCurve: exitCurve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Modal bottom sheet transition
  static PageRouteBuilder<T> modalRoute<T>({required Widget page, RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      opaque: false,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: medium,
      reverseTransitionDuration: fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: enterCurve,
          reverseCurve: exitCurve,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}
