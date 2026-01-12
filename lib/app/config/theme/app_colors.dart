import 'package:flutter/material.dart';

/// App Color Palette
/// Material 3 inspired dark theme for video streaming app
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Accent/Secondary
  static const Color secondary = Color(0xFFF472B6);
  static const Color accent = Color(0xFF22D3EE);

  // Background Colors
  static const Color background = Color(0xFF0F0F23);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF252542);
  static const Color card = Color(0xFF16213E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4C7);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textBody = Color(0xFFE5E7EB);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient overlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF252542);
  static const Color shimmerHighlight = Color(0xFF3D3D5C);

  // Divider & Border
  static const Color divider = Color(0xFF2D2D4A);
  static const Color border = Color(0xFF3D3D5C);

  // Overlay
  static const Color overlay = Color(0x99000000);
  static const Color modalBarrier = Color(0xCC000000);

  // Download Status
  static const Color downloadQueued = textTertiary;
  static const Color downloadActive = accent;
  static const Color downloadPaused = warning;
  static const Color downloadCompleted = success;
  static const Color downloadFailed = error;
}
