import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';

/// Empty State Widget
/// Display empty content with optional action button
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
     this.title,
    this.message,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize = 80,
  });
  final IconData icon;
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title!,
                style: MTextTheme.h4SemiBold.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: MTextTheme.body2Regular.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (buttonText != null && onButtonPressed != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
