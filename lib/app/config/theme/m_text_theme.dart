import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text Theme following Material 3 guidelines
/// Uses system font (Roboto on Android, SF Pro on iOS)
class MTextTheme {
  static const Color _color = AppColors.textBody;

  static const TextTheme textTheme = TextTheme(
    displayLarge: h1Regular,
    displayMedium: h2Regular,
    displaySmall: h3Regular,
    headlineMedium: h4Regular,
    headlineSmall: subTitle1Regular,
    titleLarge: body1Regular,
    bodyLarge: body1Regular,
    bodyMedium: body2Regular,
    bodySmall: captionRegular,
  );

  // H1 - 32px
  static const h1Regular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 32,
    height: 1.25,
    color: _color,
  );

  static const h1Medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 32,
    height: 1.25,
    color: _color,
  );

  static const h1SemiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 1.25,
    color: _color,
  );

  static const h1Bold = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.25,
    color: _color,
  );

  // H2 - 28px
  static const h2Regular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 28,
    height: 1.28,
    color: _color,
  );

  static const h2Medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 28,
    height: 1.28,
    color: _color,
  );

  static const h2SemiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 1.28,
    color: _color,
  );

  static const h2Bold = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.28,
    color: _color,
  );

  // H3 - 24px
  static const h3Regular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: 1.33,
    color: _color,
  );

  static const h3Medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 1.33,
    color: _color,
  );

  static const h3SemiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.33,
    color: _color,
  );

  static const h3Bold = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.33,
    color: _color,
  );

  // H4 - 20px
  static const h4Regular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 20,
    height: 1.4,
    color: _color,
  );

  static const h4Medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 1.4,
    color: _color,
  );

  static const h4SemiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.4,
    color: _color,
  );

  // SubTitle1 - 18px
  static const subTitle1Regular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 1.5,
    color: _color,
  );

  static const subTitle1Medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 1.5,
    color: _color,
  );

  // Body1 - 16px
  static const body1Regular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    color: _color,
  );

  static const body1Medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.5,
    color: _color,
  );

  static const body1SemiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.5,
    color: _color,
  );

  // Body2 - 14px
  static const body2Regular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    color: _color,
  );

  static const body2Medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.5,
    color: _color,
  );

  static const body2SemiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.5,
    color: _color,
  );

  // Caption - 12px
  static const captionRegular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.33,
    color: _color,
  );

  static const captionMedium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.33,
    color: _color,
  );

  static const captionSemiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.33,
    color: _color,
  );

  // Small Text - 10px
  static const smallTextRegular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 10,
    height: 1.2,
    color: _color,
  );

  static const smallTextMedium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 10,
    height: 1.2,
    color: _color,
  );
}
