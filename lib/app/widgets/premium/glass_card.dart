import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';

/// Premium glassmorphism card widget
/// Creates a frosted glass effect with blur background
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius = 16,
    this.borderColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isDark = true,
  });

  final Widget child;

  /// Blur intensity
  final double blur;

  /// Background opacity (0.0 - 1.0)
  final double opacity;

  /// Corner radius
  final double borderRadius;

  /// Border color (default: subtle white)
  final Color? borderColor;

  /// Inner padding
  final EdgeInsetsGeometry? padding;

  /// Outer margin
  final EdgeInsetsGeometry? margin;

  /// Fixed width
  final double? width;

  /// Fixed height
  final double? height;

  /// Use dark tint (better for dark theme)
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surface.withValues(alpha: opacity + 0.6)
                  : Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Variant with gradient overlay
class GlassCardGradient extends StatelessWidget {
  const GlassCardGradient({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.gradientColors,
  });

  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    gradientColors ??
                    [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
