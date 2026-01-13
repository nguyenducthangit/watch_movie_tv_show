import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';

/// Premium visual effects for cinematic UI
/// Glassmorphism, shadows, gradients utilities
class AppEffects {
  AppEffects._();

  // ============================================
  // GLASSMORPHISM EFFECTS
  // ============================================

  /// Glass card decoration with frosted blur effect
  /// [blur] - Blur intensity (default: 10)
  /// [opacity] - Background opacity (default: 0.1)
  /// [borderRadius] - Corner radius (default: 16)
  static BoxDecoration glassCard({
    double blur = 10,
    double opacity = 0.1,
    double borderRadius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
    );
  }

  /// Glass card with dark tint for dark theme
  static BoxDecoration glassCardDark({
    double blur = 10,
    double opacity = 0.15,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: AppColors.surface.withValues(alpha: opacity + 0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
    );
  }

  /// Blur filter for glassmorphism background
  static ImageFilter glassBlur({double sigma = 10}) {
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }

  // ============================================
  // CINEMATIC SHADOWS
  // ============================================

  /// Premium multi-layer shadow for elevated components
  static List<BoxShadow> cinematicShadow({
    Color? color,
    double elevation = 1.0,
  }) {
    final shadowColor = color ?? Colors.black;
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.3 * elevation),
        blurRadius: 8 * elevation,
        offset: Offset(0, 4 * elevation),
      ),
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.15 * elevation),
        blurRadius: 20 * elevation,
        offset: Offset(0, 8 * elevation),
      ),
    ];
  }

  /// Soft shadow for cards
  static List<BoxShadow> softShadow({double opacity = 0.2}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Glow effect for primary colored elements
  static List<BoxShadow> primaryGlow({double intensity = 0.4}) {
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: intensity),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Inner shadow for depth effect
  static BoxDecoration innerShadow({
    double borderRadius = 16,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.card,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 2),
          blurStyle: BlurStyle.inner,
        ),
      ],
    );
  }

  // ============================================
  // GRADIENT OVERLAYS
  // ============================================

  /// Cinematic fade from top to bottom
  static LinearGradient fadeToBottom({
    Color? endColor,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.3),
        endColor ?? AppColors.background,
      ],
      stops: stops ?? const [0.0, 0.5, 1.0],
    );
  }

  /// Hero banner gradient overlay
  static LinearGradient heroOverlay() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.transparent,
        Colors.black.withValues(alpha: 0.4),
        Colors.black.withValues(alpha: 0.8),
        AppColors.background,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );
  }

  /// Horizontal fade for category rows
  static LinearGradient fadeHorizontal({bool fadeRight = true}) {
    return LinearGradient(
      begin: fadeRight ? Alignment.centerLeft : Alignment.centerRight,
      end: fadeRight ? Alignment.centerRight : Alignment.centerLeft,
      colors: [
        Colors.transparent,
        AppColors.background.withValues(alpha: 0.8),
        AppColors.background,
      ],
      stops: const [0.7, 0.9, 1.0],
    );
  }

  // ============================================
  // CARD DECORATIONS
  // ============================================

  /// Premium video card decoration
  static BoxDecoration videoCard({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: softShadow(),
    );
  }

  /// Featured/Hero card with glow
  static BoxDecoration featuredCard({double borderRadius = 20}) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        ...cinematicShadow(elevation: 1.5),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.1),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Modal/Dialog decoration
  static BoxDecoration modalDecoration({double borderRadius = 24}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: cinematicShadow(elevation: 2),
    );
  }
}
