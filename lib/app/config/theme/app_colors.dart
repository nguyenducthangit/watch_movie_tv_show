import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Gold/Amber for cinematic feel)
  static const Color primary = Color(0xFFD4AF37); // Metallic Gold
  static const Color primaryLight = Color(0xFFF4C430);
  static const Color primaryDark = Color(0xFFA67D3D);

  // Accent/Secondary
  static const Color secondary = Color(0xFFE5E7EB); // Silver/White
  static const Color accent = Color(0xFF6366F1); // Indigo for accents

  // Background Colors (Cinematic Dark)
  static const Color background = Color(0xFF0B0E11); // Deep blue-black (đỡ gắt hơn #000)
  static const Color surface = Color(0xFF12161C); // Dark navy grey
  static const Color surfaceVariant = Color(0xFF1A1F27); // Card / section
  static const Color card = Color(0xFF161B22); // Elevated card

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc-400
  static const Color textTertiary = Color(0xFF71717A); // Zinc-500
  static const Color textBody = Color(0xFFD4D4D8); // Zinc-300
  static const Color textBodyNight = Color(0xFF2E2E2E); // Zinc-300

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1C1C), Color(0xFF181818)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient overlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xE6000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF262626);
  static const Color shimmerHighlight = Color(0xFF404040);

  // Divider & Border
  static const Color divider = Color(0xFF27272A);
  static const Color border = Color(0xFF3F3F46);

  // Overlay
  static const Color overlay = Color(0xAA000000);
  static const Color modalBarrier = Color(0xD9000000);

  // Download Status
  static const Color downloadQueued = textTertiary;
  static const Color downloadActive = primary;
  static const Color downloadPaused = warning;
  static const Color downloadCompleted = success;
  static const Color downloadFailed = error;
  //
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
}
